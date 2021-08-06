//
//  PenCommParser.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 8..
//  Editted by SB KIM on 2020.10.22
//  Copyright © 2017년 NeoLab. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit

#elseif os(macOS)
import AppKit
#else
#endif

class PenCommParser {
    
    weak var penDelegate: PenDelegate?
    weak var penCtrl : PenController!
    
    private let SEAL_SECTION_ID = 4
    private var packetData: [UInt8] = []
    private var IsEscape: Bool = false
    private var finalpinNumber = "0000"
    // authorized flag
    var needAuthorized = true
    
    //RealTime Dot
    private var isDown = false
    private var currntDot : Dot?
    private var currentPage : PageInfo?
    private var timestamp : Int = 0
    private var penTipType: PenTipType = PenTipType.Normal
    private var penTipColor: UIColor = UIColor.black
    
    //Offline Data
    private var offlineTotalDataReceived: Int = 0
    private var offlineTotalDataSize: Int = 0
    var cancelOfflineSync = false
    
    //Firmware Updata
    var fwFile: [UInt8] = []
    private let UPDATE2_DATA_PACKET_SIZE: UInt32 = 2048
    var cancelFWUpdate = false
    private var isZip = false
    
    //Dot Filter Use
    private var filter : DotFilter!
    private var maxForce: Float = 256

    //ProtocolVerion
    var protocolVersion: Float?
    
    // penVersionInfo
    var penVersionInfo: PenVersionInfo?
    
    // SoundPen
    private var isStopLog = false
    private var logRetryCount = 0
    
    init(penCommController manager: PenController) {
        self.penCtrl = manager
        self.filter = DotFilter(self)
    }
    
    //MARK: - Pen Data [UInt8], length
    func parsePen2Data(_ data: [UInt8]) {
        // N.Log("Received:length = \(data.count)",data);
        for i in 0..<data.count {
            if data[i] == PACKET_START{
                packetData.removeAll()
                IsEscape = false
            }else if data[i] == PACKET_END{
                parsePenDataPacket(packetData)
                IsEscape = false
            }else if data[i] == PACKET_DLE{
                IsEscape = true
            }else if IsEscape {
                packetData.append(data[i] ^ 0x20)
                IsEscape = false
            }else{
                packetData.append(data[i])
            }
        }
    }
    
    //MARK: - Data parsing
    // Complet Packet [CMD, (error), length, Data]
    func parsePenDataPacket(_ packet: [UInt8]) {
        let data: [UInt8] = packet
        
        if data.isEmpty{
            return
        }
        
        guard let cmd = CMD(rawValue: data[0]) else{
            N.Log("CMD Error")
            return
        }
        if penDelegate == nil {
            N.Log("Need to set Delegate")
        }
        
        if data.count < 3 {
            let msg = PenMessage.PEN_PACKET_ERROR(PacketErrorStruct(data))
            penDelegate?.penMessage(penCtrl, msg)
            return
        }
        
        var packetDataLength = Int(toUInt16(data[1],data[2]))
        var pos: Int = 3
        switch cmd {
        // MARK: Dot Data
        case .EVENT_PEN_DOTCODE, .EVENT_NEW_PEN_DOT:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            
            var dot = Dot.init(Array(data[pos..<pos+packetDataLength]), maxForce)
            guard dot.isValid else {
                N.Log("dot is invalid", dot)
                return
            }
            dot.penTipColor = penTipColor
            dot.penTipType = penTipType
            
            if let page = currentPage {
                if isDown {
                    dot.pageInfo = page
                    dot.dotType = .Down
                    timestamp += Int(dot.nTimeDelta)
                    dot.time = timestamp
                    self.penData(dot)
                    isDown = false
                }else {
                    dot.pageInfo = page
                    dot.dotType = .Move
                    timestamp += Int(dot.nTimeDelta)
                    dot.time = timestamp
                    self.penData(dot)
                }
                currntDot = dot
            }else {
                N.Log("Skip data",dot)
            }
            
            //            N.Log("=============dot packet end=============")
            
        case .EVENT_PEN_DOTCODE2:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let dot2 = DotStruct2.init(Array(data[pos..<pos+packetDataLength]))
            let dot = Dot.init(dot2: dot2)
            penData(dot)
            
        case .EVENT_PEN_DOTCODE3:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let dot3 = DotStruct3.init(Array(data[pos..<pos+packetDataLength]))
            let dot = Dot.init(dot3: dot3)
            penData(dot)
        case .EVENT_HOVER_DOT:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let hover = DotHover.init(Array(data[pos..<pos+packetDataLength]))
            
            var dot = Dot.init(hover: hover)
            if let page = currentPage {
                dot.pageInfo = page
            }
            
            self.hoverData(dot)
            
        case .EVENT_PEN_UPDOWN:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let upDown = PenUpDown.init(Array(data[pos..<pos+packetDataLength]))
            //            N.Log("UP Down", upDown)
            if upDown.upDown == .Down{
                isDown = true
                timestamp = upDown.time
                penTipType = upDown.penTipType
                penTipColor = upDown.penColor
            }else if upDown.upDown == .Up{
                //                N.Log("UP")
                if let dot = currntDot {
                    var d = dot
                    d.dotType = .Up
                    penData(d)
                    currntDot = nil
                }
            }
        case .EVENT_PEN_NEWID, .EVENT_NEW_PEN_NEWID:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let PID = PageInfo.init(Array(data[pos..<pos+packetDataLength]))
            guard PID.isValid else {
                N.Log("PageInfo is invalid", PID)
                return
            }
            //            N.Log("++++ page", PID)
            if let dot = currntDot {
                var d = dot
                d.dotType = .Up
                penData(d)
                isDown = true
            }
            currentPage = PID
        case .EVENT_DOT_ERROR, .EVENT_NEW_DOT_ERROR:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let dotError = DotError.init(Array(data[pos..<pos+packetDataLength]))
            if dotError.isValid {
                let msg = PenMessage.EVENT_DOT_ERROR(dotError)
                penDelegate?.penMessage(penCtrl, msg)
            }
            
        // MARK: Pen new Dot
        case .EVENT_NEW_PEN_DOWN:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let pendown = PenDown.init(Array(data[pos..<pos+packetDataLength]))
            if pendown.isValid {
                isDown = true
                timestamp = pendown.time
                penTipType = pendown.penTipType
                penTipColor = pendown.penColor
            }
        case .EVENT_NEW_PEN_UP:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let penup = PenUp.init(Array(data[pos..<pos+packetDataLength]))
            if penup.isValid {
                if let dot = currntDot {
                    var d = dot
                    d.dotType = .Up
                    penData(d)
                    currntDot = nil
                }
            }
        // MARK: Power Off Event
        case .EVENT_POWER_OFF:
            let powerOff = POWER_OFF.init(data[pos])
            if powerOff.reason == .Update {
                let msg = PenMessage.PEN_FW_UPGRADE_STATUS(100.0)
                penDelegate?.penMessage(penCtrl, msg)
            }else{
                let msg = PenMessage.EVENT_POWER_OFF(powerOff.reason)
                penDelegate?.penMessage(penCtrl, msg)
            }
            self.penCtrl.disConnect()
        // MARK: Battryy Alarm
        case .EVENT_BATT_ALARM:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let battLevel = BatterAlarm.init(data[pos])
            let msg = PenMessage.EVENT_LOW_BATTERY(battLevel.level)
            penDelegate?.penMessage(penCtrl, msg)
        // MARK: Offline Data
        case .RES1_OFFLINE_DATA_INFO:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            
            N.Log("Res1 offline data info error code : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if (data[1] != 0) {
                N.Log("OfflineFileStatus fail")
                let msg = PenMessage.OFFLINE_DATA_SEND_FAILURE
                penDelegate?.penMessage(penCtrl, msg)
                return
            }
            
            if data.count < (pos + packetDataLength) {
                N.Log("packet Length Error: ", cmd)
                let msg = PenMessage.OFFLINE_DATA_SEND_FAILURE
                penDelegate?.penMessage(penCtrl, msg)
                return
            }
            
            let offlineInfo = OfflineInfo(Array(data[pos..<pos+OfflineInfo.length]))
            offlineTotalDataReceived = 0
            offlineTotalDataSize = Int(offlineInfo.dataSize)
            let msg = PenMessage.OFFLINE_DATA_SEND_START
            penDelegate?.penMessage(penCtrl, msg)
            N.Log("Res1 offline data info:", offlineInfo)
            
        case .REQ2_OFFLINE_DATA:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let offlineData = OffLineData(Array(data[pos..<pos+OffLineData.length]))
            pos += OffLineData.length
            N.Log(offlineData)
            
            // Data Send
            if offlineData.isZip == 1 {
                let zippedData: [UInt8] = Array(data[pos..<(pos+Int(offlineData.sizeAfterZip))])
                N.Log("ZipSize", zippedData.count)
                
                let (penData, error) = CompressUtil().unzip(zippedData, offlineData.sizeBeforeZip)
                if error == nil {
                    // GOOD
                    N.Log("OFFLINE_DATA zip file received successfully")
                    if cancelOfflineSync || offlineData.trasPosition == .End {
                        requestOfflineDataAck(offlineData.packetId, .Success, .Stop)
                    } else {
                        requestOfflineDataAck(offlineData.packetId, .Success, .Continue)
                    }
                    parseSDK2OfflinePenData(penData, offlineData)

                }
                else {
                    // BAD
                    N.Log("OFFLINE_DATA zip file received badly, OfflineFileStatus fail", error ?? "error is empty")
                    if cancelOfflineSync || offlineData.trasPosition == .End {
                        requestOfflineDataAck(offlineData.packetId, .Fail, .Stop)
                    } else {
                        requestOfflineDataAck(offlineData.packetId, .Fail, .Continue)
                    }
                }
                
            }
            else {
                N.Log("OFFLINE_DATA file received successfully(is Not Zip)")
                let penData: [UInt8] = Array(data[pos..<(pos+Int(offlineData.sizeBeforeZip))])

                if cancelOfflineSync || offlineData.trasPosition == .End {
                    requestOfflineDataAck(offlineData.packetId, .Success, .Stop)
                } else {
                    requestOfflineDataAck(offlineData.packetId, .Success, .Continue)
                }
                parseSDK2OfflinePenData(penData, offlineData)

            }
            
            // Percent
            if offlineData.trasPosition == .End {
                N.Log("OFFLINE_DATA_RECEIVE_END")
                let msg = PenMessage.OFFLINE_DATA_SEND_STATUS(100.0)
                penDelegate?.penMessage(penCtrl, msg)
            } else {
                offlineTotalDataReceived += Int(offlineData.sizeBeforeZip)
                let percent = Float(offlineTotalDataReceived * 100) / Float(offlineTotalDataSize)
                N.Log("OFFLINE_DATA_RECEIVE Percent ", offlineTotalDataReceived, offlineTotalDataSize, percent)
                let msg = PenMessage.OFFLINE_DATA_SEND_STATUS(percent)
                penDelegate?.penMessage(penCtrl, msg)
            }
            

        case .RES1_OFFLINE_NOTE_LIST:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            
            N.Log("Res1 offline note list error code : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if (data[1] != 0) || (data.count < (packetDataLength + 4)) {
                return
            }
            let offlineNotes = OfflineNoteList(Array(data[pos...]))
            
            DispatchQueue.main.async(execute: {[weak self] () -> Void in
                let msg = PenMessage.OFFLINE_DATA_NOTE_LIST(offlineNotes)
                if let penCtrl = self?.penCtrl {
                    self?.penDelegate?.penMessage(penCtrl, msg)
                }
            })

        case .RES2_OFFLINE_PAGE_LIST:
            //error code
            
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            
            N.Log("Res2 offline page list error code : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if (data[1] != 0) || (data.count < (packetDataLength + 4)) {
                return
            }
            let pages = OfflinePageList(Array(data[pos...]))
            
            DispatchQueue.main.async(execute: {[weak self] () -> Void in
                let msg = PenMessage.OFFLINE_DATA_PAGE_LIST(pages)
                if let penCtrl = self?.penCtrl {
                    self?.penDelegate?.penMessage(penCtrl, msg)
                }
            })
        case .RES_DEL_OFFLINE_DATA:
            //error code
            
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            
            N.Log("Res delete offline data error code : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if (data[1] != 0) || (data.count < (packetDataLength + 4)) {
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let noteCount = data[pos]
            //deleted note count
            pos += 1
            if noteCount > 0 {
                for _ in 0..<noteCount {
                    
                    let note_ID = toUInt32(data,at: pos)
                    N.Log("note Id deleted \(note_ID)")
                    pos += 4
                }
            }
        //MARK: - Firmware update
        case .RES1_FW_FILE:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            N.Log("RES1_FW_FILE", data)
            if (data[1] != 0) || (data.count < (packetDataLength + 4)) {
                N.Log("RES1_FW_FILE error")
                return
            }
            
            let firmFirst = FirmwareUpdateFirst(Array(data[pos..<pos+packetDataLength]))
            N.Log("RES1_FW_FILE", firmFirst)
            
        case .REQ2_FW_FILE:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let firmSecond = FirmwareUpdateSecond(Array(data[pos..<pos+packetDataLength]))
            let percent: Float = Float(firmSecond.fileoffset * 100) / Float(fwFile.count)
//            N.Log("REQ2_FW_FILE", percent)

            let msg = PenMessage.PEN_FW_UPGRADE_STATUS(percent)
            penDelegate?.penMessage(penCtrl, msg)
            updateFirmwareSecond(at: firmSecond.fileoffset, andStatus: firmSecond.status.rawValue)
            
        // MARK: Using Note Set
        case .RES_SET_NOTE_LIST:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            N.Log("Res UsingNote : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if data[1] != 0 {
                return
            }
            else if data[1] == 0 {
                
            }
        // MARK: Pen Version Info
        case .RES_VERSION_INFO:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            let error = ErrorCode(rawValue: data[1])
            if error != ErrorCode.Success {
                N.Log("Fail", cmd)
                return
            }
            
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            
            let penInfo = PenVersionInfo.init(Array(data[pos..<pos+packetDataLength]))
            self.protocolVersion = Float(penInfo.protocolVer)
        
            self.penVersionInfo = penInfo
            self.requestPenSettingInfo()
            
        // MARK: PenState
        case .RES_PEN_STATE:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                return
            }
            
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            
            let penState = PenSettingStruct.init(Array(data[pos..<pos+packetDataLength]))
            maxForce = Float(penState.maxPressure)
            // MARK: PenInfo save
            penCtrl.penSetting = penState
            if penState.lock == PenSettingStruct.Lock.Lock { //Todo. BT ID 비교
                let pensetting = PenMessage.PEN_SETTING_INFO(penState)
                penDelegate?.penMessage(penCtrl, pensetting)
                
                var passwordStruct = PenPasswordStruct(penState.retryCnt, penState.maxRetryCnt)
                passwordStruct.status = .NeedPassword
                let msg = PenMessage.PEN_PASSWORD_REQUEST(passwordStruct)
                penDelegate?.penMessage(penCtrl, msg)
                
            } else {
                if needAuthorized {
                    let msg = PenMessage.PEN_AUTHORIZED
                    penDelegate?.penMessage(penCtrl, msg)
                    needAuthorized = false
                } else {
                    let msg = PenMessage.PEN_SETTING_INFO(penState)
                    penDelegate?.penMessage(penCtrl, msg)
                }
            }
            
            
        // pen status set Callback
        case .RES_SET_PEN_STATE:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            let error = ErrorCode(rawValue: data[1]) ?? ErrorCode.Fail
            if error != ErrorCode.Success {
                N.Log("Fail", cmd)
                let msg = PenMessage.PEN_SETUP_FAILURE(error)
                self.penDelegate?.penMessage(self.penCtrl, msg)
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let setupType = data[4]
            let changedType = PenSetupType(rawValue: setupType) ?? PenSetupType.NotDefine//
            N.Log("RES_SET_PEN_STATE", changedType)
            let msg = PenMessage.PEN_SETUP_SUCCESS(changedType)
            self.penDelegate?.penMessage(self.penCtrl, msg)
            
            
        // MARK: Password
        case .RES_COMPARE_PWD:
            //error code
            pos += 1
            
            packetDataLength = Int(toUInt16(data[2],data[3]))
            let error = ErrorCode(rawValue: data[1])
            if error != ErrorCode.Success {
                N.Log("Fail", cmd)
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            
            let res = PenPasswordStruct(Array(data[pos..<pos+packetDataLength]))
            N.Log("RES_COMPARE_PWD",res)
            
            if res.status ==  PenPasswordStruct.PasswordStatus.Success{
                let msg = PenMessage.PEN_AUTHORIZED
                self.penDelegate?.penMessage(self.penCtrl, msg)
                needAuthorized = false
            } else {
                let msg = PenMessage.PEN_PASSWORD_REQUEST(res)
                self.penDelegate?.penMessage(self.penCtrl, msg)
            }
            
        case .RES_CHANGE_PWD:
            var response = PenPasswordChangeStruct()
            //error code
            
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            
            //            N.Log("Res change password error code : \(data[1]), \((data[1] == 0) ? "Success" : "Fail")")
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            
            response.retryCount = data[pos]
            pos += 1
            
            response.resetCount = data[pos]
            N.Log("RES_CHANGE_PWD", response)
            // User Error Code: 0(success)*
            if data[1] == 0 {
                let msg = PenMessage.PASSWORD_SETUP_SUCCESS(response)
                self.penDelegate?.penMessage(self.penCtrl, msg)
                requestComparePasswordSDK2(finalpinNumber)
            }else {
                let msg = PenMessage.PASSWORD_SETUP_FAILURE(response)
                self.penDelegate?.penMessage(self.penCtrl, msg)
            }
        //MARK: Profile
        case .RES_PROFILE:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                N.Log("Error", data[1])
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let profile = ProfileStruct.init(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.PEN_PROFILE(profile)
            penDelegate?.penMessage(penCtrl, msg)
            
        //MARK: System
        case .RES_SYSTEM_INFO:
            // error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                N.Log("Error", data[1])
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let systemInfo = SystemInfoStruct(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.SYSTEM_INFO(systemInfo)
            penDelegate?.penMessage(penCtrl, msg)
            
        case .RES_SYSTEM_CHANGE:
            // error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                N.Log("Error", data[1])
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let systemInfo = SystemChangeStruct(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.SYSTEM_CHANGE(systemInfo)
            penDelegate?.penMessage(penCtrl, msg)
            
        //MARK: PDS (Only Sound SDK)
        case .SOUND_RES_PDS:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let psd = PDSStruct.init(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.SOUND_RES_PDS(psd)
            penDelegate?.penMessage(penCtrl, msg)
        case .SOUND_RES_OID:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let psd = ODIStruct.init(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.SOUND_RES_OID(psd)
            penDelegate?.penMessage(penCtrl, msg)
        case .SOUND_RES_STATUS:
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let psd = SoundStatusStruct.init(Array(data[pos..<pos+packetDataLength]))
            let msg = PenMessage.SOUND_RES_STATUS(psd)
            penDelegate?.penMessage(penCtrl, msg)
            
        //MARK: Log(Only Sound SDK)
        case .SOUND_RES_LOG_INFO:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                N.Log("Error", data[1], cmd)
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            let loginfo = LogInfoStruct.init(Array(data[pos..<pos+packetDataLength]))
            if(loginfo.totalLogCount > 0) {
                requestLogData(.Next)
            }else{
                let msg = PenMessage.SOUND_RES_LOG_INFO(loginfo)
                penDelegate?.penMessage(penCtrl, msg)
            }
            
        case .SOUND_RES_LOG_DATA:
            //error code
            pos += 1
            packetDataLength = Int(toUInt16(data[2],data[3]))
            if data[1] != 0 {
                N.Log("Error", data[1], cmd, data)
                return
            }
            if data.count < packetDataLength + pos {
                N.Log("Error packet length", cmd)
                return
            }
            parsingSoundLog(Array(data[pos..<pos+packetDataLength]))
            
            
        //MARK: END
        default:
            N.Log("Not implemented CMD", data[0].hexString(), cmd )
        }
    }
    
    @objc private func checkDotEnd() {
        N.Log("checkDotEnd")
    }
    
    //MARK: - Request Function
    //MARK: PenInfo
    func requestVersionInfo(_ macEncoding : [UInt8] = [UInt8](repeating: 0, count: 16)) {
        let request = REQ.VersionInfo(macEncoding)
        let data = request.toUInt8Array().toData()
        N.Log("Req version info 0x01 data")
        penCtrl.writePenSetData(data)
    }
    
    func requestPenSettingInfo() {
        let request = REQ.PenSettingInfo()
        let data = request.toUInt8Array().toData()
        N.Log("Req penState 0x04 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    //MARK: Password
    func requestComparePasswordSDK2(_ pinNumber: String) {
        finalpinNumber = pinNumber
        let request = REQ.PenPassword(pinNumber)
        let data = request.toUInt8Array().toData()
        N.Log("Req compare password 0x02 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    func requestSetPassword(_ pinNumber: String) {
        requestChangePassword(finalpinNumber,to: pinNumber)
    }
    
    func requestChangePassword(_ curNumber: String, to pinNumber: String) {
        finalpinNumber = pinNumber
        let request = REQ.ChangePenPassword(curNumber,to: pinNumber)
        let data = request.toUInt8Array().toData()
        
        N.Log("Req request Password Change 0x03 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    
    //MARK: Set PenSetting
    /// [1]
    func requestSetPenTime() {
        let timeInMiliseconds: TimeInterval = Date().timeIntervalSince1970 * 1000
        let timeStamp = Int(timeInMiliseconds)
        let request = REQ.PenStatus.init(.TimeStamp, timeStamp)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [2]
    func requestSetPenAutoPowerOffTime(_ minute: UInt16) {
        let request = REQ.PenStatus.init(.AutoPowerOffTime, minute)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [3]
    func requestSetPenCapOff(_ onoff: OnOff) {
        let request = REQ.PenStatus.init(.PenCapOff, onoff)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [4]
    func requestSetPenAutoPowerOn(_ onoff: OnOff) {
        let request = REQ.PenStatus.init(.AutoPowerOn, onoff)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [5]
    func requestSetPenBeep(_ onoff: OnOff) {
        let request = REQ.PenStatus.init(.BeepOnOff, onoff)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [6]
    func requestSetPenHover(_ onoff: OnOff) {
        let request = REQ.PenStatus.init(.HoverOnOff, onoff)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [7]
    func requestSetPenOfflineSave(_ onoff: OnOff) {
        let request = REQ.PenStatus.init(.OfflineSave, onoff)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [8]
    func requestSetPenLEDColor(_ color: LEDColor) {
        let request = REQ.PenStatus.init(.PenLEDColor, color)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [9]
    func requestSetPenFSRStep(_ pressure: UInt8){
        let request = REQ.PenStatus.init(.FSRStep,  PenSettingStruct.Sensitive(rawValue: pressure) ?? PenSettingStruct.Sensitive.Max )
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [10]
    /// [11]
    /// [12]
    func requestSetPenLocalname(_ name: String) {
        let request = REQ.PenStatus.init(.LocalName, name)
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(data)")
        penCtrl.writePenSetData(data)
    }
    /// [13]
    func requestSetPenFSCStep(_ pressure: UInt8){
        let request = REQ.PenStatus.init(.FSCStep,  PenSettingStruct.Sensitive(rawValue: pressure) ?? PenSettingStruct.Sensitive.Max )
        let data = request.toUInt8Array().toData()
        N.Log("Req setPenState 0x5 data \(request.cmd)")
        penCtrl.writePenSetData(data)
    }
    
    //MARK: Note Using
    func requestUsingAllNote() {
        let data = REQ.UsingNoteAll().toUInt8Array().toData()
        N.Log("Req set UsingNote All 0x11 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    /// Array(SectionId, OwnerId, NoteId)
    func requestUsingNote(SectionOwnerNoteList list: [(UInt8,UInt32,UInt32?)]) {
        let noteIdList = REQ.UsingNote(SectionOwnerNoteList: list)
        let data = noteIdList.toUInt8Array().toData()
        N.Log("Req set UsingNote List 0x11 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    //MARK: Offline data
    /// Offline Note List
    func requestOfflineNoteList() {
        let request = REQ.OfflineNoteList()
        let data = request.toUInt8Array().toData()
        N.Log("Req OfflineFileList2 0x21 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    /// Offline Page List
    func requestOfflinePageList(_ section: UInt8, _ owner: UInt32, _ note: UInt32) {
        let request = REQ.OfflinePageList(section, owner, note)
        let data = request.toUInt8Array().toData()
        N.Log("Req OfflinePageListSectionOwnerId 0x22 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    /// Offline note or page unit
    func requestOfflineData(_ section: UInt8, _ owner: UInt32, _ note: UInt32, _ pageList: [UInt32]?, _ deleteOnFinished: Bool) {
        let request = REQ.OfflineData(section, owner, note, pageList, deleteOnFinished)
        let data = request.toUInt8Array().toData()
        N.Log("Req OfflineData2WithOwnerId 0x23 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    /// Offline Ack after OfflineData request
    func requestOfflineDataAck(_ packetId: UInt16, _ errCode: ErrorCode, _ transOption: REQ.OfflineAckTransOP) {
        let request = REQ.OfflineDataAck(packetId, errCode, transOption)
        let data = request.toUInt8Array().toData()
        N.Log("Req response2AckToOfflineDataWithPacketID 0xA4 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    func requestDeleteOfflineData(_ section: UInt8, _ owner: UInt32, _ noteList: [UInt32]) {
        let request = REQ.DeleteOfflineData(section, owner, noteList)
        let data = request.toUInt8Array().toData()
        N.Log("Req DelOfflineFile2SectionOwnerId 0x25 data \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    
    /// Offline Parser
    func parseSDK2OfflinePenData(_ penData: [UInt8], _ offlineData: OffLineData) {
        var offlineData = offlineData
        //        N.Log("parseSDK2OfflinePenData \(offlineData)")
        var pos: Int = 0
        for _ in 0..<offlineData.nNumOfStrokes {
            var stroke = OffLineStroke(Array(penData[pos..<pos+Int(OffLineStroke.length)]))
            pos += OffLineStroke.length
            
            for _ in 0..<Int(stroke.dotCount){
                let dot =  Dot(Array(penData[pos..<pos+Int(Dot.offlineLength)]), maxForce)
                pos += Dot.offlineLength
                if dot.CalCheckSum == dot.nCheckSum{
                    stroke.dotArray.append(dot)
                }
            }
            offlineData.strokeArray.append(stroke)
        }
        
        let msg = PenMessage.OFFLINE_DATA_SEND_SUCCESS(offlineData)
        penDelegate?.penMessage(penCtrl, msg)
    }
    
    // MARK: Firmware Update
    func updateFirmwareFirst(_ data: Data, _ deviceName: String, _ fwVersion: String,_ compress: Bool) {
        var request = REQ.FWUpdateFirst()
        request.deviceName = deviceName.toUInt8Array16()
        request.fwVer = fwVersion.toUInt8Array16()
        fwFile = Array(data)
        request.fileSize = UInt32(fwFile.count)
        request.packetSize = UPDATE2_DATA_PACKET_SIZE
        request.dataZipOpt = compress ? 1: 0
        isZip = compress
        request.nCheckSum = checkSumCalculate(fwFile)
        cancelFWUpdate = false
        let data = request.toUInt8Array().toData()
        N.Log("Req UpdateFirmwareFirst 0x31 data \(request)")
        penCtrl.writePenSetData(data)
    }
    
    func updateFirmwareSecond(at fileOffset: UInt32, andStatus status: UInt8) {
        var request = REQ.FWUpdateSecond()
        
        if (fileOffset + UPDATE2_DATA_PACKET_SIZE) > UInt32(fwFile.count) {
            request.sizeBeforeZip = UInt32(UInt32(fwFile.count) - fileOffset)
        }
        else {
            request.sizeBeforeZip = UInt32(UPDATE2_DATA_PACKET_SIZE)
        }
        
        let dividedData = Array(fwFile[Int(fileOffset)..<Int(fileOffset+request.sizeBeforeZip)])
        request.nChecksum = checkSumCalculate(dividedData)
        request.fileOffset = fileOffset
        if (isZip) {
            let (zipFileData, error) = CompressUtil().zip(dividedData)
            if error != nil {
                N.Log("updateFirmwareSecond Deflate Fail", error!)
            }
            
            request.fileData = zipFileData
            request.sizeAfterZip = UInt32(zipFileData.count)
        }else{
            request.fileData = dividedData
            request.sizeAfterZip = UInt32(dividedData.count)
        }

        if status == 3 {
            request.error = 3
            N.Log("FW_UPDATE_DATA_RECEIVE_FAIL")
            let msg = PenMessage.PEN_FW_UPGRADE_FAILURE
            penDelegate?.penMessage(penCtrl, msg)
            
        }else if status == 2 {
            request.error = 0
            let msg = PenMessage.PEN_FW_UPGRADE_SUCCESS
            penDelegate?.penMessage(penCtrl, msg)
        }else {
            request.error = 0
        }
        request.length = UInt16(request.sizeAfterZip + 14)
        //0: continue, 1: stop
        if !cancelFWUpdate {
            request.transContinue = 0
        }
        else {
            request.transContinue = 1
        }
        
        let data = request.toUInt8Array().toData()
        
//        N.Log("Req updateFirmwareSecond 0xB2 data \(data)")
        //        N.Log("Req",request)
        
        penCtrl.writePenSetData(data)
    }
    
    
    
    //MARK: Profile
    func createProfile(_ proFileName: String , _ password: [UInt8]) throws {
        let request = REQ.Profile.init(proFileName, password, 32, 8)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 createProfile \(data)")
        penCtrl.writePenSetData(data)
        
    }
    
    func deleteProfile (_ proFileName: String, _ password: [UInt8]) throws {
        let request = REQ.Profile.init(proFileName, password)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 deleteProfile \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    func getProfileInfo (_ proFileName: String) throws {
        let request = REQ.Profile.init(proFileName)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 getProfileInfo \(data)")
        penCtrl.writePenSetData(data)
    }
    
    func writeProfileValue (_ proFileName: String, _ password: [UInt8] , _  data: [String : [UInt8]]) throws {
        let request = REQ.Profile.init(proFileName, password, data)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 writeProfileValue \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    func readProfileValue (_ proFileName: String, _ keys: [String] ) throws {
        let request = REQ.Profile.init(proFileName, keys)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 readProfileValue  \(data)")
        penCtrl.writePenSetData(data)
    }
    
    
    func deleteProfileValue (_ proFileName: String, _ password: [UInt8], _ keys: [String]) throws {
        let request = REQ.Profile.init(proFileName, password, keys)
        let data = request.toUInt8Array().toData()
        N.Log("Req Profile 0x41 deleteProfileValue  \(data)")
        penCtrl.writePenSetData(data)
    }
    
    //MARK: Pen System Control
    func requestSystemInfo() {
        let request = REQ.SystemInfo()
        let data = request.toUInt8Array().toData()
        N.Log("Req System Info 0x07")
        penCtrl.writePenSetData(data)
    }
    
    func requestSystemSetPerformance( _ step: PerformanceStep) {
        let request = REQ.SystemChange(.Perfomance, step.getValue())
        let data = request.toUInt8Array().toData()
        N.Log("Req System Change 0x06")
        penCtrl.writePenSetData(data)
    }
    
    
    //MARK: - Sound SDK
    func requestLogInfo(_ compressed: REQ.LogInfo.Compressed) {
        isStopLog = false
        let request = REQ.LogInfo(compressed)
        let data = request.toUInt8Array().toData()
        N.Log("Req Log Info  \(request.cmd)")
        penCtrl.writePenSetData(data)
    }
    
    func requestLogData(_ type: REQ.LogData.RequestType) {
        var request = REQ.LogData(type)
        if isStopLog {
            request = REQ.LogData(.Stop)
        }
        let data = request.toUInt8Array().toData()
        //        N.Log("Req Log Data  \(request.cmd)")
        penCtrl.writePenSetData(data)
    }
    
    func requestLogStop() {
        isStopLog = true
    }
    
    func parsingSoundLog(_ data: [UInt8]) {
        let logData = LogDataStruct.init(data)
        var requestType =  REQ.LogData.RequestType.Next
        //        N.Log("parsing Sound Data", logData)
        if logData.unZipFail {
            requestType = .Error
        } else if logData.isCheckSumError {
            if logRetryCount > 2 {
                requestType = .Error
            }else {
                requestType = .Retry
                logRetryCount += 1
            }
        } else if logData.remainLogCount == 0 {
            requestType = .End
        } else {
            requestType = .Next
            logRetryCount = 0
        }
        //        N.Log("Request Log Process", requestType)
        let msg = PenMessage.SOUND_RES_LOG_DATA(logData)
        penDelegate?.penMessage(penCtrl, msg)
        requestLogData(requestType)
    }
    
    //MARK: - DotFilter
    func penData( _ dot: Dot) {
        filter.put(dot)
    }
    
    func hoverData(_ dot: Dot) {
        self.penDelegate?.hoverData(penCtrl, dot)
    }
    
}

extension PenCommParser: FilterProtocol {
    func onFilteredDot(_ dot: Dot) {
        self.penDelegate?.penData(penCtrl, dot)
    }
}


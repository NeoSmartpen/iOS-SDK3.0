//
//  RequestStruct.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 16..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#else
#endif
protocol Request {
    func toUInt8Array() -> [UInt8]
}

struct REQ {
    struct VersionInfo: Request{
        var cmd: UInt8 = CMD.VERSION_INFO.rawValue // 0x01
        var length: UInt16 = 34 + 8
        var connectionCode: [UInt8] = [UInt8](repeating: 0, count: 16)
        // iOS 0x1001, AOS 0x1101,SDK 0x1211, Test 0xF002
        var appType: UInt16 = 0x1211
        var appVer: [UInt8] = [UInt8](repeating: 0, count: 16)
        var protocolVersion: [UInt8] = "2.18".toUInt8Array8()
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: connectionCode)
            data.append(contentsOf: appType.toUInt8Array())
            if let ver = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)?.toUInt8Array16() {
                data.append(contentsOf: ver)
            }else{
                data.append(contentsOf: appVer)
            }
            
            data.append(contentsOf: protocolVersion)
            return data
        }
        
        init (_ macEncoding : [UInt8]){
            connectionCode = macEncoding
        }
    }
    
    struct PenPassword:  Request{
        var cmd: UInt8 = CMD.COMPARE_PWD.rawValue //0x02
        var length: UInt16 = 16
        var password: [UInt8] = [UInt8](repeating: 0, count: 16)
        
        init(_ pinNumber : String) {
            password = pinNumber.toUInt8Array16()
        }
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: password)
            return data
        }
    }
    
    struct ChangePenPassword: Request {
        var cmd: UInt8 = CMD.CHANGE_PWD.rawValue //0x03
        var length: UInt16 = 33
        var usePwd: UInt8 = 1
        var oldPassword: [UInt8] = [UInt8](repeating: 0, count: 16)
        var newPassword: [UInt8] = [UInt8](repeating: 0, count: 16)
        
        init(_ curNumber: String, to pinNumber: String){
            oldPassword = curNumber.toUInt8Array16()
            newPassword = pinNumber.toUInt8Array16()
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(usePwd)
            data.append(contentsOf: oldPassword)
            data.append(contentsOf: newPassword)
            return data
        }
    }
    
    struct PenSettingInfo: Request {
        var cmd: UInt8 = CMD.PEN_STATE.rawValue//0x04
        var length: UInt16 = 0
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            return data
        }
    }
    
    struct FWUpdateSecond: Request {
        var cmd: UInt8 = CMD.RES2_FW_FILE.rawValue// 0xB2
        var error: UInt8 = 0
        var length: UInt16 = 0
        var transContinue: UInt8 = 0
        var fileOffset: UInt32 = 0
        var nChecksum: UInt8 = 0
        var sizeBeforeZip: UInt32 = 0
        var sizeAfterZip: UInt32 = 0
        var fileData: [UInt8] = []
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(error)
            data.append(contentsOf: length.toUInt8Array())
            data.append(transContinue)
            data.append(contentsOf: fileOffset.toUInt8Array())
            
            data.append(nChecksum)
            data.append(contentsOf: sizeBeforeZip.toUInt8Array())
            data.append(contentsOf: sizeAfterZip.toUInt8Array())
            data.append(contentsOf: fileData)
            return data
        }
    }
    
    public struct PenStatus: Request{
        var cmd: UInt8 = CMD.SET_PEN_STATE.rawValue// 0x05
        var length: UInt16 = 0
        var type: PenSetupType = PenSetupType.TimeStamp
        var value = [UInt8]()
        
        init(_ type: PenSetupType, _ onOff: OnOff ){
            self.type = type
            value = [onOff.rawValue]
            length = 1 + UInt16(value.count)
        }
        
        init(_ type: PenSetupType, _ sensitive: PenSettingStruct.Sensitive){
            self.type = type
            value = [sensitive.rawValue]
            length = 1 + UInt16(value.count)
        }
        
        init(_ type: PenSetupType, _ timestamp: Int){
            self.type = type
            value = timestamp.toUInt8Array()
            length = 1 + UInt16(value.count)
        }
        
        init(_ type: PenSetupType, _ minute: UInt16){
            self.type = type
            value = minute.toUInt8Array()
            length = 1 + UInt16(value.count)
            
        }
        
        init(_ type: PenSetupType, _ color: LEDColor){
            self.type = type
            value.append(0)
            value.append(contentsOf: color.toUInt8Array())
            N.Log(color.toUInt8Array())
            length = 1 + UInt16(value.count)
        }
        
        init(_ type: PenSetupType, _ localName: String){
            self.type = type
            let nameArray = localName.toUInt8Array16()
            var size: UInt8 = 0
            for m in nameArray{
                if m != 0{
                    size += 1
                }
            }
            value.append(size)
            value.append(contentsOf: nameArray)
            length = 1 + UInt16(value.count)
        }
        
        init(_ type: PenSetupType, _ FSCStep: UInt8){
            self.type = type
            value = [FSCStep]
            length = 1 + UInt16(value.count)
        }
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(type.rawValue)
            data.append(contentsOf: value)
            return data
        }
    }
    
    struct UsingNoteAll: Request{
        let cmd: UInt8 = CMD.SET_NOTE_LIST.rawValue
        let length: UInt16 = 2
        let count: UInt16 = 0xffff
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: count.toUInt8Array())
            return data
        }
    }
    
    struct UsingNote: Request {
        var cmd: UInt8 = CMD.SET_NOTE_LIST.rawValue
        var length: UInt16 = 0
        var count: UInt16 = 0
        var sectionOwnerNoteList : [UInt8] = []
        
        init(SectionOwnerNoteList list :[(UInt8,UInt32,UInt32?)]){
            count = UInt16(list.count)
            length = 2 + 8 * count
            for (section, owner, note) in list{
                let sctionOwner = toSectionOwner(section, owner)
                sectionOwnerNoteList.append(contentsOf: sctionOwner.toUInt8Array())
                if let n = note {
                    sectionOwnerNoteList.append(contentsOf: n.toUInt8Array())
                } else {
                    let allNote: [UInt8] = [0xff, 0xff, 0xff, 0xff]
                    sectionOwnerNoteList.append(contentsOf: allNote)
                }
            }
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: count.toUInt8Array())
            data.append(contentsOf: sectionOwnerNoteList)
            return data
        }
    }
    
    struct OfflineNoteList : Request{
        var cmd: UInt8 = CMD.REQ1_OFFLINE_NOTE_LIST.rawValue
        var length: UInt16 = 4
        var sectionOwnerId: UInt32 = 0xffffffff
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: sectionOwnerId.toUInt8Array())
            return data
        }
    }
    
    struct OfflinePageList: Request {
        var cmd: UInt8 = CMD.REQ2_OFFLINE_PAGE_LIST.rawValue // 0x22
        var length: UInt16 = 8
        var sectionOwnerId: UInt32 = 0
        var noteId: UInt32 = 0
        
        init(_ section : UInt8, _ owner: UInt32, _  note: UInt32){
            sectionOwnerId = toSectionOwner(section, owner)
            noteId = note
        }
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: sectionOwnerId.toUInt8Array())
            data.append(contentsOf: noteId.toUInt8Array())
            return data
        }
        
    }
    enum OfflineTransOption: UInt8{
        case NotNextTransfer = 0
        case NextAndDelete = 1
        case NextAndReserve = 2
    }
    
    enum OfflineCompress: UInt8{
        case None = 0
        case Compress = 1
    }
    
    struct OfflineData: Request {
        var cmd: UInt8 = CMD.REQ1_OFFLINE_DATA.rawValue// 0x23
        var length: UInt16 = 0
        var transOption: OfflineTransOption = OfflineTransOption.NextAndDelete
        var dataZipOption: OfflineCompress = OfflineCompress.Compress
        var sectionOwnerId: UInt32 = 0
        var noteId: UInt32 = 0
        var pageCnt: UInt32 = 0
        var pageListArray: [UInt8] = []
        init(_ section: UInt8,_ owner: UInt32,_ note: UInt32,_ pageList: [UInt32]?,  _ deleteOnFinished: Bool){
            sectionOwnerId = toSectionOwner(section, owner)
            noteId = note
            if !deleteOnFinished {
                transOption = .NextAndReserve
            }
            if let pages = pageList{
                pageCnt = UInt32(pages.count)
                length = 14 + 4 * UInt16(pageCnt)
                for page in pages{
                    pageListArray.append(contentsOf: page.toUInt8Array())
                }
            }else{
                pageCnt = 0
                length = 14
            }
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(transOption.rawValue)
            data.append(dataZipOption.rawValue)
            data.append(contentsOf: sectionOwnerId.toUInt8Array())
            data.append(contentsOf: noteId.toUInt8Array())
            data.append(contentsOf: pageCnt.toUInt8Array())
            data.append(contentsOf: pageListArray)
            return data
        }
    }
    
    enum OfflineAckTransOP: UInt8{
        case Stop = 0
        case Continue = 1
    }
    
    struct OfflineDataAck: Request {
        let cmd: UInt8 = CMD.RES2_OFFLINE_DATA.rawValue // 0xA4
        var error: ErrorCode = ErrorCode.Success
        let length: UInt16 = 3
        var packetId: UInt16 = 0
        var transOp: OfflineAckTransOP = OfflineAckTransOP.Continue
        
        init(_ packetId: UInt16, _ errCode: ErrorCode, _ transOption: OfflineAckTransOP){
            self.packetId = packetId
            error = errCode
            transOp = transOption
        }
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(error.rawValue)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: packetId.toUInt8Array())
            data.append(transOp.rawValue)
            return data
        }
        
    }
    struct DeleteOfflineData: Request {
        var cmd: UInt8 = CMD.REQ_DEL_OFFLINE_DATA.rawValue//0x25
        var length: UInt16 = 0
        var sectionOwnerId: UInt32 = 0
        var noteCnt: UInt8 = 0
        var noteListArray: [UInt8] = []
        
        init(_ section: UInt8,_ owner: UInt32,_ noteList: [UInt32]){
            noteCnt = UInt8(noteList.count)
            length = 5 + (UInt16(noteCnt) * 4)
            sectionOwnerId = toSectionOwner(section, owner)
            for note in noteList{
                self.noteListArray.append(contentsOf: note.toUInt8Array())
            }
        }
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: sectionOwnerId.toUInt8Array())
            data.append(noteCnt)
            data.append(contentsOf: noteListArray)
            return data
        }
    }
    
    struct FWUpdateFirst: Request {
        var cmd: UInt8 = CMD.REQ1_FW_FILE.rawValue // 0x31
        var length: UInt16 = 42
        var deviceName: [UInt8] = [UInt8](repeating: 0, count: 16)
        var fwVer: [UInt8] = [UInt8](repeating: 0, count: 16)
        var fileSize: UInt32 = 0
        var packetSize: UInt32 = 0
        var dataZipOpt: UInt8 = 0
        var nCheckSum: UInt8 = 0
        
        func toUInt8Array() -> [UInt8]{
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: deviceName)
            data.append(contentsOf: fwVer)
            data.append(contentsOf: fileSize.toUInt8Array())
            data.append(contentsOf: packetSize.toUInt8Array())
            data.append(dataZipOpt)
            data.append(nCheckSum)
            
            return data
        }
    }

    
    struct Profile: Request {
        var cmd: UInt8 = CMD.REQ_PROFILE.rawValue // 0x41
        var length: UInt16 = 0
        var name: String = ""
        var type: ProfileType = ProfileType.Info
        var profileData: [UInt8] = []
        
        /// Create
        init(_ name: String, _ password: [UInt8], _ size: UInt16, _ count: UInt16){
            type = .Create
            length = 21
            self.name = name
            
            profileData.append(contentsOf: password)
            profileData.append(contentsOf: size.toUInt8Array())
            profileData.append(contentsOf: count.toUInt8Array())
        }
        
        /// Delete
        init(_ name: String, _ password: [UInt8]) {
            type = .Delete
            length = 17
            self.name = name
            
            profileData.append(contentsOf: password)
        }
        
        /// Info
        init(_ name: String) {
            type = .Info
            length = 9
            self.name = name
        }
        
        /// KeyWrite
        init(_ name: String, _ password: [UInt8], _ keyvalue: [String: [UInt8]] ) {
            type = .KeyWrite
            length = 9 + 9
            self.name = name

            profileData.append(contentsOf: password)
            let count : UInt8 = UInt8(keyvalue.count)
            profileData.append(count)
            for (k, v) in keyvalue {
                let key = k.toUInt8Array16()
                let value = v
                length += 18

                let dataLength = UInt16(value.count)
                length += dataLength
                
                profileData.append(contentsOf: key)
                profileData.append(contentsOf: dataLength.toUInt8Array())
                profileData.append(contentsOf: value)
            }

        }
        
        /// KeyRead
        init(_ name: String, _ keys: [String]){
            type = .KeyRead
            length = 10
            self.name = name

            let count : UInt8 = UInt8(keys.count)
            profileData.append(count)

            for k in keys {
                length += 16
                profileData.append(contentsOf: k.toUInt8Array16())
            }
        }
        
        /// KeyDelete
        init(_ name: String, _ password: [UInt8], _ keys: [String]) {
            type = .KeyDelete
            length = 18
            self.name = name

            profileData.append(contentsOf: password)

            let count : UInt8 = UInt8(keys.count)
            profileData.append(count)
            
            for k in keys {
                length += 16
                profileData.append(contentsOf: k.toUInt8Array16())
            }
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(contentsOf: name.toUInt8Array8())
            data.append(type.rawValue)
            data.append(contentsOf: profileData)
            return data
        }

    }
    
    struct SystemInfo: Request {
        var cmd: UInt8 = CMD.REQ_SYSTEM_INFO.rawValue // 0x07
        var length: UInt16 = 0
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            return data
        }
    }
    
    struct SystemChange: Request {
        var cmd: UInt8 = CMD.REQ_SYSTEM_CHANGE.rawValue // 0x06
        var length: UInt16 = 1
        var type: SystmeType = .Perfomance
        var value: [UInt8] = []
        
        init( _ type: SystmeType, _ value: [UInt8]) {
            self.type = type
            self.value = value
            self.length = UInt16(value.count + 1)
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(type.rawValue)
            data.append(contentsOf: value)
            return data
        }
    }
    
    struct LogInfo: Request {
        var cmd : UInt8 = CMD.SOUND_REQ_LOG_INFO.rawValue // 0x74
        var length: UInt16 = 1
        var compress: Compressed = .Compressed
        
        public enum Compressed: UInt8 {
            case Normal = 0
            case Compressed = 1
        }
        
        init(_ compressed: Compressed) {
            compress = compressed
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(compress.rawValue)
            return data
        }
    }
    
    struct LogData: Request {

        var cmd : UInt8 = CMD.SOUND_REQ_LOG_DATA.rawValue // 0x75
        var length: UInt16 = 1
        var requestType: RequestType = .Error
        
        public enum RequestType: UInt8 {
            case Next = 0
            case Retry = 1
            case End = 2
            case Error = 3
            case Stop = 4
        }
        
        init(_ type: RequestType) {
            requestType = type
        }
        
        func toUInt8Array() -> [UInt8] {
            var data = [UInt8]()
            data.append(cmd)
            data.append(contentsOf: length.toUInt8Array())
            data.append(requestType.rawValue)
            return data
        }
    }
}


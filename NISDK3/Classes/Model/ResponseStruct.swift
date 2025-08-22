//
//  ResponseStruct.swift
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
protocol Response {
    var isValid: Bool {get}
}


/// full dotData, 0x65, 0x6C
public struct Dot: Response {
    var isValid: Bool = false
    
    ///Time gap between dots (millisecond)
    public var nTimeDelta: UInt8 = 0
    /// 0 ~ 1.0
    public var force: Float = 0
    /// dot code X
    public var x: Float = 0
    /// dot code Y
    public var y: Float = 0
    /// xtilt (0~180)
    public var xtilt: UInt8 = 90
    /// ytilt (0~180)
    public var ytilt: UInt8 = 90
    ///
    public var twist: UInt16 = 0
    
    //SDK Value
    /// Section, Owner, Note, Page
    public var pageInfo: PageInfo = PageInfo()
    /// penTipType
    public var penTipType: PenTipType = PenTipType.Normal
    /// penTipColor
    public var penTipColor: UIColor = UIColor.black
    /// dotType
    public var dotType: DotType = DotType.Move
    /// time millisecond tick form 1970.1.1
    public var time: Int = 0
    
    /// Event count
    public var eventcount: UInt8 = 0
    
    var reserved: [UInt8] = [UInt8](repeating: 0, count: 2)
    var nCheckSum: UInt8 = 0
    var CalCheckSum: UInt8 = 0

    static let offlineLength = 16
    /// from Pen (realTime and Offline)
    public init(_ data: [UInt8], _ maxForce: Float){
        let length = 13
        var d: [UInt8] = data
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        isValid = true
        if d.count == 14 {
            eventcount = d.removeFirst()
        }
        nTimeDelta = d[0]
        force = Float(toUInt16(d[1], d[2])) / maxForce
        x = Float(toUInt16(d[3], d[4])) + Float(d[7]) * 0.01
        y = Float(toUInt16(d[5], d[6])) + Float(d[8]) * 0.01
        xtilt = d[9]
        ytilt = d[10]
        twist = toUInt16(d[11], d[12])
        
        if d.count == Dot.offlineLength {
            reserved = [d[13],d[14]]
            nCheckSum = d[15]
            
            var ch: UInt = 0
            for i in 0..<d.count-1{
                ch += UInt(d[i])
            }
            CalCheckSum = UInt8(ch & 0xff)
        }
    }
    
    /// from Database length 16
    public init(_ dbData: [UInt8]) {
        let length = 16
        let d: [UInt8] = dbData
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        isValid = true
        nTimeDelta = d[0]
        force = toFloat(d, at: 1)
        x = toFloat(d, at: 5)
        y = toFloat(d, at: 9)
        xtilt = d[13]
        ytilt = d[14]
        twist = UInt16(d[15])
    }
    
    /// to Database length 16
    public func toUInt8Array() -> [UInt8] {
        var data = [UInt8]()
        data.append(nTimeDelta)
        data.append(contentsOf: force.toUInt8Array())
        data.append(contentsOf: x.toUInt8Array())
        data.append(contentsOf: y.toUInt8Array())
        data.append(xtilt)
        data.append(ytilt)
        
        // 2025.08.22 - to fix the crash
        data.append(contentsOf: twist.toUInt8Array())
//        data.append(UInt8(twist))
        return data
    }
    
    init(dot2 : DotStruct2){
        self.nTimeDelta = dot2.nTimeDelta
        self.x = dot2.x
        self.y = dot2.y
        
    }
    
    init(dot3 : DotStruct3){
        self.nTimeDelta = dot3.nTimeDelta
        self.x = dot3.x
        self.y = dot3.y
        
    }
    
    init(hover: DotHover) {
        self.nTimeDelta = hover.nTimeDelta
        self.x = hover.x
        self.y = hover.y
    }
    
    /// for GoogleDrive Data
    public init(){
        
    }
    
    /// dot point
    public func toPoint() -> CGPoint {
        let x: CGFloat = CGFloat(self.x)
        let y: CGFloat = CGFloat(self.y)
        return CGPoint(x: x, y: y)
    }
    
}

/// low speed, not force 0x66
struct DotStruct2 {
    var nTimeDelta: UInt8 = 0
    var x: Float = 0
    var y: Float = 0
    
    init(_ d : [UInt8]){
        let length = 7
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        nTimeDelta = d[0]
        x = Float(toUInt16(d[1], d[2])) + Float(d[5]) * 0.01
        y = Float(toUInt16(d[3], d[4])) + Float(d[6]) * 0.01
    }
}

/// section 0, low speed, not force 0x67
struct DotStruct3 {
    var nTimeDelta: UInt8 = 0
    var x: Float = 0
    var y: Float = 0
    
    init(_ d : [UInt8]){
        let length = 5
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        nTimeDelta = d[0]
        x = Float(d[1]) + Float(d[3]) * 0.01
        y = Float(d[2]) + Float(d[4]) * 0.01
    }
}

struct DotHover {
    var nTimeDelta: UInt8 = 0
    var x: Float = 0
    var y: Float = 0
    
    init(_ d : [UInt8]){
        let length = 7
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        nTimeDelta = d[0]
        x = Float(toUInt16(d[1], d[2])) + Float(d[5]) * 0.01
        y = Float(toUInt16(d[3], d[4])) + Float(d[6]) * 0.01
    }
}

/// PenUpDown Info 0x63
public struct PenUpDown {
    /// time millisecond tick form 1970.1.1
    public var time: Int = 0
    var upDown: DotType = DotType.Down
    /// Pen Tip Type: Normal(Pen) or Eraser
    public var penTipType: PenTipType = PenTipType.Normal
    /// Pen Color : Default Black
    public var penColor: UIColor = UIColor.black
    
    init(_ d : [UInt8]){
        let length = 14
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        upDown = DotType(rawValue: d[0]) ?? DotType.Down
        time = toInt64(d, at: 1)
        penTipType = PenTipType(rawValue: d[9]) ?? PenTipType.Normal
        penColor = toUInt32(d, at: 10).toUIColor()
    }
    init(){
        
    }
}

/// PenDown Info 0x69
public struct PenDown: Response {
    var isValid: Bool = false
    
    /// Event count
    public var eventcount: UInt8 = 0
    /// time millisecond tick form 1970.1.1
    public var time: Int = 0
    /// Pen Tip Type: Normal(Pen) or Eraser
    public var penTipType: PenTipType = PenTipType.Normal
    /// Pen Color : Default Black
    public var penColor: UIColor = UIColor.black
    
    init(_ d : [UInt8]){
        let length = 14
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        isValid = true
        eventcount = d[0]
        time = toInt64(d, at: 1)
        penTipType = PenTipType(rawValue: d[9]) ?? PenTipType.Normal
        penColor = toUInt32(d, at: 10).toUIColor()
    }
}

/// PenUp Info 0x6A
public struct PenUp: Response{
    var isValid: Bool = false
    
    /// Event count
    public var eventcount:    UInt8 = 0
    /// time millisecond tick form 1970.1.1
    public var time: Int = 0
    /// Dot count
    public var dotcount: UInt16 = 0
    /// total image count
    public var totalcount: UInt16 = 0
    /// process count
    public var processcount: UInt16 = 0
    /// success count
    public var successcount: UInt16 = 0
    /// send count
    public var sendcount: UInt16 = 0
    
    init(_ d : [UInt8]){
        let length = 19
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        isValid = true
        eventcount = d[0]
        time = toInt64(d, at: 1)
        dotcount = toUInt16(d, at: 9)
        totalcount = toUInt16(d, at: 11)
        processcount = toUInt16(d, at: 13)
        successcount = toUInt16(d, at: 15)
        sendcount = toUInt16(d, at: 17)
        
    }
}

/// Page Info : Owner, Section, Note, Page 0x64, 0x6B
public struct PageInfo: Response {
    var isValid: Bool = false
    /// Section
    public var section : Int = 0
    /// Owner
    public var owner: Int = 0
    /// Note(Book)
    public var note: Int = 0
    /// Page
    public var page: Int = 0
    /// Event count
    public var eventcount: UInt8 = 0
    
    public var time: Int = 0
    
    init(_ data : [UInt8]){
        let length = 12 // 0x64
        var d = data
        guard d.count >= length else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        isValid = true
        if d.count == 13 { // 0x6B
            eventcount = d.removeFirst()
        }
        section = Int(d[3])
        owner = Int(toUInt32(d, at: 0) & 0x00ffffff)
        note = Int(toUInt32(d, at: 4))
        page = Int(toUInt32(d, at: 8))
    }
    
    /// init with 0,0,0,0
    public init() {
        
    }
    /// init with page Info for google drive
    public init (_ section: Int, _ owner: Int, _ note: Int, _ page: Int = 0, _ time: Int = 0){
        self.section = section
        self.owner = owner
        self.note = note
        self.page = page
        self.time = time
    }
    
    /// compare : Owner, Section, Note, Page
    public func isEqual(_ p: PageInfo) -> Bool{
        if p.section != section {
            return false
        }
        if p.owner != owner {
            return false
        }
        if p.note != note {
            return false
        }
        if p.page != page {
            return false
        }
        return true
    }
}

// 0x62
struct POWER_OFF {
    var reason = PenPowerOffReason.None
    let cmd: CMD = CMD.EVENT_POWER_OFF
    static let length = 1
    
    init(_ d : UInt8){
        guard let offreason = PenPowerOffReason(rawValue: d) else {
            N.Log("POWER_OFF PowerOffReason Error Not Defined")
            return
        }
        self.reason = offreason
    }
}

/// level : 0 ~ 100
struct BatterAlarm {
    var level: Int = 0
    let cmd: CMD = CMD.EVENT_BATT_ALARM
    static let length = 1
    init(_ d : UInt8){
        level = Int(d)
    }
}

/// PenVerionInfo
public struct PenVersionInfo {
    ///
    public var deviceName: String = ""
    ///
    public var firmwareVersion: String = ""
    ///
    public var protocolVer: String = ""
    ///
    public var subName: String = ""
    ///
    public var deviceType : DeviceType = DeviceType.Pen
    ///
    public var mac: String = ""
    ///
    public var pressureSensorType = PressureSensorType.FSR
    
    public var isSupportCompress: Bool = false
    
    static let length = 65
    static let compressSupportProtocolVersion = 2.22
    
    init(_ d: [UInt8]){
        guard d.count >= 64 else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        deviceName = toString(Array(d[0..<16]))
        firmwareVersion = toString(Array(d[16..<32]))
        protocolVer = toString(Array(d[32..<40]))
        subName = toString(Array(d[40..<56]))
        let m = toUInt16(d[56], d[57])
        deviceType = DeviceType(rawValue: m) ?? .Pen
        mac = toString(Array(d[58..<64]))
        guard d.count >= 65 else {
            return
        }
        pressureSensorType = PressureSensorType(rawValue: d[64]) ?? .FSR
        
        
        guard let protocolVerValue = Double(protocolVer),
              d.count >= 70, protocolVerValue >= PenVersionInfo.compressSupportProtocolVersion else {
            return
        }
        isSupportCompress = d[69] == 0 ? false : true
    }
}

/// Pen Setting
public struct PenSettingStruct {
    /// if Lock, input password
    public var lock: Lock = Lock.UnLock
    /// if retrycnt over this, pen reset
    public var maxRetryCnt: UInt8 = 0
    /// wrong password count
    public var retryCnt: UInt8 = 0
    /// UTC Time tick (ms)
    public var timeTick: Int = 0
    /// power off time
    public var autoPwrOffTime: UInt16 = 0
    /// pen max pressure
    public var maxPressure: UInt16 = 0
    /// Pen Storage space in use (%)
    public var memoryUsed: UInt8 = 0
    /// Pen Cap Off
    public var usePenCapOff: OnOff = OnOff.Ignore
    /// Pen On
    public var usePenTipOnOff: OnOff = OnOff.Ignore
    /// Beef On
    public var beepOnOff: OnOff = OnOff.Ignore
    /// Hover
    public var useHover: OnOff = OnOff.Ignore
    /// Battery Charging
    public var charging : OnOff = OnOff.Off
    /// Battery Level(%)
    public var battLevel: UInt8 = 0
    /// Offline Save
    public var offlineOnOff: OnOff = OnOff.On
    /// Pen Pressure
    public var penPressure: UInt8 = 0
    /// Down Sampling data
    public var downSampling: OnOff = OnOff.On
    /// loacal name
    public var localName: String = ""
    /// NDAC Error Save Flag
    public var NDACErrorSave: OnOff = OnOff.Off
    /// System Setting
    public var usingSystemSetting: OnOff = OnOff.Off
    var reserved: [UInt8] = [UInt8](repeating: 0, count: 20)
    
    static let length = 64
    init(){
        
    }
    init(_ d: [UInt8]){
        guard d.count >= Int(PenSettingStruct.length) else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        lock = Lock.init(rawValue: d[0]) ?? .UnLock
        maxRetryCnt = d[1]
        retryCnt = d[2]
        timeTick = toInt64(d, at: 3)
        autoPwrOffTime = toUInt16(d[11], d[12])
        maxPressure = toUInt16(d[13], d[14])
        memoryUsed = d[15]
        usePenCapOff = OnOff(rawValue: d[16]) ?? .Ignore
        usePenTipOnOff = OnOff(rawValue: d[17]) ?? .Ignore
        beepOnOff = OnOff(rawValue: d[18]) ?? .Ignore
        useHover = OnOff(rawValue: d[19]) ?? .Ignore
        charging = OnOff(rawValue: (d[20] >> 7)) ?? .Ignore
        battLevel = d[20] & 0x7f
        offlineOnOff = OnOff(rawValue: d[21]) ?? .Ignore
        penPressure = d[22]
        downSampling = OnOff(rawValue: d[24]) ?? .Ignore
        localName = toString(Array(d[25..<41]))
        _ = d[41] // Not Use, Skip
        NDACErrorSave = OnOff(rawValue: d[42]) ?? .Ignore
        usingSystemSetting = OnOff(rawValue: d[43]) ?? .Ignore
        reserved = Array(d[44..<64])
    }
    
    /// Pen lock
    public enum Lock: UInt8 {
        /// unlock
        case UnLock = 0
        /// lock
        case Lock = 1
    }
    
    /// Pressure Sensitive 0(Most sensitive) ~ 4
    public enum Sensitive: UInt8 {
        /// Most sensitive
        case Max = 0
        ///
        case LV1 = 1
        ///
        case LV2 = 2
        ///
        case LV3 = 3
        ///Most Insensitive
        case LV4 = 4
    }
}


//MARK: - Offline -
public struct OfflineNoteList {
    public var notes: [Note] = []
    
    public struct Note {
        public var section: UInt8 = 0
        public var owner: UInt32 = 0
        public var note: UInt32 = 0
    }
    
    init(_ d: [UInt8]){
        guard d.count > 1 else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        var pos = 0
        let setCount = toUInt16(d[pos], d[pos+1])
        if setCount == 0 {
            return
        }
        pos += 2
        for _ in 0..<setCount {
            var note = Note()
            let secOwnerID = toUInt32(d, at: pos)
            (note.section, note.owner) = toSetionOwner(secOwnerID)
            pos += 4
            
            note.note = toUInt32(d, at: pos)
            pos += 4
            notes.append(note)
        }
    }
}

public struct OfflinePageList {
    public var section: UInt8 = 0
    public var owner: UInt32 = 0
    public var note: UInt32 = 0
    public var pages: [UInt32] = []
    
    init(_ d: [UInt8]){
        guard d.count > 1 else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        var pos = 0
        let secOwnerID = toUInt32(d, at: pos)
        (section,owner) = toSetionOwner(secOwnerID)
        pos += 4
        note = toUInt32(d, at: pos) // NoteID
        pos += 4
        
        let pageCount = toUInt16(d[pos], d[pos+1])
        pos += 2
        
        for _ in 0..<pageCount {
            let pageId = toUInt32(d, at: pos)
            pages.append(pageId)
            pos += 4
        }
    }
}


struct OfflineInfo {
    var strokeCount: UInt32 = 0
    var dataSize: UInt32 = 0 // UnCompressed strokeData + DotData
    var isZip: UInt8 = 0
    
    static let length = 9
    init(_ d: [UInt8]){
        guard d.count >= Int(OfflineInfo.length) else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        strokeCount = toUInt32(d, at: 0)
        dataSize = toUInt32(d, at: 4)
        isZip = d[8]
    }
}
enum OfflineTransPosition: UInt8 {
    case Start = 0
    case Middle = 1
    case End = 2
}

///OfflineData Header
public struct OffLineData {
    var packetId: UInt16 = 0
    var isZip: UInt8 = 0
    var sizeBeforeZip: UInt16 = 0
    var sizeAfterZip: UInt16 = 0
    var trasPosition: OfflineTransPosition = OfflineTransPosition.Start
    /// Section
    public var sectionId : UInt8 = 0
    /// Owner
    public var ownerId: UInt32 = 0
    /// Note(Book)
    public var noteId: UInt32 = 0
    /// Strokes count
    public var nNumOfStrokes: UInt16 = 0
    
    static let length = 18
    init(_ d: [UInt8]){
        guard d.count >= Int(OffLineData.length) else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        packetId = toUInt16(d[0], d[1])
        isZip = d[2]
        sizeBeforeZip = toUInt16(d[3], d[4])
        sizeAfterZip = toUInt16(d[5], d[6])
        trasPosition = OfflineTransPosition(rawValue: d[7]) ?? OfflineTransPosition.Start
        sectionId = d[11]
        ownerId = toUInt32(d, at: 8) & 0x00ffffff
        noteId = toUInt32(d, at: 12)
        nNumOfStrokes = toUInt16(d[16], d[17])
    }
    
    /// Stroke DATA
    public var strokeArray: [OffLineStroke] = []
}

///OfflineData Stroke
public struct OffLineStroke {
    /// Page
    public var pageId: UInt32 = 0
    /// Start Time
    public var downTime: Int = 0
    var upTime: Int = 0
    /// Pen Tip Type
    public var penTipType = PenTipType.Normal
    /// Pen Tip Color
    public var penTipColor = UIColor.black
    /// data count
    public var dotCount: UInt16 = 0
    /// Dot DATA
    public var dotArray: [Dot] = []
    
    static let length = 27
    init(_ d: [UInt8]){
        guard d.count >= Int(OffLineStroke.length) else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        pageId = toUInt32(d, at: 0)
        downTime = toInt64(d, at: 4)
        upTime = toInt64(d, at: 12)
        penTipType = PenTipType(rawValue: d[20]) ?? PenTipType.Normal
        penTipColor = toUInt32(d, at: 21).toUIColor()
        dotCount = toUInt16(d[25], d[26])
    }
}

//MARK: Firmware Update
struct FirmwareUpdateFirst {
    enum TransPermission: UInt8 {
        case OK = 0
        case FirmwareVersionSame = 1
        case DiskNoRoom = 2
        case Fail = 3
        case NotsupportZip = 4
    }
    var tranpermission: TransPermission
    
    init(_ d: [UInt8]){
        tranpermission = TransPermission(rawValue: d[0]) ?? .Fail
    }
}

struct FirmwareUpdateSecond {
    public enum UpdateStatus: UInt8 {
        case START
        case PROGRESSING
        case END
        case FAIL
    }
    var status: UpdateStatus
    var fileoffset : UInt32
    
    init(_ d: [UInt8]){
        status = UpdateStatus(rawValue: d[0]) ?? .FAIL
        fileoffset = toUInt32(d, at: 1)
    }
}

//MARK: Password
/// PenPasswordStruct
public struct PenPasswordStruct {
    ///
    public var status: PasswordStatus = PasswordStatus.NeedPassword
    ///
    public var retryCount: UInt8 = 0
    ///
    public var resetCount: UInt8 = 0
    
    static let length = 3
    
    init(_ retryCount: UInt8, _ resetCount: UInt8){
        self.retryCount = retryCount
        self.resetCount = retryCount
    }
    
    init(_ d: [UInt8]) {
        guard d.count >= Int(PenPasswordStruct.length) else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        status = PasswordStatus.init(rawValue: d[0]) ?? .NeedPassword
        retryCount = d[1]
        resetCount = d[2]
    }
    ///
    public enum PasswordStatus: UInt8 {
        ///
        case NeedPassword = 0
        ///
        case Success = 1
        ///
        case Reset = 2
    }
}
///
public struct PenPasswordChangeStruct {
    ///
    public var retryCount: UInt8 = 0
    ///
    public var resetCount: UInt8 = 0
}

/// Profile Struct
public struct ProfileStruct {
    public var status: ProfileStatus = ProfileStatus.Success
    /// Profile Name
    public var name: String = ""
    /// Profile type
    public var profileType: ProfileType = ProfileType.NotDefined
    /// Profile Data
    public var data: AnyObject?
    
    // length 이후 부터
    init(_ d: [UInt8]) {
        name = toString( Array(d[0..<8]))
        guard let profileType = ProfileType(rawValue: d[8]) else {
            N.Log("Profile Type Error")
            return
        }
        self.profileType = profileType
        switch self.profileType {
        case .Create:
            status = ProfileStatus(rawValue: d[9]) ?? ProfileStatus.NotDefined
        case .Delete:
            status = ProfileStatus(rawValue: d[9]) ?? ProfileStatus.NotDefined
        case .Info:
            status = ProfileStatus(rawValue: d[9]) ?? ProfileStatus.NotDefined
            data = Info.init(Array(d[10..<d.count])) as AnyObject
        case .KeyWrite:
            let tempdata = KeyWrite.init(Array(d[9..<d.count]))
            for (_, st) in tempdata.keyStatus {
                if st != .Success {
                    status = st
                }
            }
            data = tempdata as AnyObject
        case .KeyRead:
            let tempdata = KeyRead.init(Array(d[9..<d.count]))
            for st in tempdata.keyStatus {
                if st != .Success {
                    status = st
                }
            }
            data = tempdata as AnyObject
        case .KeyDelete:
            let tempdata = KeyDelete.init(Array(d[9..<d.count]))
            for (_, st) in tempdata.keyStatus {
                if st != .Success {
                    status = st
                }
            }
            data = tempdata as AnyObject
        default:
            N.Log("Not defined")
        }
    }
    /// Profile data: Info
    public struct Info {
        var sectorCount: UInt16 = 0
        var sectorSize: UInt16 = 0
        var sectorUsedCount: UInt16 = 0
        var secotrUsedKeyCount: UInt16 = 0
        
        init(_ d: [UInt8]) {
            if d.count != 8 {
                N.Log("Data Size Error: ", type(of: self))
                return
            }
            sectorCount = toUInt16(d[0], d[1])
            sectorSize = toUInt16(d[2], d[3])
            sectorUsedCount = toUInt16(d[4], d[5])
            secotrUsedKeyCount = toUInt16(d[6], d[7])
        }
    }
    
    /// Profile data: KeyWrite
    public struct KeyWrite {
        var keyCount: Int = 0
        var keyStatus : [String : ProfileStatus ]  = [:]
        init(_ d: [UInt8]) {
            keyCount = Int(d[0])
            for i in 0..<keyCount {
                let start = 1 + i * 17
                let key = toString(Array(d[start..<(start+16)]))
                let status = ProfileStatus(rawValue: d[start+16]) ?? ProfileStatus.NotDefined
                keyStatus[key] = status
            }
        }
    }
    
    /// Profile data: KeyRead
    public struct KeyRead {
        var keyCount: Int = 0
        public var keyValue: [String : [UInt8]]  = [:]
        var keyStatus: [ProfileStatus] = []
        
        init(_ d: [UInt8]) {
            keyCount = Int(d[0])
            var i = 1
            for _ in 0..<keyCount {
                let key = toString(Array(d[i..<(i+16)]))
                i += 16
                let status = ProfileStatus(rawValue: d[i]) ?? ProfileStatus.NotDefined
                keyStatus.append(status)
                i += 1
                let dataLength = Int(toUInt16(d[i], d[i+1]))
                i += 2
                let data = Array(d[i..<(i + dataLength)])
                i += dataLength
                keyValue[key] = data
            }
        }
    }
    
    /// Profile data: KeyDelete
    public struct KeyDelete {
        var keyCount: Int = 0
        var keyStatus : [String : ProfileStatus ]  = [:]
        init(_ d: [UInt8]) {
            keyCount = Int(d[0])
            for i in 0..<keyCount {
                let start = 1 + i * 17
                let key = toString(Array(d[start..<(start+16)]))
                let status = ProfileStatus(rawValue: d[start+16]) ?? ProfileStatus.NotDefined
                keyStatus[key] = status
            }
        }
    }
}

/// PDS Struct
public struct PDSStruct {
    /// Section
    public var section: Int = 0
    /// Owner
    public var owner: Int = 0
    /// Note(Book)
    public var note: Int = 0
    /// Page
    public var page: Int = 0
    /// dot code X
    public var x: Float = 0
    /// dot code Y
    public var y: Float = 0
    
    init(_ d: [UInt8]) {
        guard d.count >= 28 else{
            return
        }
        section = Int(toUInt32(d, at: 4))
        owner = Int(toUInt32(d, at: 0))
        note = Int(toUInt32(d, at: 8))
        page = Int(toUInt32(d, at: 12))
        x = Float(toUInt32(d, at: 16)) + Float(d[24]) * 0.01
        y = Float(toUInt32(d, at: 20)) + Float(d[26]) * 0.01
    }
    
    init(_ d: [UInt8], isLog: Bool = true) {
        guard d.count >= 18 else{
            return
        }
        section = Int(d[3])
        owner = Int(toUInt32(d, at: 0) & 0x00ffffff)
        note = Int(toUInt32(d, at: 4))
        page = Int(toUInt32(d, at: 8))
        x = Float(toUInt16(d, at: 12)) + Float(d[16]) * 0.01
        y = Float(toUInt16(d, at: 14)) + Float(d[17]) * 0.01
    }
    
    /// nproj scale point
    public func toPoint() -> CGPoint {
        let x: CGFloat = CGFloat(self.x)
        let y: CGFloat = CGFloat(self.y)
        return CGPoint(x: x, y: y)
    }
}

/// Sound OID Struct
public struct ODIStruct {
    /// OID
    public var OID: UInt16 = 0
    public var reserved: [UInt8] = []
    init(_ d: [UInt8]) {
        guard d.count >= 8 else{
            return
        }
        OID = toUInt16(d, at: 0)
        reserved = Array(d[2...])
    }
    
}
/// Sound Status Struct
public struct SoundStatusStruct {
    public var status: UInt8 = 0
    public var reserved: [UInt8] = []
    init(_ d: [UInt8]) {
        guard d.count >= 8 else{
            return
        }
        status = d[0]
        reserved = Array(d[1...])
    }
}

/// PDS Struct
public struct DotError: Response {
    var isValid: Bool = false
    /// Event count
    public var eventcount: UInt8 = 0
    /// Time gap between dots (millisecond)
    public var time: UInt8 = 0
    /// force
    public var force: UInt16 = 0
    /// Image Brightness
    public var brightness: UInt8 = 0
    /// Exposure Time
    public var exposuretime: UInt8 = 0
    /// NDAC Process Time
    public var processtime: UInt8 = 0
    /// Label count
    public var labelcount: UInt16 = 0
    /// NDAC Error code
    public var code: UInt8 = 0
    /// class type: [0: G3C6, 1: N3C6]
    public var classtype: UInt8 = 0xff
    /// error count
    public var errorCount: UInt8 = 0
    
    static let length = 9 // min length
    
    init(_ d: [UInt8]) {
        guard d.count >= DotError.length else{
            return
        }
        isValid = true
        if d.count > 11 {
            init0x6D(d, nil)
            return
        }
        time = d[0]
        force = toUInt16(d, at: 1)
        brightness = d[3]
        exposuretime = d[4]
        processtime = d[5]
        labelcount = toUInt16(d, at: 6)
        code = d[8]
    }
    
    mutating func init0x6D(_ d: [UInt8], _ dummy: Int?) {
        eventcount = d[0]
        time = d[1]
        force = toUInt16(d, at: 2)
        brightness = d[4]
        exposuretime = d[5]
        processtime = d[6]
        labelcount = toUInt16(d, at: 7)
        code = d[9]
        classtype = d[10]
        errorCount = d[11]
    }
    
}

/// LogInfo Struct
public struct LogInfoStruct {
    /// total log count
    public var totalLogCount: UInt16 = 0
    static let length = 2
    init(_ d: [UInt8]) {
        guard d.count >= LogInfoStruct.length else{
            return
        }
        totalLogCount = toUInt16(d, at: 0)
    }
}

public struct PacketErrorStruct{
    public enum PacketErrorType:UInt8{
        case Fail = 0x01
        case AuthorizedErr = 0x02
        case PacketLengthErr = 0x04
        case NotSupportCMD = 0x05
        case Unknown
    }
    var cmd:CMD?
    var packetErrorType:PacketErrorType = .Unknown
    
    init( _ d: [UInt8] ) {
        cmd = CMD(rawValue: d[0])
        guard d.count >= 2 else{
            return
        }
        packetErrorType = PacketErrorType(rawValue: d[1]) ?? .Unknown
    }
}

/// LogDataStruct
public struct LogDataStruct {
    public enum CompressStatus: UInt8 {
        case Normal = 0
        case Compressed = 1
        case Fail = 2
    }
    
    public enum LogSendPosition: UInt8 {
        case start = 0
        case middle = 1
        case end = 2
        case error = 3
    }
    
    public enum LogData {
        case Penstatus(PenLogStruct)
        case PDS(PDSLogStruct)
        case OID(OID2LogStruct)
    }
    /// data Compress status
    public var compress = CompressStatus.Normal
    var sizeBeforeZip: UInt16 = 0
    var sizeAfterZip: UInt16 = 0
    var checksum: UInt8 = 0
    /// Log Send Status
    public var remainLogCount: UInt16 = 0
    /// log count
    public var logcount: UInt16 = 0
    /// log data
    public var logdata: [UInt8] = []
    
    public var unZipFail = false
    
    public var isCheckSumError = false
    
    init(_ d: [UInt8]) {
        guard d.count >= 8 else{
            N.Log("Data size error", d.count )
            return
        }
        compress = CompressStatus.init(rawValue: d[0]) ?? .Fail
        sizeBeforeZip = toUInt16(d, at: 1)
        sizeAfterZip = toUInt16(d, at: 3)
        checksum = d[5]
        remainLogCount = toUInt16(d, at: 6)
        logcount = toUInt16(d, at: 8)
        logdata = Array(d[10...])
        checkSumProcess(logdata)
        if compress == .Compressed {
            let zippedData = logdata
            //            N.Log("ZipSize", zippedData.count)
            let (unZipData, error) = CompressUtil().unzip(zippedData, sizeBeforeZip)
            if error == nil {
                // GOOD
                //                N.Log("decompress success")
                logdata = unZipData
            } else {
                //                N.Log("decompress Fail")
                unZipFail = true
            }
        }
    }
    
    mutating func checkSumProcess(_ d: [UInt8]) {
        let calSum: UInt8 = checkSumCalculate(d)
        //        N.Log("ChackSum value", calSum)
        isCheckSumError = (checksum != calSum)
    }
    
    public func getLogData() -> [LogData] {
        let d = logdata
        var logList: [LogData] = []
        var ix = 0
        for _ in 0 ..< Int(logcount) {
            let type = d[ix]
            switch type {
            case 0:
                let dataSize = 12
                let penlog = PenLogStruct(Array(d[ix..<ix+dataSize]))
                ix += dataSize
                let result = LogData.Penstatus(penlog)
                logList.append(result)
            case 1:
                let dataSize = 13
                let oid = OID2LogStruct(Array(d[ix..<ix+dataSize]))
                ix += dataSize
                let result = LogData.OID(oid)
                logList.append(result)
            case 2:
                let dataSize = 29
                let pdsLog = PDSLogStruct(Array(d[ix..<ix+dataSize]))
                ix += dataSize
                let result = LogData.PDS(pdsLog)
                logList.append(result)
            default:
                print("Not implemented log data")
            }
        }
        //        N.Log("LogDataIndex", ix, d.count, logList.count)
        return logList
    }
    
    public struct PenLogStruct {
        public var type: UInt8 = 0
        public var sequenceNumber: UInt8 = 0
        public var time: Int = 0
        public var sync: UInt8 = 0
        public var status = PenAction.NotDefine
        
        init(_ d: [UInt8]) {
            type = d[0]
            sequenceNumber = d[1]
            time = toInt64(d, at: 2)
            sync = d[10]
            status = PenAction.init(rawValue: d[11]) ?? .NotDefine
        }
        
        public enum PenAction: UInt8 {
            case PowerOff = 0, PowerOn = 1, Connected = 2, Disconnected = 3
            case NotDefine = 0xff
        }
    }
    
    
    public struct OID2LogStruct {
        public var type: UInt8 = 0
        public var sequenceNumber: UInt8 = 0
        public var time: Int = 0
        public var sync: UInt8 = 0
        /// OID2 Value
        public var OID2Value: UInt16 = 0
        
        init(_ d: [UInt8]) {
            type = d[0]
            sequenceNumber = d[1]
            time = toInt64(d, at: 2)
            sync = d[10]
            OID2Value = toUInt16(d, at: 11)
        }
    }
    
    public struct PDSLogStruct {
        public var type: UInt8 = 0
        public var sequenceNumber: UInt8 = 0
        public var time: Int = 0
        public var sync: UInt8 = 0
        public var section: Int = 0
        public var owner: Int = 0
        public var note: Int = 0
        public var page: Int = 0
        public var x: Float = 0
        public var y: Float = 0
        
        init(_ d: [UInt8]) {
            type = d[0]
            sequenceNumber = d[1]
            time = toInt64(d, at: 2)
            sync = d[10]
            section = Int(d[11])
            owner = Int(toUInt32(d, at: 11) & 0x00ffffff)
            note = Int(toUInt32(d, at: 15))
            page = Int(toUInt32(d, at: 19))
            x = Float(toUInt16(d, at: 23)) + Float(d[27]) * 0.01
            y = Float(toUInt16(d, at: 25)) + Float(d[28]) * 0.01
        }
    }
}


/// System
public struct SystemInfoStruct {
    public var performanceEnable: OnOff = .Ignore
    public var performanceStep: PerformanceStep = PerformanceStep.lowFrame
    public var reserved: [UInt8] = []
    
    init(){}
    
    init(_ d: [UInt8]){
        guard d.count >= 128 else {
            N.Log("Data Size Error: ", type(of: self))
            return
        }
        performanceEnable = OnOff(rawValue: d[0]) ?? .Ignore
        performanceStep = PerformanceStep(rawValue: toUInt32(d, at: 5)) ?? .lowFrame
//        reserved = Array(d[10..<128])
    }

}

public struct SystemChangeStruct {
    public var type: UInt8 = 0
    public var status: SystemResult = .ingore

    init(){}
    
    init(_ d: [UInt8]){
        type = d[0]
        if type == 1 {
            guard d.count >= 2 else {
                N.Log("Data Size Error: SystemChange \(d.count)")
                return
            }
            status = SystemResult(rawValue: d[1]) ?? .ingore
        }
    }
}

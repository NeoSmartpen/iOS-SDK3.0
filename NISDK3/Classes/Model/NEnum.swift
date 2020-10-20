//
//  NEnum.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 2. 28..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

import Foundation

//MARK: - Response Only
/// Pen Error Code: Success, Fail, NoPermission
public enum ErrorCode: UInt8 {
    /// 0
    case Success = 0
    /// Fail
    case Fail = 1
    /// Pen No Permision
    case NoPermission = 2
}

/// 0: Down, 1: Up, 2: Move
public enum DotType: UInt8 {
    /// Pen Down
    case Down = 0
    /// Pen Up
    case Up = 1
    /// Pen Move
    case Move = 2
}

/// 0: Normal(Pen), 1: Eraser
public enum PenTipType: UInt8 {
    /// Pen
    case Normal = 0
    /// Eraser
    case Eraser = 1
}

/// Power Off Reason
public enum PenPowerOffReason: UInt8 {
    /// Power off Time
    case TimeOut = 0
    /// Law Battery
    case LowBattery = 1
    /// Firmware update
    case Update = 2
    /// Pen Power Button Off
    case PowerButton = 3
    /// Pen Cap Off
    case PenCapOff = 4
    /// Not defined Reason from Pen
    case Error = 5
    /// USB Cable Connect
    case USBIn = 6
    /// Enter wrong password 10 times
    case PassordError = 7
    /// Not defined Reason from SDK
    case None = 8
}

/// Device Type
public enum DeviceType: UInt16 {
    /// Pen
    case Pen = 0x0001
    /// Eraser
    case Eraser = 0x0002
    /// Player
    case Player = 0x0003
}

/// Pressure Sensor Type
public enum PressureSensorType: UInt8 {
    /// Force Sensitive Resistor
    case FSR = 0
    /// Force Sensitive Capacitor
    case FSC = 1
}

/// Pen Setup Event Type
public enum PenSetupType: UInt8 {
    /// Set Time Stamp
    case TimeStamp = 1
    /// Set Power off time
    case AutoPowerOffTime = 2
    /// Set power off when closing pen cap
    case PenCapOff = 3
    /// Set Power On when Pressing Pen tip or Open Pen Cap
    case AutoPowerOn = 4
    /// Pen beep on/off
    case BeepOnOff = 5
    /// Pen hover mode on/off
    case HoverOnOff = 6
    /// Offline data save or not
    case OfflineSave = 7
    /// Set pen led color
    case PenLEDColor = 8
    /// 0 ~ 4 (0 Most Sensitive)
    case FSRStep = 9
    /// USB Connect Interface : Disk or Bulk
    case USBMode = 10
    /// DownSampling on/off
    case DownSampling = 11
    /// Set Device LocalName
    case LocalName = 12
    /// 0 ~ 4 (0 Most Sensitive)
    case FSCStep = 13
    /// Not define from SDK
    case NotDefine = 255
}

/// On OFF
public enum OnOff: UInt8 {
    /// Off
    case Off = 0
    /// On
    case On = 1
    /// Ignore
    case Ignore = 9
}

/// Pen LDE Color 0 ~ 7
public enum LEDColor: Int {
    ///
    case VIOLET = 0 // "#9C3FCD"
    ///
    case BLUE = 1   // "#3c6bf0"
    ///
    case GRAY = 2   // "#bdbdbd"
    ///
    case YELLOW = 3  // "#fbcb26"
    ///
    case PINK = 4   // "#ff2084"
    ///
    case MINT = 5   // "#27e0c8"
    ///
    case RED = 6    // "#f93610"
    ///
    case BLACK = 7  // "#000000"
    
    func toUInt8Array() -> [UInt8] {
        var r: [UInt8] = [0x00, 0x00, 0x00, 0xff]
        switch self {
        case .VIOLET:
            r[2] = 0x9c; r[1] = 0x3f; r[0] = 0xcd
        case .BLUE:
            r[2] = 0x3c; r[1] = 0x6b; r[0] = 0xf0
        case .GRAY:
            r[2] = 0xbd; r[1] = 0xbd; r[0] = 0xbd
        case .YELLOW:
            r[2] = 0xfb; r[1] = 0xcb; r[0] = 0x26
        case .PINK:
            r[2] = 0xff; r[1] = 0x20; r[0] = 0x84
        case .MINT:
            r[2] = 0x27; r[1] = 0xe0; r[0] = 0xc8
        case .RED:
            r[2] = 0xf9; r[1] = 0x36; r[0] = 0x10
        case .BLACK:
            r[2] = 0x00; r[1] = 0x00; r[0] = 0x00
        }
        return r
    }
}

//MARK: - Resquest -
/// ProfileStatus
public enum ProfileStatus: UInt8 {
    ///
    case Success = 0x00
    ///
    case Fail = 0x01
    /// profile Exist
    case Exist = 0x10
    /// not defined error from pen
    case None = 0x11
    ///
    case NoKey = 0x21
    ///
    case NoPermission = 0x30
    ///
    case BufferSizeDifference = 0x40
    /// not defied error from SDK
    case NotDefined = 0x99
}

/// Profile Type
public enum ProfileType: UInt8 {
    /// data: nil
    case Create = 0x01
    /// data: nil
    case Delete = 0x02
    /// data: ProfileStruct.Info
    case Info = 0x03
    /// data: ProfileStruct.KeyWrite
    case KeyWrite = 0x11
    /// data: ProfileStruct.KeyRead
    case KeyRead = 0x12
    /// data: ProfileStruct.KeyDelete
    case KeyDelete = 0x13
    /// not defined type from SDK
    case NotDefined = 0x99
}

//MARK: - Offline Data -
///
//public enum OFFLINE_DATA_STATUS : Int {
//    ///
//    case START
//    ///
//    case PROGRESSING
//    ///
//    case END
//    ///
//    case FAIL
//}


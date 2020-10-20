//
//  Config.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 7..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth

let PACKET_START: UInt8 = 0xc0
let PACKET_END: UInt8 = 0xc1
let PACKET_DLE: UInt8 = 0x7d
let PACKET_MAX_LEN = 32000

struct NEOLAB {
    static let PEN_SERVICE_UUID = CBUUID(string :"19F1" )
    static let PEN_SERVICE_PAIRMODE_UUID = CBUUID(string :"19F0")
    static let PEN_CHARACTERISTICS_NOTIFICATION_UUID = CBUUID(string :"2BA1")
    static let PEN_CHARACTERISTICS_WRITE_UUID = CBUUID(string :"2BA0")
    
    static let PEN_SERVICE_UUID_128 = CBUUID(string: "4F99F138-9D53-5BFA-9E50-B147491AFE68")
    static let PEN_CHARACTERISTICS_NOTIFICATION_UUID_128 = CBUUID(string :"64cd86b1-2256-5aeb-9f04-2caf6c60ae57")
    static let PEN_CHARACTERISTICS_WRITE_UUID_128 = CBUUID(string :"8bc8cc7d-88ca-56b0-af9a-9bf514d0d61a")

//    static let PEN_SERVICE_UUID_128 = CBUUID(string: "3000a81c-3847-5055-bff4-422da946c360")
//    static let PEN_CHARACTERISTICS_NOTIFICATION_UUID_128 = CBUUID(string :"edb187a2-bc25-5963-b106-210f8728d1ea")
//    static let PEN_CHARACTERISTICS_WRITE_UUID_128 = CBUUID(string :"374c63b1-9390-5861-ad0e-c08549ce4d6b")
}




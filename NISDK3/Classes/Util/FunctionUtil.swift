//
//  FunctionUtil.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 16..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation


func toFloat(_ data: [UInt8], at: Int) -> Float {
    let d = Array(data[at..<at+4])
    return d.withUnsafeBytes {
        $0.baseAddress!.load(as: Float.self)
    }
}
/// little Endian: (d2, d1)
func toUInt16(_ data1: UInt8, _ data2: UInt8) -> UInt16 {
    return  UInt16(data1) + UInt16(data2) << 8
}

func toUInt16(_ data: [UInt8], at: Int) -> UInt16 {
    var value: UInt16 = UInt16(data[at])
    value += UInt16(data[at+1]) << 8
    return value
}

func toUInt32(_ data: [UInt8], at: Int) -> UInt32 {
    var value: UInt32 = UInt32(data[at])
    value += UInt32(data[at+1]) << 8
    value += UInt32(data[at+2]) << 16
    value += UInt32(data[at+3]) << 24
    return value
}

func toInt64(_ data: [UInt8], at: Int) -> Int {
    var value: Int = Int(data[at]) + Int(data[at+1]) << 8
    value  += Int(data[at+2]) << 16 + Int(data[at+3]) << 24
    value  += Int(data[at+4]) << 32 + Int(data[at+5]) << 40
    value  += Int(data[at+6]) << 48 + Int(data[at+7]) << 56
    return value
}

func toSectionOwner(_ section: UInt8, _ owner: UInt32) -> UInt32 {
    let sectionOwner: UInt32 = (UInt32(section) << 24) | owner
    return sectionOwner
}

func toSetionOwner(_ sectionOwner: UInt32) -> (section: UInt8, owner: UInt32) {
    let section: UInt8 = UInt8(sectionOwner >> 24)
    let owner : UInt32 = sectionOwner & 0x00ffffff
    return (section,owner)
}

func toString(_ data: [UInt8]) -> String {
    var validdata = [UInt8]()
    for m in data{
        if m != 0{
            validdata.append(m)
        }
    }
    var result = ""
    if let r = String(data: Data(validdata), encoding: .utf8) {
        result = r
    }
    return result
}

func makeWholePacket(_ data: [UInt8]) -> [UInt8] {
    var wholePacketData = [UInt8]()
    wholePacketData.append(PACKET_START)
    for i in 0..<data.count {
        let int_data = data[i]
        if (int_data == PACKET_START) || (int_data == PACKET_END) || (int_data == PACKET_DLE) {
            wholePacketData.append(PACKET_DLE)
            wholePacketData.append(int_data ^ 0x20)
        }
        else {
            wholePacketData.append(int_data)
        }
    }
    wholePacketData.append(PACKET_END)
    return wholePacketData
}

func toHexString(data: [UInt8]) -> String {
    var result = "["
    for d in data{
        result += d.hexString()
        result += ", "
    }
    return result
}

func checkSumCalculate(_ data: [UInt8]) -> UInt8 {
    var Sum: UInt32 = 0
    for d in data {
        Sum += UInt32(d)
    }
    return (UInt8(Sum & 0xff))
}


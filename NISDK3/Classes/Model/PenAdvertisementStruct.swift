//
//  PenAdvertisementStruct.swift
//  NISDK3
//
//  Created by Aram Moon on 09/09/2019.
//  Copyright © 2019 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct PenAdvertisementStruct: Codable {
    public var mac: String = ""
    public var subName: String = ""
    public var venderCode: Int = 0
    public var productCode: Int = 0
    public var colorCode: Int = 0
    
    init(_ advertisementData: [String: Any], _ peripheral: CBPeripheral) {
        if  let manufactureData = advertisementData["kCBAdvDataManufacturerData"]{
            mac = getMacAddr(fromString: manufactureData)
            if let code = getModelCode(manufactureData) {
                venderCode = code.v
                productCode = code.p
                colorCode = code.c
            }
        }
        
        if let localName = advertisementData["kCBAdvDataLocalName"] as? String {
            subName = localName
        }
        if subName.isEmpty, let peripheralName = peripheral.name {
            subName = peripheralName
        }
    }
    
    init(){
        
    }
    
    func getModelCode(_ data: Any) -> (v: Int, p: Int,  c: Int)? {
        if let dd = data as? Data {
            let d = [UInt8](dd)
            if d.count > 10 {
                let v = Int(toUInt16(d[7], d[8]))
                let p = Int(d[9])
                let c = Int(d[10])
                return (v, p, c)
            }
        }
        return nil
    }
    
    func getMacAddr(fromString data: Any) -> String {
        if let dd = data as? Data {
            let bytes = [UInt8](dd)
            if bytes.count > 5 {
                let d = bytes[0...5]
                let mac = d.map{String(format: "%02x", $0)}.joined()
                return mac
            }
        }
        let macAddrStr: String = String.init(describing: data)
        return macAddrStr
    }
}

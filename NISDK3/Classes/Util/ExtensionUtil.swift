//
//  ExtionsionUtil.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 16..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import UIKit

/// NeoView Framework Version String
public var NISDK_Version: String {
    get {
        var version = ""
        if let v = Bundle(for: PenController.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            version = v
        }
        return version
    }
}

extension Float {
    func toUInt8Array() -> [UInt8] {
        var value = self
        return withUnsafeBytes(of: &value) { Array($0) }
    }
}

public extension UInt16 {
    func toUInt8Array() -> [UInt8] {
        return [UInt8(self & 0xff), UInt8((self >> 8) & 0xff)]
    }
}

extension UInt32 {
    func toUInt8Array() -> [UInt8] {
        return [UInt8(self & 0xff), UInt8((self >> 8) & 0xff), UInt8((self >> 16) & 0xff), UInt8((self >> 24) & 0xff)]
    }
    
    func toUIColor() -> UIColor {
        let a = (self >> 24) & 0xff
        let r = (self >> 16) & 0xff
        let g = (self >> 8) & 0xff
        let b = self & 0xff
        let color = UIColor.init(red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255), alpha: CGFloat(a/255))
        return color
    }
}

extension UIColor {
    func toUInt8Array() -> [UInt8] {
        var result: [UInt8] = [0xff, 0x00, 0x00, 0x00]
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha){
            result[1] = UInt8(fRed * 255.0)
            result[2] = UInt8(fGreen * 255.0)
            result[3] = UInt8(fBlue * 255.0)
            result[0] = UInt8(fAlpha * 255.0)
        }
        return result
    }
}

extension Int {
    func toUInt8Array() -> [UInt8] {
        return [UInt8(self & 0xff), UInt8((self >> 8) & 0xff), UInt8((self >> 16) & 0xff), UInt8((self >> 24) & 0xff)
            , UInt8((self >> 32) & 0xff), UInt8((self >> 40) & 0xff), UInt8((self >> 48) & 0xff), UInt8((self >> 56) & 0xff)]
    }
}

extension String {
    func toUInt8Array16() -> [UInt8] {
        let array: [UInt8] = Array(self.utf8)
        var data = [UInt8](repeating: 0, count: 16)
        
        for i in 0..<16{
            if(i < array.count){
                data[i] = array[i]
            }
        }
        return data
    }
    
    func toUInt8Array8() -> [UInt8] {
        let array: [UInt8] = Array(self.utf8)
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 0..<8{
            if(i < array.count){
                data[i] = array[i]
            }
        }
        return data
    }
}

extension UInt8 {
    func hexString() -> String {
        return String(format: " 0x%02hhx", self)
    }
}

extension Data {
    func hexString() -> String {
        var i = -1
        return map {
            i += 1
            if i%4 == 0 {
                return String(format: " %02hhx", $0)
            }else{
                return String(format: "%02hhx", $0)
            }}.joined()
    }
}

protocol UInt8Type {}
extension UInt8: UInt8Type {}
extension Array where Element: UInt8Type {
    func toData() -> Data {
        return Data(makeWholePacket(self as! [UInt8]))
    }
}

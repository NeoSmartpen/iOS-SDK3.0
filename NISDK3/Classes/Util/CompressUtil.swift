//
//  CompressUtil.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 2. 2..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

import Foundation
import zlib

class CompressUtil {
    
    func Ncompress(dest: UnsafeMutablePointer<UInt8>, destLen: UnsafeMutablePointer<UInt>, source: UnsafePointer<UInt8>, sourceLen: CUnsignedLong ) -> CInt {
        let result = compress(dest, destLen, source, sourceLen)
        return result
    }
    
    func Nuncompress(dest: UnsafeMutablePointer<UInt8>, destLen: UnsafeMutablePointer<UInt>, source: UnsafePointer<UInt8>, sourceLen: CUnsignedLong ) -> CInt {
        let result = uncompress(dest, destLen, source, sourceLen)
        return result
    }
    
    func zip(_ bytes: [UInt8]) -> (data: [UInt8], error: NSError?) {
        let sourcedata = NSData.init(data: Data(bytes)).bytes.assumingMemoryBound(to: UInt8.self)
        let len = CUnsignedLong(bytes.count)
        var bufferSize: UInt = 3072
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(bufferSize))
        let result = Ncompress(dest: buffer, destLen: &bufferSize, source: sourcedata, sourceLen: len)
        let error = makeError(res: result)
        if result != 0 {
            return ([UInt8](), error)
        }

        let data = [UInt8](Data(bytes: buffer, count:Int(bufferSize)))
        return (data, error)
    }
    
    func unzip(_ bytes: [UInt8], _ beforzip: UInt16) -> (data: [UInt8] , error: NSError?) {
        let sourcedata = NSData.init(data: Data(bytes)).bytes.assumingMemoryBound(to: UInt8.self)
        let len = CUnsignedLong(bytes.count)
        var bufferSize: UInt = UInt(beforzip)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(bufferSize))
        let result = Nuncompress(dest: buffer, destLen: &bufferSize, source: sourcedata, sourceLen: len)
        let error = makeError(res: result)
        if result != 0 {
            return ([UInt8](), error)
        }
        
        let data = [UInt8](Data(bytes: buffer, count:Int(bufferSize)))
        return (data, error)
    }
    
    func makeError(res : CInt) -> NSError? {
        var err = ""
        switch res {
        case 0: return nil
        case 1: err = "stream end"
        case 2: err = "need dict"
        case -1: err = "errno"
        case -2: err = "stream error"
        case -3: err = "data error"
        case -4: err = "mem error"
        case -5: err = "buf error"
        case -6: err = "version error"
        default: err = "undefined error"
        }
        return NSError(domain: "deflateswift", code: -1, userInfo: [NSLocalizedDescriptionKey:err])
    }
}

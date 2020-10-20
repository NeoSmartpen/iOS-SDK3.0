//
//  KeyEncoder.swift
//  NISDK3
//
//  Created by Aram Moon on 2020/02/17.
//

import Foundation

public class KeyEncoder: NSObject {
    public static var encoder: ((String)->([UInt8]))?
}

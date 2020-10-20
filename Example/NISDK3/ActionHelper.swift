////
////  ActionHelper.swift
////  Sample3
////
////  Created by Aram Moon on 2018. 2. 7..
////  Copyright © 2018년 Aram Moon. All rights reserved.
////
//
//import Foundation
//import NISDK3
//import UIKit
//
//protocol SymbolActionProtocol {
//    func Event(symbol: SymbolData)
//}
//
//class ActionHelper {
//    static let shared = ActionHelper()
//    var delegate: SymbolActionProtocol?
//    init(){}
//
//    var pageInfo = PageInfo()
//    var symbolsInPage: [SymbolData]?
//    var symbolFlag = false
//
//    func symbolCheck(_ dot: Dot) {
//
//        DispatchQueue.main.sync {
//            if !pageInfo.isEqual(dot.pageInfo) {
//                self.pageInfo = dot.pageInfo
//                let s : Int = pageInfo.section
//                let o : Int  = pageInfo.owner
//                let n : Int  = pageInfo.note
//                let p : Int  = pageInfo.page
////                self.symbolsInPage = DBHelper.shared.getSymbol(UInt8(s),UInt32(o),UInt32(n),UInt32(p))
//            }
//
//            if dot.dotType == .Down {
//                self.symbolFlag = false
//                print("symbol check - dot down")
//            }
//
//            if self.symbolFlag {
//                print("symbol check - symbol flag")
//                return
//            }
//
//            guard let syms = self.symbolsInPage else {
//                return
//            }
//
//            for s in syms {
//                let rect = CGRect(x: CGFloat(s.x), y: CGFloat(s.y), width: CGFloat(s.width), height: CGFloat(s.height))
////                let rect = CGRect(x: CGFloat(73.57), y: CGFloat(9.43), width: CGFloat(s.width), height: CGFloat(s.height))
//                print("symbol check - symbol rect: \(rect)")
//                print("dot point : \(dot.toPoint())")
//                if  rect.contains(dot.toPoint()) {
//                    print("dot in rect container")
//                    self.delegate?.Event(symbol: s)
//                    self.symbolFlag = true
//                }
//            }
//        }
//    }
//}


//
//  SymbolActionHelper.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import NISDK3

protocol SymbolActionProtocol {
    func Event(symbol: SymbolData)
}

class ActionHelper {
    static let shared = ActionHelper()
    var delegate: SymbolActionProtocol?
    init(){}
    
    var pageInfo = PageInfo()
    var symbolsInPage: [SymbolData]?
    var symbolFlag = false
    var symbolData:SymbolData?
        
    let NPROJ_TO_PIXEL_SCALE: CGFloat = 600 / 72 / 56
    
    func symbolCheck(_ dots: [Dot]) {
        
        DispatchQueue.main.sync {
            for dot in dots{
                if !pageInfo.isEqual(dot.pageInfo) {
                    self.pageInfo = dot.pageInfo
                    
                    let n = pageInfo.note
                    var p = pageInfo.page
                    if p > 0{
                        p = p - 1
                    }

                    if n == 234 {
                        guard let note234Data = NProjParser.shared.getNoteData(note: .note234) else {
                            print("note234 data is nil")
                            return
                        }
                        self.symbolsInPage = note234Data.symbolList
                    } else if n == 261 {
                        guard let note261Data = NProjParser.shared.getNoteData(note: .note261) else {
                            print("note261 data is nil")
                            return
                        }
                        self.symbolsInPage = note261Data.symbolList
                    } else {
                        guard let note261Data = NProjParser.shared.getNoteData(note: .note261) else {
                            print("note261 data is nil")
                            return
                        }
                        self.symbolsInPage = note261Data.symbolList
                    }
                    
                }
                
                if dot.dotType == .Down {
                    self.symbolFlag = false
                }
                
                if self.symbolFlag {
                    return
                }
                
                guard let syms = self.symbolsInPage else {
                    return
                }
                
                for s in syms {
                    let rect = CGRect(x: (CGFloat(s.x) * NPROJ_TO_PIXEL_SCALE),
                                      y: (CGFloat(s.y) * NPROJ_TO_PIXEL_SCALE),
                                      width: CGFloat(s.width) * NPROJ_TO_PIXEL_SCALE,
                                      height: CGFloat(s.height) * NPROJ_TO_PIXEL_SCALE)
                    if  rect.contains(dot.toPoint()) {
                        self.symbolFlag = true
                        symbolData = s
                    }
                }
            }
            
        }
        if self.symbolFlag {
            if symbolData != nil{
                self.delegate?.Event(symbol: symbolData!)
            }
        }
    }
    
}

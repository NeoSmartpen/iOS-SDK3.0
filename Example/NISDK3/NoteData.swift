//
//  NoteData.swift
//  NeoView
//
//  Created by Aram Moon on 2017. 7. 17..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

/**
 NoteData from xml
 */
public struct NoteData {
    var id : String = "" // Section_Owner_note_segment ex) 5_4_1_2
    /// nproj file version
    public var version = ""
    /// note title
    public var title = ""
    /// code section
    public var section = 0
    /// code owner
    public var owner = 0
    /// code book
    public var book = 0
    /// note start Page
    public var startPage = 0
    /// note segment Index (분절 북의 경우
    public var segmentId = 0
    /// 노트 전체의 PageData List
    public var pageList: [PageData] = []
    /// 노트 전체의 SymbolData List
    public var symbolList: [SymbolData] = []
    /// paper size.
    public var paperSize: CGRect?
    
    
    init(xml : XMLIndexer) {
        if let s = xml["nproj"].element?.attribute(by: "version")?.text {
            version = s
        }
        
        if let s = xml["nproj"]["book"]["title"].element?.text {
            title = s
        }
        
        if let s = xml["nproj"]["book"]["section"].element?.text {
            section = Int(s) ?? 0
        }
        
        if let s = xml["nproj"]["book"]["owner"].element?.text {
            owner = Int(s) ?? 0
        }
        
        if let s = xml["nproj"]["book"]["code"].element?.text {
            book = Int(s) ?? 0
        }
        
        if let s = xml["nproj"]["book"]["start_page"].element?.text {
            startPage = Int(s) ?? 0
        }
        
        if let s = xml["nproj"]["book"]["segment_info"].element?.attribute(by: "current_sequence")?.text {
            segmentId = Int(s) ?? 0
        }
        
        id = "\(section)_\(owner)_\(book)_\(segmentId)"
        
        let pagesXml = xml["nproj"]["pages"]["page_item"].all
        for page in pagesXml {
            pageList.append(PageData.init(xml: page, startPage: startPage, section, owner, book ))
        }
        
        let symbolsXml = xml["nproj"]["symbols"]["symbol"].all
        for symbol in symbolsXml {
            symbolList.append(SymbolData.init(xml: symbol, section, owner, book))
        }
        
        for symbol in symbolList {
            if symbol.cmdParam == "crop_area_common"{
                paperSize = CGRect(x: CGFloat(symbol.x), y: CGFloat(symbol.y), width: CGFloat(symbol.width), height: CGFloat(symbol.height))
                break
            }
        }
    }
    
}


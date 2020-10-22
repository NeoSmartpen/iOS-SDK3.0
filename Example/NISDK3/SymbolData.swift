//
//  SymbolData.swift
//  NeoView
//
//  Created by Aram Moon on 2017. 7. 17..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import SWXMLHash
//let NPROJ_TO_PIXEL_SCALE: Float = 600 / 72 / 56
let NPROJ_TO_PIXEL_SCALE: Float = 1//600 / 72 / 56

/// Symbol data form xml or Database
public struct SymbolData{
    
    var id : String = "" // Section_Owner_note_page ex) 5_4_1_2
    /// symbole 이 속해있는 페이지
    public var page: Int = 0
    /// Ncode Page ID
    public var pageId: Int = 0
    /// Command Name Value
    public var cmdName = ""
    /// Command action value
    public var cmdAction = ""
    /// Command param value
    public var cmdParam = ""
    /// symbol top-left x coordinates
    public var x: Float = 0
    /// symbol top-left y coordinates
    public var y: Float = 0
    /// symbol width
    public var width: Float = 0
    /// symbol height
    public var height: Float = 0
    /// Symbol View init Setting(ignoredProperties in Database)
    public var checked = true
    /// UI Event Enable(ignoredProperties in Database)
    public var isEnabled = true

    init(xml : XMLIndexer, _ s: Int, _ o : Int, _ n : Int) {
        if let s = xml.element?.attribute(by: "page")?.text {
            page = Int(s) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "page_name")?.text {
            pageId = Int(s) ?? 0
        }
        
        self.id = "\(s)_\(o)_\(n)_\(self.pageId)"
        
        if let s = xml["command"].element?.attribute(by: "name")?.text {
            cmdName = s
        }
        
        if let s = xml["command"].element?.attribute(by: "action")?.text {
            cmdAction = s
        }
        
        if let s = xml["command"].element?.attribute(by: "param")?.text {
            cmdParam = s
        }
        
        if let s = xml.element?.attribute(by: "x")?.text {
            x = (Float(s ) ?? 0) * NPROJ_TO_PIXEL_SCALE
        }
        
        if let s = xml.element?.attribute(by: "y")?.text {
            y = (Float(s) ?? 0) * NPROJ_TO_PIXEL_SCALE
        }
        
        if let s = xml.element?.attribute(by: "width")?.text {
            width = (Float(s) ?? 0) * NPROJ_TO_PIXEL_SCALE
        }
        
        if let s = xml.element?.attribute(by: "height")?.text {
            height = (Float(s) ?? 0) * NPROJ_TO_PIXEL_SCALE
        }
    }
    
    init() {
        
    }
}

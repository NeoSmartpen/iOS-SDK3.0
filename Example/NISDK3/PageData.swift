//
//  PageData.swift
//  NeoView
//
//  Created by Aram Moon on 2017. 7. 17..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

/// PageData from xml
public struct PageData {
    var id : String = "" // Section_Owner_note_page ex) 5_4_1_2
    /// ncode page (page Number + Start Page)
    public var pageId: Int = 0
    /// page top-left x coordinates
    public var x1: Float = 0
    /// page top-left y coordinates
    public var y1: Float = 0
    /// page  bottom-right coordinates
    public var x2: Float = 0
    /// page bottom-right y coordinates
    public var y2: Float = 0
    /// crop_margin value left
    public var crop_margin_left: Float = 0
    /// crop_margin value right
    public var crop_margin_right: Float = 0
    /// crop_margin value top
    public var crop_margin_top: Float = 0
    /// crop_margin value bottom
    public var crop_margin_bottom: Float = 0
    /// bg_disabled value
    public var bg_disabled = false
    
    
    init(xml : XMLIndexer, startPage: Int, _ s : Int, _ o : Int, _ n : Int ) {
        if let s = xml.element?.attribute(by: "number")?.text {
            self.pageId = (Int(s) ?? 0) + startPage
        }
        self.id = "\(s)_\(o)_\(n)_\(self.pageId)"

        if let s = xml.element?.attribute(by: "x1")?.text {
            x1 = Float.init(s) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "x2")?.text {
            x2 = Float(s) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "y1")?.text {
            y1 = Float(s) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "y2")?.text {
            y2 = Float(s) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "crop_margin")?.text {
            let m = s.components(separatedBy: ",")
            guard m.count == 4 else {
                return
            }
            crop_margin_left = Float(m[0]) ?? 0
            crop_margin_right = Float(m[1]) ?? 0
            crop_margin_top = Float(m[2]) ?? 0
            crop_margin_bottom = Float(m[3]) ?? 0
        }
        
        if let s = xml.element?.attribute(by: "bg_disabled")?.text {
            bg_disabled = (s == "true")
        }
    }
}

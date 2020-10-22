//
//  ScaleHelper.swift
//  NISDK3
//
//  Created by KIM SONGBONG on 2020/02/25.
//  Copyright © 2020 KIM SONGBONG. All rights reserved.
//

import Foundation
import UIKit
import NISDK3

class ScaleHelper {
    static let shared = ScaleHelper()
    private init() { }
    
    var p = PageInfo()
    
    //Dot to Frame
    var scaleX: CGFloat = 0.011
    var scaleY: CGFloat = 0.008
    var deltaX: CGFloat = 0.06
    var deltaY: CGFloat = 0.46

    // Realtime dot
    func getPoint(_ dot: Dot,_ size: CGSize) -> CGPoint {
        setPage(dot.pageInfo)
        
        let x = CGFloat((CGFloat(dot.x)) * scaleX * size.width - self.deltaX * size.width)
        let y = CGFloat((CGFloat(dot.y)) * scaleY * size.height - self.deltaY * size.height)

        let point = CGPoint(x: x , y: y)
        return point
    }
    
    // Offline dot step1
    func setPage(_ pageInfo: PageInfo) {
        if !p.isEqual(pageInfo) {
            p = pageInfo
            
            var sampleNote:SampleSupportNote = .note261
            
            if pageInfo.note == 234 {
                sampleNote = .note234
            } else {
                sampleNote = .note261
            }
            
            guard let pageData = NProjParser.shared.getNoteData(note: sampleNote) else {
                return
            }
            
            let crop_margin_left = CGFloat(pageData.pageList[p.page].crop_margin_left)
            let crop_margin_right = CGFloat(pageData.pageList[p.page].crop_margin_right)
            let crop_margin_top = CGFloat(pageData.pageList[p.page].crop_margin_top)
            let crop_margin_bottom = CGFloat(pageData.pageList[p.page].crop_margin_bottom)
            
            let pageWidth = CGFloat(pageData.pageList[p.page].x2)
            let pageHeight = CGFloat(pageData.pageList[p.page].y2)
            
            let frame: CGRect = CGRect(x: crop_margin_left, y: crop_margin_top, width: pageWidth - (crop_margin_left + crop_margin_right), height: pageHeight - (crop_margin_top + crop_margin_bottom))
            
            let nprojToDot: CGFloat = 6.72
            
            let nprojFrame = frame
            // Frame to dotCode
            scaleX =  nprojToDot / nprojFrame.width
            scaleY =  nprojToDot / nprojFrame.height
            deltaX =  nprojFrame.origin.x / nprojFrame.width
            deltaY =  nprojFrame.origin.y / nprojFrame.height
        }
    }
}


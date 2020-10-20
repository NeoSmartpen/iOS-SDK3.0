//
//  PageSymbolView.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class PageSymbolView: UIView {
    var path :UIBezierPath = UIBezierPath()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewinit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewinit()
    }
    
    func viewinit() {
        backgroundColor = UIColor.clear
        UIGraphicsBeginImageContext(frame.size)
    }
    
    func setSymbol(_ rect: CGRect,_ symbols: [SymbolData]) {
        path.removeAllPoints()
        let scaleX = frame.width / rect.width
        let scaleY = frame.height / rect.height
        
        for s in symbols{
            
            let x = (CGFloat(s.x) - rect.origin.x) * scaleX
            let y = (CGFloat(s.y) - rect.origin.y) * scaleY
            let w = CGFloat(s.width) * scaleX
            let h = CGFloat(s.height) * scaleY
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x+w, y: y))
            path.addLine(to: CGPoint(x: x+w, y: y+h))
            path.addLine(to: CGPoint(x: x, y: y+h))
            path.addLine(to: CGPoint(x: x, y: y))
            
        }
        path.lineWidth = 3

        path.stroke()
        self.setNeedsDisplay()
    }
    
    func clearSymbols() {
        path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        let clearColor = UIColor.clear
        clearColor.setStroke()
        path.stroke()
        
    }
}

//
//  PageStrokeView.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/07.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import NISDK3

class PageStrokeView: UIView {

    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    var dotPath = UIBezierPath()
    var shapelayer: CAShapeLayer!
    var x:Double = 0.0
    var y:Double = 0.0
    var width:Double = 0.0
    var height:Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewinit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewinit()
    }
    
    func viewinit(){
        backgroundColor = UIColor.clear
        isMultipleTouchEnabled = false
        UIGraphicsBeginImageContext(frame.size)
        shapelayer = CAShapeLayer()
        shapelayer.lineWidth = 1
        shapelayer.strokeColor = UIColor.black.cgColor
        shapelayer.fillColor = UIColor.clear.cgColor
        shapelayer.lineCap = kCALineCapRound
        layer.addSublayer(shapelayer)
    }
    
    //Second Dot data
    func addDot(_ dot: Dot) {
        DispatchQueue.main.async {
            let type = dot.dotType
            let pointXY = ScaleHelper.shared.getPoint(dot, self.frame.size)
            switch type {
            case .Down:
                self.dotPath.move(to: pointXY)

            case .Move:
                self.dotPath.addLine(to: pointXY)
                self.shapelayer.path = self.dotPath.cgPath
            case .Up:
                self.dotPath.removeAllPoints()
                break
            }
        }
    }
    
    func pointCheck(dot:Dot) -> CGPoint{
        let x = ((dot.x - Float(self.x)) * (Float(self.frame.size.width) / Float(self.width)))
        let y = (dot.y - Float(self.y)) * (Float(self.frame.size.height) / Float(self.height))
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

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
    
    //HoverView
    var hoverLayer: CAShapeLayer!
    var hoverPath: UIBezierPath!
    private var hoverRadius = CGFloat(5)
    
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
        
        //HoverView
        hoverLayer = CAShapeLayer()
        layer.addSublayer(hoverLayer)
    }
    
    //Second Dot data
    func addDot(_ dot: Dot) {
        DispatchQueue.main.async {
            self.hoverLayer.removeFromSuperlayer() //remove hover when draw stroke

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
    
    //MARK: HoverView
    func addHoverLayout(_ dot: Dot) {
        DispatchQueue.main.async {
            let len = self.hoverRadius
            let currentLocation = ScaleHelper.shared.getPoint(dot, self.frame.size)
            
            let path = UIBezierPath(arcCenter: currentLocation, radius: len, startAngle: 0, endAngle: .pi * 2.0, clockwise: true)
            
            self.hoverLayer.path = path.cgPath
            self.hoverLayer.fillColor = UIColor.orange.cgColor
            self.hoverLayer.strokeColor = UIColor.yellow.cgColor
            self.hoverLayer.lineWidth = self.hoverRadius * 0.05
            self.hoverLayer.opacity = 0.6
            self.layer.addSublayer(self.hoverLayer)
            
        }
    }
}

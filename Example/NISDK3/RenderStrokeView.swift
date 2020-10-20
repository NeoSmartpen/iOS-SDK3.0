//
//  RenderStrokeView.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/09.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NISDK3
import CoreGraphics

class RenderStrokeView: UIView {
    
    var x:Double = 0
    var y:Double = 0
    var width:Double = 0
    var height:Double = 0
    
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
    }
    
    
    func setStroke(_ dots: [Dot]){
        DispatchQueue.main.async {
            self.drawStrokSimple(dots)
        }
    }
    
    //MARK: Draw Stroke
    func drawStrokSimple(_ dots: [Dot]) {
        let dotlayer = CAShapeLayer()
        let path = UIBezierPath()
        var i = 0
        for dot in dots {
            let currentLocation: CGPoint = ScaleHelper.shared.getPoint(dot, self.frame.size)
            if i == 0 {
                path.move(to: currentLocation)
            } else {
                path.addLine(to: currentLocation)
            }
            i += 1
        }
        dotlayer.path = path.cgPath
        dotlayer.lineWidth = 1
        dotlayer.strokeColor = UIColor.black.cgColor
        dotlayer.fillColor = UIColor.clear.cgColor
        dotlayer.lineCap = kCALineCapRound
        self.layer.addSublayer(dotlayer)
        self.layer.setNeedsDisplay()
    }
    public func clear(){
        if let layers = layer.sublayers{
            for l in layers{
                l.removeFromSuperlayer()
            }
        }
        setNeedsDisplay()
    }
    
    func pointCheck(dot:Dot) -> CGPoint{
        let x = (dot.x - Float(self.x)) * (Float(self.frame.size.width) / Float(self.width))
        let y = (dot.y - Float(self.y)) * (Float(self.frame.size.height) / Float(self.height))
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    func refreshView(dot:[[Dot]]){
        clear()
        for dots in dot {
            setStroke(dots)
        }
    }

}



extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}

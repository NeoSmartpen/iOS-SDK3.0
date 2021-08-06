//
//  ActivityIndicator.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ActivityIndicator: NSObject {
    
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static var label: UILabel = UILabel()
    
    static func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x:0, y:0, width:100, height:100)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x:10.0, y:0.0, width:40.0, height:40.0);
        if #available(iOS 13.0, *) {
            activityIndicator.style = UIActivityIndicatorView.Style.large
        } else {
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        }
        activityIndicator.center = CGPoint(x:loadingView.frame.size.width / 2, y:loadingView.frame.size.height / 2);
        
        label.text = "노트를 갱신중.."
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.frame = CGRect(x: 0, y: 80, width: 100, height: 20)
        
        loadingView.addSubview(label)
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    static func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    static func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

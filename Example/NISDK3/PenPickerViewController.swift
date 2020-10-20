//
//  PenPickerViewController.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/07.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NISDK3

enum SettingOption {
    case shutdownTime

    var settingArr: [Any] {
        switch self {
        case .shutdownTime:
            return minSixty()//["10분","20분","40분","60분"] //1분 부터 60분까지로 변경
        }
    }
    
    func minSixty() -> [Any]{
        var minArr = Array<Any>()
        for i in 1..<61{
            minArr.append("\(i)분")
        }
        return minArr
    }
}

class PenPickerViewController: UIViewController {

    static func instance() -> PenPickerViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PenPickerViewController") as! PenPickerViewController
        return vc
    }
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var pickerTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var settingOpt = SettingOption.shutdownTime
    var penStatus : PenSettingStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if settingOpt == .shutdownTime{
            pickerView.selectRow(Int(penStatus?.autoPwrOffTime ?? 1)-1, inComponent:0, animated:true)
        }
    }
    
    @IBAction func cancleBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        PenHelper.shared.pen?.requestPenSettingInfo()
    }
}

extension PenPickerViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingOpt.settingArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let str = "\(settingOpt.settingArr[row])"
        return str
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if settingOpt == .shutdownTime{
            PenHelper.shared.pen?.requestSetPenAutoPowerOffTime(UInt16(row+1))
        }
    }
    
}

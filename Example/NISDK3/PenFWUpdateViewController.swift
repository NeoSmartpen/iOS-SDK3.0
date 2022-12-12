//
//  PenFWUpdateViewController.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NISDK3

enum NetworkError: Error {
    case domainError
    case decodingError
    var errorStr:String{
        switch self {
        case .domainError:
            return "Wrong Domain!"
        case .decodingError:
            return "json decoding error!"
        }
    }
}
class PenFWUpdateViewController: UIViewController {
    
    static func instance() -> PenFWUpdateViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PenFWUpdateViewController") as! PenFWUpdateViewController
        return vc
    }
    @IBOutlet weak var penFWVer: UILabel!
    @IBOutlet weak var penFWLastVer: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPer: UILabel!
    @IBOutlet weak var perView: UIView!
    @IBOutlet weak var fwUpdateBtn: UIButton!
    
    var penFWVersion: String = ""
    var deviceName = ""
    var fwServerVer = ""
    var fwServerLoc = ""
    let kURL_NEOLAB_FW20: String = "http://one.neolab.kr/resource/fw20"
    let kURL_NEOLAB_FW20_JSON: String = "/firmware_all_3.json"
    // Device model [NWP-F53, NWP-F63, NWP-F151] is not support compress
    private let compressNotSupportModels: [String] = ["NWP-F53", "NWP-F63", "NWP-F151"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fwUpdateBtn.layer.borderColor = UIColor.black.cgColor
        fwUpdateBtn.layer.borderWidth = 1
        fwUpdateBtn.layer.cornerRadius = 10
        fwUpdateBtn.isEnabled = false
        fwUpdateBtn.tag = 1
        perView.isHidden = true
        progressPer.text = "0 %"
        progressView.progress = 0
        
        updatePenFWVerision()
        fetchPostPage(url: URL(string: "\(kURL_NEOLAB_FW20)\(kURL_NEOLAB_FW20_JSON)")!, completion: { [weak self] result in
            switch result {
            case .success(let dic):
                self?.fwServerLoc = dic["location"] as! String
                self?.fwServerVer = dic["version"] as! String
                DispatchQueue.main.async {
                    if (self?.penFWVersion ?? "").compare((self?.fwServerVer ?? ""),options: []).rawValue == -1{
                        self?.fwUpdateBtn.isEnabled = true
                        
                        self?.fwUpdateBtn.setTitle("Firmware update exist.", for: .normal)
                    }else{
                        self?.fwUpdateBtn.setTitle("Firmware update not exist.", for: .normal)
                    }
                    
                    self?.penFWVer.text = "Pen FW Ver : \(self?.penFWVersion ?? "")"
                    self?.penFWLastVer.text = "FW Latest Ver : \(self?.fwServerVer ?? "")"
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
        
        PenHelper.shared.penFWUpgradePerDelegate = { [weak self] per in
            DispatchQueue.main.async {
                let numberFormatter = NumberFormatter()
                numberFormatter.roundingMode = .floor         // 형식을 버림으로 지정
                if per > 10{
                    numberFormatter.minimumSignificantDigits = 3  // 자르길 원하는 자릿수
                    numberFormatter.maximumSignificantDigits = 3
                }else{
                    numberFormatter.minimumSignificantDigits = 2  // 자르길 원하는 자릿수
                    numberFormatter.maximumSignificantDigits = 2
                }
                let originalNum = per
                let newNum = numberFormatter.string(from: NSNumber(value: originalNum))
                self?.progressView.progress = (per)/100
                self?.progressPer.text = "\(newNum ?? "0") %"
                if per == 100{
                    
                }
            }
        }
        
        PenHelper.shared.fwUpdateSuccessDelegate = { [weak self] updateBool in
            if updateBool{
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Notice", message: "Firmware update finished. Please reconnect the pen.", preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { alert -> Void in
                        let  vc = self?.navigationController?.viewControllers.filter({$0 is MainViewController}).first
                        PenHelper.shared.connectDelegate?(false)
                        self?.navigationController?.popToViewController(vc!, animated: true)
                    })
                    
                    alertController.addAction(okButton)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func updatePenFWVerision() {
        guard let internalFWVersion = PenHelper.shared.pen?.requestPenVersionInfo()?.firmwareVersion else {
            return
        }
        guard let name = PenHelper.shared.pen?.requestPenVersionInfo()?.deviceName else {
            return
        }
        let array: [String] = internalFWVersion.components(separatedBy: ".")
        deviceName = name
        penFWVersion = "\(array[0]).\(array[1])"//"1.01"
    }
    
    
    func fetchPostPage(url: URL, completion: @escaping (Result<Dictionary<String, Any>,NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else {
                if let error = error as NSError?, error.domain == NSURLErrorDomain {
                    completion(.failure(.domainError))
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String : Any]
                guard let loc = ((json[self.deviceName] as! [String : Any])["COMMON"] as! [String:Any])["location"] as? String else {
                    print("Server loc is error")
                    return
                }
                guard let ver = ((json[self.deviceName] as! [String : Any])["COMMON"] as! [String:Any])["version"] as? String else  {
                    print("Server ver is error")
                    return
                }
                var dic = Dictionary<String,Any>()
                dic = ["location":loc ,"version" : ver]
                completion(.success(dic))
            } catch {
                completion(.failure(.decodingError))
            }
            
        }.resume()
        
    }
    
    func startFirmwareUpdate() {
        if self.fwServerLoc.isEmpty {
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let urlStr: String = "\(kURL_NEOLAB_FW20)\(self.fwServerLoc)"
        
        let documentsDirectoryPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL: URL = documentsDirectoryPath.appendingPathComponent("NEO1Temp.v")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Remove exist f/w success")
            } catch {
                print("Remove exist f/w fail... error: \(error)")
            }
        }
        
        let urlRequest = URLRequest(url: URL(string: urlStr)!)
        let task = session.downloadTask(with: urlRequest) { (url, response, error) in
            if let tempLocalUrl = url, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    let documentsDirectoryPath = URL(fileURLWithPath: NSTemporaryDirectory())
                    let fileURL: URL = documentsDirectoryPath.appendingPathComponent("NEO1Temp.v")
                    try FileManager.default.copyItem(at: tempLocalUrl, to: fileURL)
                    let data = try Data(contentsOf: fileURL)
                    
                    let isCompress: Bool = {
                        if self.compressNotSupportModels.contains(where: { $0 == self.deviceName }) {
                            return false
                        } else {
                            return true
                        }
                    }()
                    
                    PenHelper.shared.pen?.UpdateFirmware(data, self.deviceName, self.fwServerVer, isCompress: isCompress)
                    
                } catch (let writeError) {
                    print("error writing file : \(writeError)")
                }
                
            } else {
                print("Failure:\(String(describing: error))");
            }
        }
        task.resume()
    }
    
    @IBAction func fwUpdateBtnClicked(_ sender: UIButton) {
        if sender.tag == 1{
            self.perView.isHidden = false
            sender.setTitle("Cancel Firmware update", for: .normal)
            startFirmwareUpdate()
            sender.tag = 2
        }else{
            sender.tag = 1
            sender.setTitle("Firmware update exist.", for: .normal)
            cancelTask()
        }
    }
    
    func cancelTask() {
        PenHelper.shared.pen?.setCancelFWUpdate()
        progressView.progress = 0.0
        self.perView.isHidden = true
    }
}


//
//  PenSearchViewController.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/06.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreBluetooth
import NISDK3

class PenSearchViewController: UIViewController ,UIGestureRecognizerDelegate{

    static func instance() -> PenSearchViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PenSearchViewController") as! PenSearchViewController
        return vc
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var penSearchView: UIView!
    
    let penFinder = PenFinder.shared
    var penList:[(peripheral: CBPeripheral, penAd: PenAdvertisementStruct)] = []
    var isConnecting = false
    var autoConnecting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        penSearchView.clipsToBounds = true
        penSearchView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            penSearchView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }else{
            
        }
        
        PenHelper.shared.penAutorizedDelegate = { [weak self] (success) -> () in
            DispatchQueue.main.async {
                if let index = self?.tableView.indexPathForSelectedRow{
                    self?.tableView.deselectRow(at: index, animated: true)
                }
            }
            if (success) {
                DispatchQueue.main.async {
                    PenHelper.shared.connectDelegate?(true)
                    self?.dismiss(animated: true, completion: nil)
                }
            }else {
                DispatchQueue.main.async {
                    self?.alert()
                }
            }
        }
        penFinder.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.penList.removeAll()
            UserDefaults.standard.set(nil, forKey: "mac")
            self.penFinder.scan(10.0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        print("deinit : PenSearchViewController")
    }

    @IBAction func dismissBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func penSearchRefreshBtnClicked(_ sender: UIButton) {
        penList.removeAll()
        penFinder.scan(10.0)
    }
    
    func alert(){
        let alertController = UIAlertController(title: "Please Input Password", message: "The password is 4 digits.", preferredStyle: .alert)

            let saveAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                PenHelper.shared.pen?.requestComparePassword(firstTextField.text!)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:{ alert -> Void in
                PenHelper.shared.connectDelegate?(false)
            })
            
            saveAction.isEnabled = false

            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Input Password"
                textField.keyboardType = .numberPad
                textField.isSecureTextEntry = true
            }

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object:alertController.textFields?[0],queue: OperationQueue.main) { (notification) -> Void in
                let pw1 = alertController.textFields?[0].text
                saveAction.isEnabled = self.isPassword(pw1: pw1 ?? "")
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        
        func isPassword(pw1:String) -> Bool {
            if pw1.count == 4 {
                return true
            }
            return false
        }
}

extension PenSearchViewController: PenFinderDelegate{

    func didConnect(_ pencontroller: PenController) {
        isConnecting = false
        PenHelper.shared.setPen(pen: pencontroller)
    }
    
    func didFailToConnect(_ peripheral: CBPeripheral, _ error: Error?) {
        print("didFailToConnect", peripheral)
        if let e = error {
            print("error", e)
        }
    }
    
    func discoverPen(_ peripheral: CBPeripheral, _ pen: PenAdvertisementStruct, _ rssi: Int) {
        print(peripheral, pen)
        
        if pen.subName.isEmpty{
            return
        }
        penList.append((peripheral, pen))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didDisconnect(_ central: CBCentralManager, _ peripheral: CBPeripheral?, _ error: Error?) {
        print("Disconnected pen")
        if central.isScanning {
            print("scanning")
        } else {
            print("Scan end")
        }
        if #available(iOS 10.0, *) {
            if central.state == CBManagerState.poweredOff {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func scanStop(){
        print("scanStop")
    }
}

extension PenSearchViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return penList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PenSearchCell", for: indexPath) as! PenSearchCell
        let pen = penList[indexPath.row]
        cell.PenName.text = pen.penAd.subName
        cell.PenMac.text = pen.penAd.mac
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if isConnecting {
            return
        }
        isConnecting = true
        let mac = penList[row].penAd.mac
        UserDefaults.standard.set(mac, forKey: "mac")
        penFinder.connectPeripheral(penList[row].peripheral)
        PenHelper.shared.connectingArr.append((penList[row].peripheral, penList[row].penAd))
    }
}

//MARK: - PenSearchCell
class PenSearchCell: UITableViewCell {
    
    @IBOutlet weak var PenView:UIView!
    @IBOutlet weak var PenName:UILabel!
    @IBOutlet weak var PenMac:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        PenView.layer.borderWidth = 0.5
        PenView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

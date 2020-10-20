//
//  PenFinder.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 7. 3..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

/// Pen Search and Connect Helper Class
public class PenFinder: NSObject {
    
    /// Singleton instance
    public static let shared = PenFinder()
    
    /// PenFinderDelegate
    public var delegate: PenFinderDelegate?
    
    private var centralManager: CBCentralManager!
    
    private var timer: Timer?
    
    private var findlist: [(peripheral: CBPeripheral, penAd: PenAdvertisementStruct, rssi: Int)] = []
    
    /// Readonly Blutooth On flag
    public private(set) var bluetoothOn = false
    
    private override init(){
        super.init()
        initBluetooth()
    }
    
    //MARK: - Public Bluetooth -
    /// Scan for peripherals - specifically for our service's 128bit CBUUID
    /// if time = 0 not stop
    public func scan(_ second: CGFloat) {
//        N.Log("Scanning started")
        findlist.removeAll()
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: [NEOLAB.PEN_SERVICE_UUID, NEOLAB.PEN_SERVICE_UUID_128], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        if !second.isZero{
            startScanTimer(second)
        }
    }

    /// scan stop
    public func scanStop() {
        timer?.invalidate()
        timer = nil
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            self.delegate?.scanStop()
        }
    }
    
    /// disconnect
    public func disConnect(_ peripheral: CBPeripheral) {
        // Give some time to pen, before actual disconnect.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(500 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
            self.centralManager.cancelPeripheralConnection(peripheral)
        })
    }
    
    /**
     connect pen
     - Parameters:
        - peripheral: CBPeripheral
     - callback: PenFinderDelegate.connectpen
     */
    public func connectPeripheral(_ peripheral: CBPeripheral) {
        N.Log("Connecting to peripheral \(String(describing: peripheral))")
        centralManager.connect(peripheral, options: nil)
    }
    
    
    //MARK: - private Bluetooth -
    private func startScanTimer(_ duration: CGFloat) {
        if timer == nil {
            timer = Timer(timeInterval: TimeInterval(duration), target: self, selector: #selector(self.stopScanTimer), userInfo: nil, repeats: false)
            RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    @objc private func stopScanTimer() {
        scanStop()
    }
    
}

extension PenFinder: CBCentralManagerDelegate {
    //MARK: - Ignore It -
    /// we start the connection process
    fileprivate func initBluetooth(){
        centralManager = CBCentralManager(delegate: self, queue: (DispatchQueue(label: "kr.neolab.penBT")), options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
        
    // Central Manager State Change
    /// :nodoc:
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state{
            case CBManagerState.unauthorized:
                N.Log("This app is not authorised to use Bluetooth low energy")
            case CBManagerState.poweredOff:
                bluetoothOn = false
                self.delegate?.didDisconnect(centralManager, nil, nil)
                N.Log("Bluetooth is currently powered off.")
            case CBManagerState.poweredOn:
                bluetoothOn = true
                N.Log("Bluetooth is currently powered on and available to use.")
            default:break
            }
        } else {
            // Fallback on earlier versions
            switch central.state.rawValue {
            case 3: // CBCentralManagerState.unauthorized :
                N.Log("This app is not authorised to use Bluetooth low energy")
            case 4: // CBCentralManagerState.poweredOff:
                bluetoothOn = false
                self.delegate?.didDisconnect(centralManager, nil, nil)
                N.Log("Bluetooth is currently powered off.")
            case 5: //CBCentralManagerState.poweredOn:
                bluetoothOn = true
                N.Log("Bluetooth is currently powered on and available to use.")
            default:break
            }
        }
    }
    
    // Scanning... Discover Pen
    /// :nodoc:
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if Int(truncating: RSSI) > -15 {
            return
        }
        guard let serviceUUIDs = (advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID]) else{
            return
        }

        //펜 3초간 눌렀을때 제공되는 UUID 19F0
        if serviceUUIDs.contains(NEOLAB.PEN_SERVICE_PAIRMODE_UUID) {
//            N.Log("found service 19F0 Pairing Mode")
        }
        else if (serviceUUIDs.contains(NEOLAB.PEN_SERVICE_UUID) || serviceUUIDs.contains(NEOLAB.PEN_SERVICE_UUID_128)) {
            //                N.Log("found service 19F1 return")
            // TODO: 페어링 아닐때도 연결 가능(retun 하면 페어링모드만)
//                return
            
        } else {
            return
        }
    
        let rssi = Int(truncating: RSSI)
        let penAdvertiseMent = PenAdvertisementStruct(advertisementData)
//        N.Log(penAdvertiseMent)

        self.findlist.append((peripheral, penAdvertiseMent, rssi))
//        N.Log("Find Device", mac, subName, rssi)
        self.delegate?.discoverPen(peripheral, penAdvertiseMent, rssi)
    }
    
    // Connect Fail
    private func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) throws {
        N.Log("Failed to connect to \(peripheral). (\(String(describing: error?.localizedDescription)))")
        self.delegate?.didFailToConnect(peripheral, error)
    }
    
    // Step1: Connect -> Discover Service
    /// :nodoc:
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let pen = PenController(peripheral)
        if let scanPen = findlist.filter({$0.0 == peripheral}).first {
            pen.penAdvertisement = scanPen.penAd
            pen.macAddress = scanPen.penAd.mac
        }
        pen.centralManager = central
        self.delegate?.didConnect(pen)
    }
    /// Disconnect
    /// :nodoc:
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        N.Log("centralManager Peripheral Disconnected", error ?? "")
        self.delegate?.didDisconnect(central, peripheral, error)
    }
}

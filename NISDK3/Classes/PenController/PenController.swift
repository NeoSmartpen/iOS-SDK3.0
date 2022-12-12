//
//  PenController.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 7..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#else
#endif
/// Pen Controller (API Main Component)
public class PenController: NSObject {
    
    weak var centralManager: CBCentralManager?
    weak var penDelegate: PenDelegate?
    var penCommParser : PenCommParser!
    
    // MARK: - Public Parameters
    /// CBPeripheral
    public var peripheral: CBPeripheral?
    /// PenVerionInfo:
    //    public var penVersionInfo: PenVersionInfo?
    
    /// Pen MacAddress
    public var macAddress = ""
    public var penAdvertisement = PenAdvertisementStruct()
    //Connecte Pen
    private var verInfoTimer: Timer?
    private var penService: CBService?
    private var penCharacteristics: [CBUUID] = [NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID,NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID]
    private var penCharacteristics_128: [CBUUID] = [NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID_128,NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID_128]

    private var penSetDataCharacteristic: CBCharacteristic?
    private var supportedServices = [CBUUID]()

    // Data read(Notification) and write Queue
    private var bt_write_dispatch_queue: DispatchQueue!
    private var bt_parsing_dispach_queue: DispatchQueue!
    private var MTU = 20 //Maximum Transmission Unit
    
    // Data for App
    public var penSetting: PenSettingStruct?
        
    // MARK: - Functions
    init(_ peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        peripheral.discoverServices(supportedServices)
        let id = UUID().uuidString
        bt_write_dispatch_queue = DispatchQueue(label: "bt_write_" + id)
        bt_parsing_dispach_queue = DispatchQueue(label: "data_paser_" + id)
        
        //Protocol V2 Setting
        self.penCommParser = PenCommParser(penCommController: self)
    }
    // only Unit Test
    override init(){
        super.init()
        let id = UUID().uuidString
        bt_write_dispatch_queue = DispatchQueue(label: "bt_write_" + id)
        bt_parsing_dispach_queue = DispatchQueue(label: "data_paser_" + id)
        self.penCommParser = PenCommParser(penCommController: self)
    }
    
    /// Pen data Callback PenProtocol
    public func setPenDelegate(_ delegate: PenDelegate) {
        self.penDelegate = delegate
        self.penCommParser?.penDelegate = delegate
    }
    
    /// SDK Debug Log
    public func showSDKLog(_ flag : Bool){
        N.isDebug = flag
    }
    
    fileprivate func startTimerForVerInfoReq() {
        if verInfoTimer == nil {
            verInfoTimer = Timer(timeInterval: 0.7, target: self, selector: #selector(self.requestVersionInfo), userInfo: nil, repeats: false)
            RunLoop.main.add(verInfoTimer!, forMode: RunLoop.Mode.default)
        }
    }
    
    private func stopTimerForVerInfoReq() {
        verInfoTimer?.invalidate()
        verInfoTimer = nil
    }

    /// DisConnect Pen
    public func disConnect(){
        cleanup()
    }
    
    ///unsubscribe and disconnect
    private func cleanup() {
        N.Log("PenController cleanup")
        // Don't do anything if we're not connected
        
        defer {
            if let conn = self.peripheral {
                centralManager?.cancelPeripheralConnection(conn)
            }
        }
        
        if self.peripheral?.state != .connected {
            N.Log("peripheral disconnected")
            return
        }
        // See if we are subscribed to a characteristic on the peripheral
        guard let services = self.peripheral?.services else {
            N.Log("services Not found")
            return
        }
        
        for service in services {
            guard let characters = service.characteristics else{
                continue
            }
            for characteristic in characters {
                if characteristic.uuid.isEqual(NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID) && characteristic.isNotifying{
                    // It is notifying, so unsubscribe
                    self.peripheral?.setNotifyValue(false, for: characteristic)
                    return
                }
            }
        }
    }
    
    //MARK: - Internal API -
    /// First call at Pen Connected (Using Timer)
    /// didDiscoverCharacteristicsFor -> startTimerForVerInfoReq -> after 0.7 second
    @objc func requestVersionInfo() {
        stopTimerForVerInfoReq()
        if let encoder = KeyEncoder.encoder {
            let result = encoder(macAddress)
            penCommParser.requestVersionInfo(result)
            return
        }
        penCommParser.requestVersionInfo()
    }
    
    // MARK: - Public API
    // MARK: Password
    /// Input Password
    public func requestComparePassword(_ pinNumber: String) {
        penCommParser.requestComparePasswordSDK2(pinNumber)
    }
    /// Set Password first
    public func requestSetPassword(_ pinNumber: String) {
        penCommParser.requestSetPassword(pinNumber)
    }
    /// Change Password
    public func requestChangePassword(from curNumber: String, to pinNumber: String) {
        penCommParser.requestChangePassword(curNumber, to: pinNumber)
    }
    
    // MARK: Pen Setting Info
    /// requestPenSettingInfo
    public func requestPenSettingInfo() {
        penCommParser.requestPenSettingInfo()
    }
    
    /// Pen Version Info refer to PenVersionInfo
    public func requestPenVersionInfo() -> PenVersionInfo? {
        return penCommParser.penVersionInfo
    }
    
    // MARK: Pen Setting
    /// UTC Time
    public func requestSetPenTime() {
        penCommParser.requestSetPenTime()
    }
    
    /// Pen Power Off Time
    public func requestSetPenAutoPowerOffTime(_ minute: UInt16) {
        penCommParser.requestSetPenAutoPowerOffTime(minute)
    }
    
    /**
     PenCapOff: F50 Only
     - Parameters:
        - OnOff: on(PenCap Off Enabled)
    */
    public func requestSetPenCapOff(_ onoff: OnOff) {
        penCommParser.requestSetPenCapOff(onoff)
    }
    
    /// Pen Tip or Pen Cap On
    public func requestSetPenAutoPowerOn(_ onoff: OnOff) {
        penCommParser.requestSetPenAutoPowerOn(onoff)
    }
    
    /// Pen Beep Active
    public func requestSetPenBeep(_ onoff: OnOff) {
        penCommParser.requestSetPenBeep(onoff)
    }
    
    /// Pen Hover Mode On
    public func requestSetPenHover(_ onOff: OnOff) {
        penCommParser.requestSetPenHover(onOff)
    }
    
    /// Pen Offline Data Save On
    public func requestSetPenOfflineSave(_ onOff: OnOff) {
        penCommParser.requestSetPenOfflineSave(onOff)
    }
    
    /// Pen LED Color Set
    public func requestSetPenLEDColor(_ color: LEDColor) {
        penCommParser.requestSetPenLEDColor(color)
    }

    /// Pen Pressuer Sensor Sensitivity: 0(max) ~ 4
    public func requestSetPenPressStep(_ step: UInt8) {
        if let peninfo = penCommParser.penVersionInfo {
            if peninfo.pressureSensorType == .FSR {
                penCommParser.requestSetPenFSRStep(step)
            }else if peninfo.pressureSensorType == .FSC {
                penCommParser.requestSetPenFSCStep(step)
            }else {
                N.Log("Not support Pressure Sensor Type")
            }
        } else {
            N.Log("Not support Pressure Sensor function")
        }
    }
    
    //MARK: System Setting
    public func requestSystemInfo() {
        penCommParser.requestSystemInfo()
    }
    
    public func requestSystemSetPerformance( _ step: PerformanceStep) {
        penCommParser.requestSystemSetPerformance(step)
    }
    
    
    // MARK: - Offline Data
    /// Offline Note List
    public func requestOfflineNoteList(){
        penCommParser.requestOfflineNoteList()
    }
    
    /// Offline Page List
    public func requestOfflinePageList(_ section: UInt8,_ owner: UInt32,_ note: UInt32){
        penCommParser.requestOfflinePageList(section, owner, note)
    }
    
    /// Offline Page Data
    public func requestOfflinePage(_ section: UInt8,_ owner: UInt32,_ note: UInt32, _ page: UInt32, _ deleteOnFinished: Bool = true){
        penCommParser.requestOfflineData(section, owner, note, [page], deleteOnFinished)
    }
    
    /// Offline Note Data
    public func requestOfflineData(_ section: UInt8,_ owner: UInt32,_ note: UInt32, _ deleteOnFinished: Bool = true) {
        penCommParser.requestOfflineData(section, owner, note, nil, deleteOnFinished)
    }
    
    /// Offline Notes Data
    public func requestDeleteOfflineData(_ section: UInt8,_ owner: UInt32,_ note: [UInt32]){
        penCommParser.requestDeleteOfflineData(section, owner, note)
    }
    
    /// Offline cancel
    public func setCancelOfflineSync(_ cancelOfflineSync: Bool) {
        penCommParser.cancelOfflineSync = cancelOfflineSync
    }


    // MARK: USing Note
    /**
    Using Note. If note is nil, Using All Note
    - Parameters:
        - Tuplelist: [(Section, Owner, Note)]
     */
    public func requestUsingNote(SectionOwnerNoteList list: [(UInt8,UInt32,UInt32?)]) {
        penCommParser.requestUsingNote(SectionOwnerNoteList: list)
    }
    
    /// Using All Note
    public func requestUsingAllNote() {
        penCommParser.requestUsingAllNote()
    }
    
    // MARK: - Firmware Update
    /**
     Update Firmware.
     - Parameters:
         - fileUrl: URL
         - deviceName: String
         - fwVersion : String
     */
    public func UpdateFirmware(_ data: Data,_ deviceName: String,_ fwVersion : String, isCompress: Bool) {
        return penCommParser.updateFirmwareFirst(data, deviceName, fwVersion, isCompress)
    }
    
    /// Firemware Upate Cancel
    public func setCancelFWUpdate() {
        penCommParser.cancelFWUpdate = true
    }
    
    //MARK: - PenProfile -
    /**
     Create profile.
     - Parameters:
         - proFileName: the profile name (Under 8)
         - password:    the password (Only 8)
     - Throws: ProfileError
     */
    public func requestCreateProfile( _ proFileName: String , _ password: [UInt8]) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        if invalidPassword(password) {
            throw ProfileError.ProfilePasswordSize
        }
        do {
            try penCommParser.createProfile(proFileName, password)
        }catch let error {
            throw error
        }
    }
    
    
    /**
     Delete profile.
     - Parameters:
         - proFileName: the profile name (Under 8)
         - password:    the password (Only 8)
     - Throws: ProfileError
     */
    public func requestDeleteProfile ( _ proFileName: String, _ password: [UInt8] ) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        if invalidPassword(password) {
            throw ProfileError.ProfilePasswordSize
        }
        do {
            try penCommParser.deleteProfile(proFileName, password)
        }catch let error {
            throw error
        }
    }
    

    /**
     Gets profile info.
     - Parameters:
        - proFileName: the profile name (Under 8)
     - Throws: ProfileError
     */
    public func requestProfileInfo ( _ proFileName: String) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        do {
            try penCommParser.getProfileInfo(proFileName)
        }catch let error {
            throw error
        }
    }
    
    /**
     Write profile value.
     - Parameters:
        - proFileName: the profile name (Under 8)
        - password:    the password (Only 8)
        - keys        : the keys (Under 16)
        - data        : the data
     - Throws: ProfileError
     */
    public func requestWriteProfileValue ( _ proFileName: String, _ password: [UInt8] , _  data: [String : [UInt8]] ) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        if invalidPassword(password) {
            throw ProfileError.ProfilePasswordSize
        }
        
        if invalidKeys(Array(data.keys)) {
            throw ProfileError.ProfileKeyLimit
        }
        
        do {
            try penCommParser.writeProfileValue(proFileName,password, data)
        }catch let error {
            throw error
        }
    }
    
    /**
     Read profile value.
     - Parameters:
         - proFileName: the profile name (Under 8)
         - keys:        the keys (Under 16)
     - Throws: ProfileError
     */
    public func requestReadProfileValue ( _ proFileName: String, _ keys: [String] ) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        if invalidKeys(keys) {
            throw ProfileError.ProfileKeyLimit
        }
        do {
            try penCommParser.readProfileValue(proFileName, keys)
        }catch let error {
            throw error
        }
    }
    
    /**
    Delete profile value.
     - Parameters:
         - proFileName: the profile name (Under 8)
         - password :   the password (Only 8)
         - keys:        the keys (Under 16)
     - Throws: ProfileError
     */
    public func requestDeleteProfileValue (  _ proFileName: String, _ password: [UInt8], _ keys: [String]) throws {
        if notSupportPenProfile() {
            throw ProfileError.ProtocolNotSupported
        }
        
        if invalidName(proFileName) {
            throw ProfileError.ProfileNameLimit
        }
        
        if invalidPassword(password) {
            throw ProfileError.ProfilePasswordSize
        }
        
        if invalidKeys(keys) {
            throw ProfileError.ProfileKeyLimit
        }
        
        do {
            try penCommParser.deleteProfileValue (proFileName, password, keys)
        }catch let error {
            throw error
        }
        
    }
    
    /**
     * Is support pen profile boolean. 2.10
     */
    private func notSupportPenProfile() -> Bool {
        let SupportVersion : Float = 2.10
        if let v = penCommParser.protocolVersion {
            if v >= SupportVersion {
                return false
            }
        }
        return true
    }
    private func invalidName(_ name: String) -> Bool {
        let array: [UInt8] = Array(name.utf8)
        if array.count > 8 {
            return true
        }
        return false
    }
    
    private func invalidPassword(_ password: [UInt8]) -> Bool {
        if password.count == 8 {
            return false
        }
        return true
    }
    
    private func invalidKeys(_ keys: [String]) -> Bool {
        for k in keys {
            let array: [UInt8] = Array(k.utf8)
            if array.count > 16 {
                return true
            }
        }
        return false
    }
    
    // MARK: SOUND(TOUCH) PEN ONLY
    public func requestLogInfo() {
        penCommParser.requestLogInfo(REQ.LogInfo.Compressed.Compressed)
    }
    
    public func requestLogStop() {
        penCommParser.requestLogStop()
    }
}


extension PenController {
    //MARK: Write Data to Pen
    func writePenSetData(_ data: Data) {
        //        N.Log("Send Data",CMD(rawValue: data[1]) ?? "CMD Error")
        if data.count > MTU {
            var pos = 0
            
            let sliceCount : Int = Int(data.count / MTU)
            for _ in 0..<sliceCount {
                let sliceData = data[pos..<pos+MTU]
                pos += MTU
                bt_write_dispatch_queue.async(execute: {() -> Void in
                    if let characteristic = self.penSetDataCharacteristic {
                        self.peripheral?.writeValue(sliceData, for: characteristic, type: .withResponse)
                    }
                })
            }
            
            if data.count > MTU * sliceCount {
                let last = data[pos...]
                bt_write_dispatch_queue.async(execute: {() -> Void in
                    if let characteristic = self.penSetDataCharacteristic {
                        self.peripheral?.writeValue(last, for: characteristic, type: .withResponse)
                    }
                })
            }
            
        }else {
            bt_write_dispatch_queue.async(execute: {() -> Void in
                if let characteristic = self.penSetDataCharacteristic {
                    self.peripheral?.writeValue(data, for: characteristic, type: .withResponse)
                }
            })
        }
    }
}

// MARK: CBPeripheralDelegate
extension PenController: CBPeripheralDelegate {
    // Step1: PenFinder centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    // Step2: Discover Service -> Discover Characteristics
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            N.Log("Error discovering services: \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }
        guard peripheral.services != nil else {
            N.Log("peripheral services Error")
            return
        }
        
        for service: CBService in peripheral.services! {
            N.Log("Service UUID : \(service.uuid.uuidString)")
            if service.uuid.isEqual(NEOLAB.PEN_SERVICE_UUID){
                penService = service
                peripheral.discoverCharacteristics(penCharacteristics, for: service)
            }else if service.uuid.isEqual(NEOLAB.PEN_SERVICE_UUID_128){
                penService = service
                peripheral.discoverCharacteristics(penCharacteristics_128, for: service)
            }else{
                N.Log("Not support This Service")
            }
        }
    }

    // Step3: Discover Characteristics -> Subscribe characteristic
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any)
        if error != nil {
            N.Log("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }
        guard let characters = service.characteristics else{
            N.Log("Service Characteristics is nil")
            return
        }
        if service == penService {
            // Again, we loop through the array, just in case.
            for characteristic: CBCharacteristic in characters {
                // And check if it's the right one
                if characteristic.uuid.isEqual(NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID) {
                    N.Log("PEN_CHARACTERISTICS_NOTIFICATION_UUID",NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID);
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                else if characteristic.uuid.isEqual(NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID) {
                    N.Log("PEN_CHARACTERISTICS_WRITE_UUID",NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID);
                    penSetDataCharacteristic = characteristic
                    startTimerForVerInfoReq()
                }
                else if characteristic.uuid.isEqual(NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID_128) {
                    N.Log("PEN_CHARACTERISTICS_NOTIFICATION_UUID_128",NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID_128);
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                else if characteristic.uuid.isEqual(NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID_128) {
                    N.Log("PEN_CHARACTERISTICS_WRITE_UUID_128",NEOLAB.PEN_CHARACTERISTICS_WRITE_UUID_128);
                    penSetDataCharacteristic = characteristic
                    startTimerForVerInfoReq()
                }
                else {
                    N.Log("Unknown characteristic \(service.uuid) for service \(characteristic.uuid)")
                }
            }
        }else{
            N.Log("Not support This Service", service.uuid)
        }
    }
    
    // Step4: Subscrived...Start Read and Write
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            N.Log("Error changing notification state: \(String(describing: error?.localizedDescription)) characteristic : \(characteristic.uuid)")
        }
        // Notification has started
        if characteristic.isNotifying {
            N.Log("Notification began on \(characteristic.uuid)")
        }
        else {
            // so disconnect from the peripheral
            N.Log("Notification stopped on \(characteristic.uuid).  Disconnecting")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }

    // Step5: Read Data
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            N.Log("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        guard let received_data = characteristic.value else {
            N.Log("Data is empty")
            return
        }
        let packet = [UInt8](received_data)
//        N.Log("Pen Data", packet[1], CMD(rawValue: packet[1]))
        switch characteristic.uuid {
        case NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID:
//            N.Log("Received: pen2DataUuid data \(packet[1])", packet);
            bt_parsing_dispach_queue.async{
                self.penCommParser.parsePen2Data(packet)
            }
        case NEOLAB.PEN_CHARACTERISTICS_NOTIFICATION_UUID_128:
            //            N.Log("Received: pen2DataUuid data \(packet[1])", packet);
            bt_parsing_dispach_queue.async{
                self.penCommParser.parsePen2Data(packet)
            }
        default:
            N.Log("Not support This Notification")
        }
    }
    
    // Step5-1: Write Result
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            N.Log("Error WriteValueForCharacteristic: \(String(describing: error?.localizedDescription)) characteristic : \(characteristic.uuid)")
            return
        }
        if characteristic == penSetDataCharacteristic {
//            N.Log("Pen2.0 Data Write successful")
            if #available(iOS 9.0, *) {
                MTU = peripheral.maximumWriteValueLength(for: .withoutResponse)
//                N.Log("MTU", MTU)
            } else {
                // Fallback on earlier versions
            }
        }else{
            N.Log("Not support This Notification")
        }
    }
    
}



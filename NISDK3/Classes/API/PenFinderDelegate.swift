//
//  PenFinderDelegate.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 3. 5..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Pen Finder Callback Protocol
public protocol PenFinderDelegate {
    /// discover pen Callback
    func discoverPen(_ peripheral: CBPeripheral, _ pen: PenAdvertisementStruct, _ rssi: Int)
    /// scanEnd Callback
    func scanStop()
    /// connected Callback
    func didConnect(_ pencontroller: PenController)
    /// connected fail with peripheral
    func didFailToConnect(_ peripheral: CBPeripheral,_ error: Error?)
    /// dis connected
    func didDisconnect(_ central: CBCentralManager, _ peripheral: CBPeripheral?,_ error: Error?)
}

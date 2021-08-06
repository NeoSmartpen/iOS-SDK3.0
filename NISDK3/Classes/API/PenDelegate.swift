//
//  PenProtocol.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 7..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Receive From Device : penData & penMessage
public protocol PenDelegate: AnyObject {
    /// Pen Dot Data
    func penData(_ sender: PenController,  _ dot: Dot)
    /// Pen Message
    func penMessage(_ sender: PenController, _ msg: PenMessage)
    /// Pen Hover Data
    func hoverData(_ sender: PenController,  _ dot: Dot)
}



//
//  MacColorSupport.swift
//  Pods
//
//  Created by Aram Moon on 2020/12/11.
//
import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
public typealias UIColor = NSColor
#else
#endif

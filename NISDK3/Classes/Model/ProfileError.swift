//
//  NISDKError.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 2. 22..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

import Foundation

/// Profile Error
public enum ProfileError: Error {
    /// Pen Protocol Not Support
    case ProtocolNotSupported
    /// ProfileName Under 8 bytes
    case ProfileNameLimit
    /// Only 8 bytes
    case ProfilePasswordSize
    /// Key Under 16 bytes
    case ProfileKeyLimit
}

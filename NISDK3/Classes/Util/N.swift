//
//  Log.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 7..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation

class N {
    
    static var isDebug = true
    
    static func Log(_ items: Any... ) {
        
        if(isDebug){
            print(items)
        }
    }
}





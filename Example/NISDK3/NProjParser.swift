//
//  NprojParser.swift
//  NeoView
//
//  Created by Aram Moon on 2017. 7. 10..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//  SWXMLHash info: https://github.com/drmohundro/SWXMLHash

import Foundation
import UIKit
import SWXMLHash

/**
 nproj 파일 파서(parser).
 */

enum SampleSupportNote: String {
    case note234 = "note_234"
    case note261 = "note_261"
}
class NProjParser {
    
    /// Singleton
    static let shared = NProjParser()
    
    private init(){}
    
    /**
     Returns NoteData
     Parsing .nproj
     - Parameter data: nproj file of String type.
     */
    func pasing(_ data: String) -> NoteData? {
        let xml = SWXMLHash.parse(data)
        let noteInfo = NoteData.init(xml: xml)
        return noteInfo
    }
    
    func getNoteData(note: SampleSupportNote) -> NoteData? {
        let nprojFile = note.rawValue
        let nprojString = loadfile(nprojFile)
        
        if !nprojString.isEmpty {
            guard let note = NProjParser.shared.pasing(nprojString) else{
                print("Note Parsing Fail")
                return nil
            }
            return note
        }else {
            print("\(nprojFile) is nproj Error")
            return nil
        }
    }
    
    func loadfile(_ name: String) -> String {
        guard let filepath = Bundle.main.path(forResource: name, ofType: "nproj") else {
            print("Bundle file is nil")
            return ""
        }
        
        let url = URL.init(fileURLWithPath: filepath)
        
        do {
            let fileData = try Data.init(contentsOf: url)
            let data: String = String.init(data: fileData, encoding: .utf8)!
            return data
        } catch {
            print("fileData error")
            return ""
        }
        
    }
}



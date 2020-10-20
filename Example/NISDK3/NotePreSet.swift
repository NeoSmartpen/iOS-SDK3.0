//
//  NotePreSet.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/09.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NISDK3

enum NotePreSet{
    case note655,note601,note603
    
    func note601Data() -> Dictionary<String,Any>{
        var noteResult:[String:Any] = Dictionary<String,Any>()

        if let path = Bundle.main.path(forResource: "3_27_601", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let note = jsonResult["note"] {
                    noteResult = note as! [String : Any]
                }
            } catch {
               print(error)
            }
        }
        return noteResult
    }

    func page601Data() -> Array<Dictionary<String,Any>>{
        var pageResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_601", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let page = jsonResult["page"] as? [Dictionary<String,Any>] {
                    for i in page{
                        pageResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return pageResult
    }

    func symbol601Data() -> Array<Dictionary<String,Any>>{
        var symbolResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_601", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let symbol = jsonResult["symbol"] as? [Dictionary<String,Any>] {
                    for i in symbol{
                        symbolResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return symbolResult
    }

    func note603Data() -> Dictionary<String,Any>{
        var noteResult:[String:Any] = Dictionary<String,Any>()

        if let path = Bundle.main.path(forResource: "3_27_603", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let note = jsonResult["note"] {
                    noteResult = note as! [String : Any]
                }
            } catch {
               print(error)
            }
        }
        return noteResult
    }

    func page603Data() -> Array<Dictionary<String,Any>>{
        var pageResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_603", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let page = jsonResult["page"] as? [Dictionary<String,Any>] {
                    for i in page{
                        pageResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return pageResult
    }

    func symbol603Data() -> Array<Dictionary<String,Any>>{
        var symbolResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_603", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let symbol = jsonResult["symbol"] as? [Dictionary<String,Any>] {
                    for i in symbol{
                        symbolResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return symbolResult
    }

    func note655Data() -> Dictionary<String,Any>{
        var noteResult:[String:Any] = Dictionary<String,Any>()

        if let path = Bundle.main.path(forResource: "3_27_655", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let note = jsonResult["note"] {
                    noteResult = note as! [String : Any]
                }
            } catch {
               print(error)
            }
        }
        return noteResult
    }

    func page655Data() -> Array<Dictionary<String,Any>>{
        var pageResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_655", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let page = jsonResult["page"] as? [Dictionary<String,Any>] {
                    for i in page{
                        pageResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return pageResult
    }

    func symbol655Data() -> Array<Dictionary<String,Any>>{
        var symbolResult:Array = Array<Dictionary<String,Any>>()
        if let path = Bundle.main.path(forResource: "3_27_655", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let symbol = jsonResult["symbol"] as? [Dictionary<String,Any>] {
                    for i in symbol{
                        symbolResult.append(i)
                    }
                }
            } catch {
               print(error)
            }
        }
        return symbolResult
    }

    var noteArr:[String:Any]{
        switch self {
        case .note601:
            return note601Data()
        case .note603:
            return note603Data()
        case .note655:
            return note655Data()
        }
    }

    var pageArr:Array<Dictionary<String,Any>>{
        switch self {
        case .note601:
            return page601Data()
        case .note603:
            return page603Data()
        case .note655:
            return page655Data()
        }
    }

    var symbolArr:Array<Dictionary<String,Any>>{
        switch self {
        case .note601:
            return symbol601Data()
        case .note603:
            return symbol603Data()
        case .note655:
            return symbol655Data()
        }
    }
}

//
//  MainViewController.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/06.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreBluetooth
import NISDK3

class MainViewController: UIViewController {
    
    static func instance() -> MainViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        return vc
    }

    @IBOutlet weak var pencilConBtn: UIBarButtonItem!
    @IBOutlet weak var pencilSetBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noteCover: UIImageView!
    
    var centralManager: CBCentralManager!
    var drawingView : UIView!
    var pageStrokeView : PageStrokeView!
    var renderStrokeView : RenderStrokeView!
    var pageSymbolView : PageSymbolView!
    
    var backImageView : UIImageView!
    
    var pageInfo = PageInfo()
    var stroke: [Dot] = []
    var strokeRefresh: [Dot] = []
    var strokeRefreshArr: [[Dot]] = []
    var penConnectBool:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(origin: CGPoint.zero, size: scrollView.frame.size)
        drawingView = UIView(frame: frame)
        pageStrokeView = PageStrokeView(frame: frame)
        renderStrokeView = RenderStrokeView(frame: frame)
        backImageView = UIImageView(frame: frame)
        drawingView.addSubview(backImageView)
        drawingView.addSubview(renderStrokeView)
        drawingView.addSubview(pageStrokeView)
        pageSymbolView = PageSymbolView(frame: frame)
        scrollView.addSubview(pageSymbolView!)
        scrollView.addSubview(drawingView)
        
        scrollView.delegate = self
        ActionHelper.shared.delegate = self
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        pencilSetBtn.isEnabled = false
        pencilSetBtn.tintColor = UIColor.clear
        
        noteUpdate(supportNote: .note234)
        symbolViewSet(supportNote: .note234)
        
        PenHelper.shared.connectDelegate = { [weak self] (success) -> () in
            if (success) {
                self?.penConnectBool = true
                self?.pencilSetBtn.isEnabled = true
                self?.pencilSetBtn.tintColor = UIColor.black
                if #available(iOS 13.0, *) {
                    self?.pencilConBtn.image = UIImage(systemName: "pencil")
                } else {
                    self?.pencilConBtn.image = UIImage(named: "")
                    self?.pencilConBtn.title = "연결"
                }
            }else{
                self?.penConnectBool = false
                self?.pencilSetBtn.isEnabled = false
                self?.pencilSetBtn.tintColor = UIColor.clear
                if #available(iOS 13.0, *) {
                    self?.pencilConBtn.image = UIImage(systemName: "pencil.slash")
                } else {
                    self?.pencilConBtn.image = UIImage(named: "")
                    self?.pencilConBtn.title = "비연결"
                }
                
                if PenHelper.shared.connectingArr.count > 0{
                    PenFinder.shared.disConnect(PenHelper.shared.connectingArr[0].pen)
                }
            }
    
        }
        
        PenHelper.shared.dotDelegate = { [weak self] (dot)-> () in
            self?.stroke.append(dot)
            self?.strokeRefresh.append(dot)
            if dot.dotType == .Down{
                
                if !dot.pageInfo.isEqual(self!.pageInfo){
                    if self?.pageInfo.note != dot.pageInfo.note{
                        self?.strokeRefresh.removeAll()
                        switch dot.pageInfo.note {
                        case 234:
                            self!.noteUpdate(supportNote: .note234)
                            self!.symbolViewSet(supportNote: .note234)
                        case 261:
                            self!.noteUpdate(supportNote: .note261)
                            self!.symbolViewSet(supportNote: .note261)
                        default:
                            self!.noteUpdate(supportNote: .note261)
                            self!.symbolViewSet(supportNote: .note261)
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "알림", message: "샘플에서 지원하지 않는 노트 입니다.", preferredStyle: UIAlertController.Style.alert)
                                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
                                alertController.addAction(okButton)
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    self?.pageInfo = dot.pageInfo
                    DispatchQueue.main.async {
                        self?.navigationItem.title = "page \(self?.pageInfo.page ?? 0) note \(self?.pageInfo.note ?? 0)"
                        self?.renderStrokeView.clear()
                    }
                }
                
            }else if dot.dotType == .Up{
                ActionHelper.shared.symbolCheck(self!.stroke)
                self?.renderStrokeView.setStroke(self!.stroke)
                self?.strokeRefreshArr.append(self?.strokeRefresh ?? [])
                self?.strokeRefresh.removeAll()
                self?.stroke.removeAll()
            }else if dot.dotType == .Move{

            }else{

            }
            
            self?.pageStrokeView.addDot(dot)
        }
        
        PenHelper.shared.dotsDataDelegate = { [weak self] (linedata)-> () in
            for strokeArr in linedata.strokeArray{
                for dotArr in strokeArr.dotArray{
                    self?.strokeRefresh.append(contentsOf: [dotArr])
                }
                self?.renderStrokeView.clear()
                self?.renderStrokeView.setStroke(self!.strokeRefresh)
                self?.strokeRefresh.removeAll()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swipeToPop()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            let frame = CGRect(origin: CGPoint.zero, size: self.scrollView.frame.size)
            self.drawingView.frame.size = frame.size
            self.pageStrokeView.frame.size  = frame.size
            self.renderStrokeView.frame.size  = frame.size
            self.pageSymbolView.frame.size = frame.size
            self.backImageView.frame.size = frame.size
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        if penConnectBool {
            if PenHelper.shared.connectingArr.count > 0{
                PenFinder.shared.disConnect(PenHelper.shared.connectingArr[0].pen)
            }
        }
        print("deinit : MainViewController")
    }
    
    @IBAction func pencilConBtnClicked(_ sender: UIBarButtonItem) {
        if #available(iOS 13.0, *) {
            if centralManager.state == .poweredOff {
                centralManager = CBCentralManager(delegate: self, queue: (DispatchQueue(label: "nestudio.navicontroller")), options: [CBCentralManagerOptionShowPowerAlertKey: true])
            } else if (centralManager.authorization == .allowedAlways) {
                if penConnectBool {
                    penConnectBool = false
                    if PenHelper.shared.connectingArr.count > 0{
                        PenFinder.shared.disConnect(PenHelper.shared.connectingArr[0].pen)
                    }
                    PenHelper.shared.connectDelegate?(false)
                }else{
                    let vc = PenSearchViewController.instance()
                    present(vc, animated: true, completion: nil)
                }
            } else {
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func pencilSetBtnClicked(_ sender: UIBarButtonItem) {
        let vc = PenSettingViewController.instance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MainViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .poweredOff:
            print("setting form")
        default:
            print("central.state", central.state.rawValue)
        }
    }
}

extension MainViewController {
    func symbolViewSet(supportNote: SampleSupportNote) {
        DispatchQueue.main.async {
            self.pageSymbolView.clearSymbols()
            self.renderStrokeView.clear()
            
            var rect = CGRect.zero
            var page = self.pageInfo.page
            var symbollist:[SymbolData]?
            if page >= 1{
                page = page - 1
            }
            
            switch supportNote {
            case .note234:
                guard let note234Data = NProjParser.shared.getNoteData(note: .note234) else {
                    print("note 234 data is nil")
                    return
                }
                symbollist = note234Data.symbolList
                rect = CGRect(x: CGFloat(note234Data.pageList[page].x1 + note234Data.pageList[page].crop_margin_left),
                              y: CGFloat(note234Data.pageList[page].y1 + note234Data.pageList[page].crop_margin_top),
                              width: CGFloat(note234Data.pageList[page].x2 - (note234Data.pageList[page].crop_margin_left + note234Data.pageList[page].crop_margin_right)),
                              height: CGFloat(note234Data.pageList[page].y2 - (note234Data.pageList[page].crop_margin_top + note234Data.pageList[page].crop_margin_bottom)))
            case .note261:
                guard let note261Data = NProjParser.shared.getNoteData(note: .note261) else {
                    print("note 261 data is nil")
                    return
                }
                
                symbollist = note261Data.symbolList
                rect = CGRect(x: CGFloat(note261Data.pageList[page].x1 + note261Data.pageList[page].crop_margin_left),
                              y: CGFloat(note261Data.pageList[page].y1 + note261Data.pageList[page].crop_margin_top),
                              width: CGFloat(note261Data.pageList[page].x2 - (note261Data.pageList[page].crop_margin_left + note261Data.pageList[page].crop_margin_right)),
                              height: CGFloat(note261Data.pageList[page].y2 - (note261Data.pageList[page].crop_margin_top + note261Data.pageList[page].crop_margin_bottom)))
            }
            
            
            var imageName = "\(self.pageInfo.section)_\(self.pageInfo.owner)_\(self.pageInfo.note)_\(self.pageInfo.page)"
            var image = UIImage(named: imageName)
            if image == nil {
                print("image is nil")
                imageName = "\(self.pageInfo.section)_\(self.pageInfo.owner)_\(self.pageInfo.note)_\(self.pageInfo.page % 2)"
                image = UIImage(named: imageName)
            }
            self.backImageView.image = image
            self.backImageView.frame = self.pageStrokeView.frame
            
            self.pageSymbolView?.setSymbol(rect, symbollist!)
            ActivityIndicator.hideActivityIndicator(uiView: self.view)
        }
    }
    
    func noteUpdate(supportNote: SampleSupportNote){
        DispatchQueue.main.async {
            ActivityIndicator.showActivityIndicator(uiView: self.view)
        }
        
//        let image = UIImage(named: "note_\(pageInfo.note)")
        let image = UIImage(named: supportNote.rawValue)
        DispatchQueue.main.async {
            self.noteCover.image = image
        }
        
        pageUpdate(supportNote: supportNote)
    }
    
    func pageUpdate(supportNote: SampleSupportNote){
        var page = self.pageInfo.page
        
        if page >= 1{
            page = page - 1
        }
        
        switch supportNote {
        case .note234:            guard let note234Data = NProjParser.shared.getNoteData(note: .note234) else {
                print("note 234 is nil")
                return
            }
            
            self.renderStrokeView.x = Double(note234Data.pageList[page].x1)
            self.renderStrokeView.y = Double(note234Data.pageList[page].y1)
            self.renderStrokeView.width = Double(note234Data.pageList[page].x2)
            self.renderStrokeView.height = Double(note234Data.pageList[page].y2)
            
            self.pageStrokeView.x = Double(note234Data.pageList[page].x1)
            self.pageStrokeView.y = Double(note234Data.pageList[page].y1)
            self.pageStrokeView.width = Double(note234Data.pageList[page].x2)
            self.pageStrokeView.height = Double(note234Data.pageList[page].y2)
        case .note261:
            guard let note261Data = NProjParser.shared.getNoteData(note: .note261) else {
                print("note 261 is nil")
                return
            }
            
            self.renderStrokeView.x = Double(note261Data.pageList[page].x1)
            self.renderStrokeView.y = Double(note261Data.pageList[page].y1)
            self.renderStrokeView.width = Double(note261Data.pageList[page].x2)
            self.renderStrokeView.height = Double(note261Data.pageList[page].y2)
            
            self.pageStrokeView.x = Double(note261Data.pageList[page].x1)
            self.pageStrokeView.y = Double(note261Data.pageList[page].y1)
            self.pageStrokeView.width = Double(note261Data.pageList[page].x2)
            self.pageStrokeView.height = Double(note261Data.pageList[page].y2)
        }
        
        
        DispatchQueue.main.async {
//            self.renderStrokeView.refreshView(dot: self.strokeRefreshArr)
            self.renderStrokeView.clear()
            self.strokeRefresh.removeAll()
            
        }
        symbolViewSet(supportNote: supportNote)
    }
}

extension MainViewController : UIGestureRecognizerDelegate{
    
    func swipeToPop() {

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }
    
}

extension MainViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.drawingView
    }
}

extension MainViewController : SymbolActionProtocol{
    func Event(symbol: SymbolData) {
        DispatchQueue.main.async {
            let title = "Symbol Event"
            let ac = UIAlertController(title: title, message: "make event what you want.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            ac.addAction(defaultAction)
            self.present(ac, animated: true, completion: nil)
        }
    }
}

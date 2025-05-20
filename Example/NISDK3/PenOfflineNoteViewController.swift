//
//  PenOfflineNoteViewController.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NISDK3

enum OfflineCheck{
    case note,page
}

class PenOfflineNoteViewController: UIViewController {
    
    static func instance() -> PenOfflineNoteViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PenOfflineNoteViewController") as! PenOfflineNoteViewController
        return vc
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteAllPagesButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var notelist : [OfflineNoteList.Note] = []
    var pagelist : OfflinePageList?
    var datalist: OffLineData?
    var dataCheck = OfflineCheck.note {
        didSet {
            
            DispatchQueue.main.async(execute: {
                self.statusLabel.text = "\(self.dataCheck)"
                
                if self.dataCheck == .note {
                    self.deleteAllPagesButton.isHidden = true
                } else {
                    self.deleteAllPagesButton.isHidden = false
                }
            })
        }
    }
    
    // request Note List
    var requestOfflineNoteCommand: (() -> (Void)) = {
        PenHelper.shared.pen?.requestOfflineNoteList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // as an initial setup, update status label and hide delete all pages button
        self.statusLabel.text = "\(self.dataCheck)"
        self.deleteAllPagesButton.isHidden = true
        
        // request offline notes
        requestOfflineNoteCommand()
        
        // for notes
        PenHelper.shared.offlinenoteDelegate = { [weak self] (noteinfo) -> () in
            self?.notelist = noteinfo.notes
            DispatchQueue.main.async {
                self?.dataCheck = .note
                self?.tableView.reloadData()
            }
        }
        
        PenHelper.shared.offlineNoteDeleteDelegate = { [weak self] (errorCode: UInt8?) -> (Void) in
            
            guard let self = self else { return }
            
            let message = errorCode == nil ? "note deleted" : "error"
            
            showSimpleNotification(message: message, in: self)
            
            if errorCode == nil {
                // refresh
                self.requestOfflineNoteCommand()
            }
            
        }
        
        // for pages
        PenHelper.shared.offlinepageDelegate = { [weak self] (pageinfo) -> () in
            self?.pagelist = pageinfo
            print("페이지리스트 : \(self?.pagelist)")
            DispatchQueue.main.async {
                self?.dataCheck = .page
                self?.tableView.reloadData() 
            }
        }
        
        PenHelper.shared.offlinePageDeleteDelegate = { [weak self] (errorCode: UInt8?) -> (Void) in
            
            guard let self = self else { return }
            
            let message = errorCode == nil ? "page deleted" : "error"
            
            showSimpleNotification(message: message, in: self)
            
            if errorCode == nil {
                // refresh
                self.requestOfflineNoteCommand()
            }
            
        }
        
        
        PenHelper.shared.offlinedataDelegate = { [weak self] (datainfo) -> () in
            self?.datalist = datainfo
            
            if self?.datalist?.strokeArray.count ?? 0 > 0 {
                
                DispatchQueue.main.async {
                    let  vc = self?.navigationController?.viewControllers.filter({$0 is MainViewController}).first
                    PenHelper.shared.dotsDataDelegate!(self!.datalist!)
                    self?.navigationController?.popToViewController(vc!, animated: true)
                }
            }
        }
    }
    
    @IBAction func deleteAllPagesButtonTapped(_ sender: UIButton) {
        
        guard dataCheck == .page else {
            return
        }
        
        // show a simple popup for confirm to delete all notes or pages
        let message = "Are you sure you want to delete all ofline pages?"
        
        showYesAndNoPopup(message: message, in: self) { [unowned self] in
            
            if let pagelist = self.pagelist {
                
                let section = pagelist.section
                let owner = pagelist.owner
                let note = pagelist.note
                let pages = pagelist.pages
                
                // maximum pages for pen to handle per request
                let MAX_PAGES = 128
                    
                // Split pages into chunks of at most MAX_PAGES pages
                var pageChunks: [[UInt32]] = []
                    
                if pages.count > MAX_PAGES {
                    // Split into chunks
                    var currentChunk: [UInt32] = []
                    
                    for (index, page) in pages.enumerated() {
                        currentChunk.append(page)
                            
                        // When chunk reaches MAX_PAGES or it's the last page, push the chunk and start a new one
                        if currentChunk.count == MAX_PAGES || index == pages.count - 1 {
                            pageChunks.append(currentChunk)
                            currentChunk = []
                        }
                    }
                } else {
                    // If the number of pages is less than or equal to MAX_PAGES, no need to chunk
                    pageChunks = [pages]
                }
                    
                // Send delete requests for each chunk
                for pageChunk in pageChunks {
                    PenHelper.shared.pen?.requestDeleteOfflineDataPage(section, owner, note, pageChunk)
                }
            }
        }
    }
    
}

extension PenOfflineNoteViewController: NoteCellDelegate {
    
    func buttonTap(index: IndexPath, sender: NoteCell) {
        
        // show a simple popup for confirm to delete either individual note or page
        var message = ""
        switch dataCheck {
        case .note:
            message = "Are you sure you want to delete this note?"
        case .page:
            message = "Are you sure you want to delete this page?"
        }
        
        showYesAndNoPopup(message: message, in: self) { [unowned self] in
            
            switch self.dataCheck {
            case .note:
                
                let noteData = notelist[index.row]
                
                // public func requestDeleteOfflineDataNote(_ section: UInt8,_ owner: UInt32,_ note: [UInt32])
                PenHelper.shared.pen?.requestDeleteOfflineDataNote(noteData.section, noteData.owner, [noteData.note])
            case .page:
                
                if let pagelist = self.pagelist {
                    
                    // public func requestDeleteOfflineDataPage(_ section: UInt8,_ owner: UInt32, _ note:UInt32, _ pageList: [UInt32]
                    let page = pagelist.pages[index.row]
                    PenHelper.shared.pen?.requestDeleteOfflineDataPage(pagelist.section, pagelist.owner, pagelist.note, [page])
                }
            }
        }
        
    }
    
    func showYesAndNoPopup(message: String, in viewController: UIViewController, yesClosure: (() -> (Void))?) {
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

        // Yes Action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            
            yesClosure?()
            
            print("User selected Yes")
            // Handle the "Yes" response here
            
        }
        
        // No Action
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            print("User selected No")
            // Handle the "No" response here
        }
        
        // Add actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present the alert
        DispatchQueue.main.async(execute: {
            viewController.present(alertController, animated: true, completion: nil)
        })
        
    }
    
    func showSimpleNotification(message: String, in viewController: UIViewController) {
        let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        
        // OK Action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("User acknowledged the message")
            // Handle the OK action here
        }
        
        // Add OK action to the alert controller
        alertController.addAction(okAction)
        
        // Present the alert
        DispatchQueue.main.async(execute: {
            viewController.present(alertController, animated: true, completion: nil)
        })
        
    }
}

extension PenOfflineNoteViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataCheck {
        case .note:
            return notelist.count
        case .page:
            return pagelist?.pages.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        switch dataCheck {
        case .note:
            cell.noteLabel.text = "Note \"\(self.notelist[indexPath.row].note)\""
        case .page:
            cell.noteLabel.text = "Note\"\(self.pagelist?.note ?? 0)\" Page \(self.pagelist?.pages[indexPath.row] ?? 0)"
        }
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataCheck {
        case .note:
            PenHelper.shared.pen?.requestOfflinePageList(self.notelist[indexPath.row].section, self.notelist[indexPath.row].owner, self.notelist[indexPath.row].note)
        case .page:
            PenHelper.shared.pen?.requestOfflineData(self.pagelist?.section ?? 3, self.pagelist?.owner ?? 27, self.pagelist?.note ?? 655)
            break;
        }
    }
}

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var noteLabel: UILabel!
    
    var indexPath = IndexPath.init(row: 0, section: 0)
    weak var delegate: NoteCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    @IBAction func deleteButtonTapped() {
        delegate?.buttonTap(index: indexPath, sender: self)

    }
}

protocol NoteCellDelegate: AnyObject {
    func buttonTap(index: IndexPath, sender:NoteCell)
}

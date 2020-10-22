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
    var notelist : [OfflineNoteList.Note] = []
    var pagelist : OfflinePageList?
    var datalist: OffLineData?
    var dataCheck = OfflineCheck.note
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PenHelper.shared.pen?.requestOfflineNoteList()
        
        PenHelper.shared.offlinenoteDelegate = { [weak self] (noteinfo) -> () in
            self?.notelist = noteinfo.notes
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        PenHelper.shared.offlinepageDelegate = { [weak self] (pageinfo) -> () in
            self?.pagelist = pageinfo
            DispatchQueue.main.async {
                self?.dataCheck = .page
                self?.tableView.reloadData()
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
}

extension PenOfflineNoteViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataCheck {
        case .note:
            return notelist.count
        case .page:
            return pagelist?.page.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        switch dataCheck {
        case .note:
            cell.noteLabel.text = "Note \"\(self.notelist[indexPath.row].note)\""
        case .page:
            cell.noteLabel.text = "Note\"\(self.pagelist?.note ?? 0)\" Page \(self.pagelist?.page[indexPath.row] ?? 0)"
        }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

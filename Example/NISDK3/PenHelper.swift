//
//  PenHelper.swift
//  NISDK3_Example
//
//  Created by NeoLAB on 2020/04/07.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import NISDK3
import CoreBluetooth
import UIKit

class PenHelper: PenDelegate{
    
    static let shared = PenHelper()
    
    private init() { }
    
    var penAutorizedDelegate: ((_ success: Bool) -> ())?
    var connectDelegate: ((Bool) -> ())?
    var dotDelegate: (( _ dot: Dot) -> ())?
    //For hovermode
    var hoverDelegate: (( _ dot: Dot) -> ())?
    var penSettingDelegate: ((_ status: PenSettingStruct) -> ())?
    var offlinenoteDelegate: ( (_ notes: OfflineNoteList) -> ())?
    var offlinepageDelegate: ( (_ pages: OfflinePageList) -> ())?
    //Step2 : Offline Data
    var offlinedataDelegate: ((OffLineData) -> ())?
    //Step3 : Offline Data Status
    var offlinestatusDelegate: ( (_ percent: Float) -> ())?
    var fwUpdateSuccessDelegate: ((_ success: Bool) -> ())?
     
    var pen:PenController?
    var connectingArr: [(pen: CBPeripheral, penAd: PenAdvertisementStruct)] = []
    var dotArr:[Dot] = []
    var dotsDataDelegate: ((OffLineData) -> ())?
    var penFWUpgradePerDelegate: ((Float) -> ())?
    
    func penData(_ sender: PenController, _ dot: Dot) {
        dotArr.append(dot)
        
        if dot.dotType == .Up {
            dotArr.removeAll()
        }else if dot.dotType == .Down {
            print(dot.dotType, dot.pageInfo.page, dot.x, dot.y)
        }
        self.dotDelegate?(dot)
    }
    
    func penMessage(_ sender: PenController, _ msg: PenMessage) {
        switch msg {
        case .PEN_AUTHORIZED: // 펜 인증 완료
            print("PEN_AUTHORIZED : - msg : \(msg)")
            penAutorizedDelegate?(true)
            pen?.requestUsingAllNote()
        case .PEN_PASSWORD_REQUEST: // 펜 패스워드 필요
            print("PEN_PASSWORD_REQUEST : - msg : \(msg)")
            penAutorizedDelegate?(false)
        case .PEN_PROFILE: // 펜 정보
            print("PEN_PROFILE : - msg : \(msg)")
        case .PEN_SETTING_INFO(let setting): // 펜 세팅 정보
            print("PEN_SETTING_INFO : - msg : \(msg)")
            penSettingDelegate?(setting)
        case .PEN_SETUP_SUCCESS: //펜 세팅 성공
            print("PEN_SETUP_SUCCESS : - msg : \(msg)")
        case .PEN_SETUP_FAILURE: // 펜 세팅 실패
            print("PEN_SETUP_FAILURE : - msg : \(msg)")
        case .PEN_FW_UPGRADE_STATUS(let percent): // 펜 펌웨어 업그레이드 상태
            print("PEN_FW_UPGRADE_STATUS : - msg : \(msg)")
            penFWUpgradePerDelegate?(percent)
        case .PEN_FW_UPGRADE_SUCCESS: // 펜 펌웨어 업그레이드 성공
            print("PEN_FW_UPGRADE_SUCCESS : - msg : \(msg)")
            fwUpdateSuccessDelegate?(true)
        case .PEN_FW_UPGRADE_FAILURE: // 펜 펌웨어 업그레이드 실패
            print("PEN_FW_UPGRADE_FAILURE : - msg : \(msg)")
        case .PEN_FW_UPGRADE_SUSPEND: // 펜 펌웨어 업그레이드 일시 중단
            print("PEN_FW_UPGRADE_SUSPEND : - msg : \(msg)")
        case .PEN_CONNECTION_FAILURE_BTDUPLICATE: // 펜 연결 실패에 따른 중복 이벤트
            print("PEN_CONNECTION_FAILURE_BTDUPLICATE : - msg : \(msg)")
        case .EVENT_LOW_BATTERY: // 펜 배터리 부족
            print("EVENT_LOW_BATTERY : - msg : \(msg)")
        case .EVENT_DOT_ERROR: // 펜 점그리기 에러
            print("EVENT_DOT_ERROR : - msg : \(msg)")
        case .EVENT_POWER_OFF: // 펜 전원 꺼짐
            print("EVENT_POWER_OFF : - msg : \(msg)")
            PenHelper.shared.connectDelegate?(false)
        case .OFFLINE_DATA_NOTE_LIST(let notes): // 펜 오프라인 노트 리스트
            print("OFFLINE_DATA_NOTE_LIST : - msg : \(msg)")
            offlinenoteDelegate?(notes)
        case .OFFLINE_DATA_PAGE_LIST(let pages): // 펜 오프라인 페이지 리스트
            print("OFFLINE_DATA_PAGE_LIST : - msg : \(msg)")
            offlinepageDelegate?(pages)
        case .OFFLINE_DATA_SEND_START: // 펜 오프라인 데이터 보내기 시작
            print("OFFLINE_DATA_SEND_START : - msg : \(msg)")
        case .OFFLINE_DATA_SEND_STATUS(let percent): // 펜 오프라인 데이터 전송 상태
            print("OFFLINE_DATA_SEND_STATUS : - msg : \(msg) , \(percent)")
        case .OFFLINE_DATA_SEND_SUCCESS(let offdata): // 펜 오프라인 데이터 전송 성공
            print("OFFLINE_DATA_SEND_SUCCESS : - msg : \(msg)")
            offlinedataDelegate?(offdata)
        case .OFFLINE_DATA_SEND_FAILURE: // 펜 오프라인 데이터 전송 실패
            print("OFFLINE_DATA_SEND_FAILURE : - msg : \(msg)")
        case .PASSWORD_SETUP_SUCCESS: // 펜 패스워드 설정 성공
            print("PASSWORD_SETUP_SUCCESS : - msg : \(msg)")
        case .PASSWORD_SETUP_FAILURE: // 펜 패스워드 설정 실패
            print("PASSWORD_SETUP_FAILURE : - msg : \(msg)")
        //Touch and play case
        case .SOUND_RES_STATUS:
            print("SOUND_RES_STATUS : - msg : \(msg)")
        case .SOUND_RES_OID:
            print("SOUND_RES_OID : - msg : \(msg)")
        case .SOUND_RES_PDS:
            print("SOUND_RES_PDS : - msg : \(msg)")
        case .SOUND_RES_LOG_INFO:
            print("SOUND_RES_LOG_INFO : - msg : \(msg)")
        case .SOUND_RES_LOG_DATA:
            print("SOUND_RES_LOG_DATA : - msg : \(msg)")
        }
    }
  
    func hoverData(_ sender: PenController, _ dot: Dot) {
//        print("hoverData : sender : \(sender) - dot \(dot)")
        if hoverDelegate != nil {
            //print("dot dot dot : \(dot)")
            hoverDelegate?(dot)
        }
    }
    
    func setPen(pen : PenController){
        self.pen = pen
        self.pen?.setPenDelegate(self)
        self.pen?.showSDKLog(true)
    }
    
}

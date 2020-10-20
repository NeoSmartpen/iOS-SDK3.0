//
//  CMD.swift
//  NISDK3
//
//  Created by Aram Moon on 2017. 6. 8..
//  Copyright © 2017년 Aram Moon. All rights reserved.
//

import Foundation

/// PenMessage Data Struct
public enum PenMessage {
    
    /**
     Pens when the pen authorized, the events that occur
     - data: nil
     */
    case PEN_AUTHORIZED
    
    /**
     Request Password, the events that occur
     - data: PenPasswordStruct?
     */
    case PEN_PASSWORD_REQUEST(PenPasswordStruct)
    
    /**
     The status(battery, memory, ...) of pen
     - data: PenSettingStruct
     */
    case PEN_SETTING_INFO(PenSettingStruct)
    
    /**
     The constant PEN_SETUP_SUCCESS.
     - data: PenSetupType
     */
    case PEN_SETUP_SUCCESS(PenSetupType)
    
    /**
     The constant PEN_SETUP_FAILURE.
     - data: ErrorCode
     */
    case PEN_SETUP_FAILURE(ErrorCode)
    
    /**
     The constant PASSWORD_SETUP_SUCCESS.
     - data: PenPasswordChangeStruct
     */
    case PASSWORD_SETUP_SUCCESS(PenPasswordChangeStruct)
    /**
     The constant PASSWORD_SETUP_FAILURE.
     - data: PenPasswordChangeStruct
     */
    case PASSWORD_SETUP_FAILURE(PenPasswordChangeStruct)
    
    /**
     The constant EVENT_LOW_BATTERY.
     - data : Int (%)
     */
    case EVENT_LOW_BATTERY(Int)
    
    /**
     - data: PowerOffReason
     */
    case EVENT_POWER_OFF(PenPowerOffReason)
    
    /**
     Message showing the status of the firmware upgrade pen
     - data : Float( 0 ~ 100.0 %)
     */
    case PEN_FW_UPGRADE_STATUS(Float)
    
    /**
     * When the firmware upgrade is successful, the pen events that occur
     */
    case PEN_FW_UPGRADE_SUCCESS
    
    /**
     * When the firmware upgrade is fails, the pen events that occur
     */
    case PEN_FW_UPGRADE_FAILURE
    
    /**
     * When the firmware upgrade is suspended, the pen events that occur
     */
    case PEN_FW_UPGRADE_SUSPEND
    
    /**
     Off-line data stored in the pen's
     - data: [(SectionId: UInt8, OnerId: UInt32, Note(Book)Id: UInt32)] Tuple List
     */
    case OFFLINE_DATA_NOTE_LIST(OfflineNoteList)
    
    /**
     Off-line data stored in the pen's
     - data: [PageId : UInt32] List
     */
    case OFFLINE_DATA_PAGE_LIST(OfflinePageList)
    
    /**
     The constant OFFLINE_DATA_SEND_START.
     - data: nil
     */
    case OFFLINE_DATA_SEND_START
    
    /**
     The constant OFFLINE_DATA_SEND_STATUS.
     - data : Float(0 ~ 100.0 %)
     */
    case OFFLINE_DATA_SEND_STATUS(Float)
    
    /**
     The constant OFFLINE_DATA_SEND_SUCCESS.
     - data : OffLineData
     */
    case OFFLINE_DATA_SEND_SUCCESS(OffLineData)
    
    /**
     The constant OFFLINE_DATA_SEND_FAILURE.
     - data: nil
     */
    case OFFLINE_DATA_SEND_FAILURE
    
    /**
     * Pens when the connection fails cause duplicate BT connection, an event that occurs
     */
    case PEN_CONNECTION_FAILURE_BTDUPLICATE
    
    /**
     Pens Profile (key,value)
     - data: ProfileStruct
     */
    case PEN_PROFILE(ProfileStruct)
    
    /**
     SoundPen PDS(for touch and play)
     - data: PDSStruct
     */
    case SOUND_RES_PDS(PDSStruct)
    
    /**
     SoundPen OID(for touch and play)
     - data: ODIStruct
     */
    case SOUND_RES_OID(ODIStruct)
    
    /**
     SoundPen Status(for touch and play)
     - data: SoundStatusStruct
     */
    case SOUND_RES_STATUS(SoundStatusStruct)
    
    /**
     Pens Error
     - data: DotError
     */
    case EVENT_DOT_ERROR(DotError)
    
    /**
     Pens Log Info(for touch and play)
     - data: LogInfoStruct
     */
    case SOUND_RES_LOG_INFO(LogInfoStruct)
    
    /**
     Pens Log Data(for touch and play)
     - data: LogDataStruct
     */
    case SOUND_RES_LOG_DATA(LogDataStruct)
    
}

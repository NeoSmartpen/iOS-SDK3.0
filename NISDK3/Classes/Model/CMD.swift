//
//  CMD.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 2. 21..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

enum CMD: UInt8 {
    case VERSION_INFO = 0x01
    case COMPARE_PWD = 0x02
    case CHANGE_PWD = 0x03
    case PEN_STATE = 0x04
    case SET_PEN_STATE = 0x05
    case SET_NOTE_LIST = 0x11
    case REQ1_OFFLINE_NOTE_LIST = 0x21
    case REQ2_OFFLINE_PAGE_LIST = 0x22
    case REQ1_OFFLINE_DATA = 0x23
    case REQ2_OFFLINE_DATA = 0x24
    case REQ_DEL_OFFLINE_DATA = 0x25
    case REQ1_FW_FILE = 0x31
    case RES2_FW_FILE = 0xB2
    case REQ_PROFILE = 0x41
    
    case EVENT_BATT_ALARM = 0x61
    case EVENT_POWER_OFF = 0x62
    case EVENT_PEN_UPDOWN = 0x63
    case EVENT_PEN_NEWID = 0x64
    /// Full Dot Data
    case EVENT_PEN_DOTCODE = 0x65
    case EVENT_PEN_DOTCODE2 = 0x66
    case EVENT_PEN_DOTCODE3 = 0x67
    
    //From Pen
    case RES_VERSION_INFO = 0x81
    case RES_COMPARE_PWD = 0x82
    case RES_CHANGE_PWD = 0x83
    case RES_PEN_STATE = 0x84
    case RES_SET_PEN_STATE = 0x85
    case RES_SET_NOTE_LIST = 0x91
    case RES1_OFFLINE_NOTE_LIST = 0xA1
    case RES2_OFFLINE_PAGE_LIST = 0xA2
    case RES1_OFFLINE_DATA_INFO = 0xA3
    case RES2_OFFLINE_DATA = 0xA4
    case RES_DEL_OFFLINE_DATA = 0xA5
    case RES1_FW_FILE = 0xB1
    case REQ2_FW_FILE = 0x32
    case RES_PROFILE = 0xC1
    
    // Only Touch and play
    case SOUND_RES_PDS = 0x73
    case SOUND_RES_OID = 0x76
    case SOUND_RES_STATUS = 0x77
    case SOUND_REQ_LOG_INFO = 0x74
    case SOUND_RES_LOG_INFO = 0xF4
    case SOUND_REQ_LOG_DATA = 0x75
    case SOUND_RES_LOG_DATA = 0xF5
    
    // New Dot, UpDown, PageInfo, Error
    case EVENT_DOT_ERROR = 0x68
    case EVENT_NEW_PEN_DOWN = 0x69
    case EVENT_NEW_PEN_UP = 0x6A
    case EVENT_NEW_PEN_NEWID = 0x6B
    case EVENT_NEW_PEN_DOT = 0x6C
    case EVENT_NEW_DOT_ERROR = 0x6D
    case EVENT_HOVER_DOT = 0x6F
    
}

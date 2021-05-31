//
//  BLEEnums.swift
//  CommunicationLibrary
//
//  Created by Admin on 23/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation

public enum BLECentralState : Int {
    case unknown            //0
    case resetting          //1
    case unsupported        //2
    case unauthorized       //3
    case poweredOff         //4
    case poweredOn          //5
}

public enum BLEPeripheralState : Int {
    case disconnected       //0
    case connecting         //1
    case connected          //2
    case disconnecting      //3
}

public enum PeripheralType : Int {
    case DW2 = 1       //1
    case DW5           //2
    case RW2           //3
}

public enum ConnectionError: Int {
    
    case FAILED_TO_CONNECT = 1
    case FAILED_TO_CONNECT_BLE_DISABLED
    case FAILED_TO_CONNECT_INSUFFICIENT_AUTHENTICATION_ENCRYPTION
    case FAILED_TO_DISCOVER_SERVICES
    case FAILED_TO_DISCOVER_CHARACTERISTICS
    case FAILED_TO_DISCOVER_DESCRIPTORS
    case FAILED_TO_RECONNECT
    case RETRYING_TO_CONNECT

}

public enum ConfigKeys: String {
    
    case REATTEMPT_COUNT_KEY = "REATTEMPT_COUNT_KEY"
    case WILL_RESTORE_STATE = "WILL_RESTORE_STATE"
}

public enum ScanError: Int {

   case NO_ERROR = 1

    /**
     * Failed to start scan as BLE scan with the same settings is already started by the app.
     */
    case SCAN_FAILED_ALREADY_STARTED

    /**
     * Failed to start scan as app cannot be registered.
     */
    case  SCAN_FAILED_APPLICATION_REGISTRATION_FAILED

    /**
     * Failed to start scan due an internal error
     */
    case  SCAN_FAILED_INTERNAL_ERROR

    /**
     * Failed to start power optimized scan as this feature is not supported.
     */
    case  SCAN_FAILED_FEATURE_UNSUPPORTED

    /**
     * Failed to start scan as it is out of hardware resources.
     * @hide
     */
    case SCAN_FAILED_OUT_OF_HARDWARE_RESOURCES

    /**
     * Failed to start scan as application tries to scan too frequently.
     * @hide
     */
    case SCAN_FAILED_SCANNING_TOO_FREQUENTLY

    /**
     * Failed to start scan as Device Bluetooth is Disabled.
     * @hide
     */
    case SCAN_FAILED_BLUETOOTH_DISABLED
}

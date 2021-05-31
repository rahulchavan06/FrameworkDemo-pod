//
//  CBAdvertisingData.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 15/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation
import CoreBluetooth

open class CBAdvertisingData {
    
    class open func getAdvertisingDataName(_ key: String) -> String {
        switch key {
        case CBAdvertisementDataLocalNameKey:
            return "Local Name"
        case CBAdvertisementDataTxPowerLevelKey:
            return "Tx Power Level"
        case CBAdvertisementDataServiceUUIDsKey:
            return "Service UUIDs"
        case CBAdvertisementDataServiceDataKey:
            return "Service Data"
        case CBAdvertisementDataManufacturerDataKey:
            return "Manufacturer Data"
        case CBAdvertisementDataOverflowServiceUUIDsKey:
            return "Overflow Service UUIDs"
        case CBAdvertisementDataIsConnectable:
            return "Device is Connectable"
        case CBAdvertisementDataSolicitedServiceUUIDsKey:
            return "Solicited Service UUIDs"
        default:
            return key
        }
    }
    
    class open func getAdvertisingDataStringValue(_ datas: [String : Any?], key : String) -> String {
        var resultString : String? = ""
        if key == CBAdvertisementDataLocalNameKey {
            resultString = datas[CBAdvertisementDataLocalNameKey] as? String
        } else if key == CBAdvertisementDataTxPowerLevelKey {
            resultString = datas[CBAdvertisementDataTxPowerLevelKey] as? String
        } else if key == CBAdvertisementDataServiceUUIDsKey {
            guard let serviceUUIDs = datas[CBAdvertisementDataServiceUUIDsKey] as? NSArray else {
                return ""
            }
            for i in 0..<serviceUUIDs.count {
                resultString = resultString! + "\(serviceUUIDs.object(at: i)),"
            }
            resultString?.removeLast();
        } else if key == CBAdvertisementDataServiceDataKey {
            guard let data = datas[CBAdvertisementDataServiceDataKey] as? NSDictionary else {
                return ""
            }
            print("\(data)")
            resultString = data.description.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        } else if key == CBAdvertisementDataManufacturerDataKey {
            resultString = (datas[CBAdvertisementDataManufacturerDataKey] as? Data)?.description
        } else if key == CBAdvertisementDataOverflowServiceUUIDsKey {
            resultString = ""
        } else if key == CBAdvertisementDataIsConnectable{
            if let connectable = datas[key] as? NSNumber {
                resultString = connectable.boolValue ? "true" : "false"
            }
        } else if key == CBAdvertisementDataSolicitedServiceUUIDsKey {
            resultString = ""
        }
        if resultString == nil {
            resultString = ""
        }
        return resultString!
    }
    
}

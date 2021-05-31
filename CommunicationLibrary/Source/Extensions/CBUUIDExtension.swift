//
//  CBUUIDExtension.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation

import CoreBluetooth

extension CBUUID {
    static public let genericAccessUUID = CBUUID(string: "1800")
    static public let deviceInfoUUID = CBUUID(string: "180A")
    static public let proteusUUID = CBUUID(string: "0000F72B-4F40-4C51-AD31-C410F4E12C04")
    static public let deviceNameUUID = CBUUID(string: "2A00")
    static public let appearanceUUID = CBUUID(string: "2A01")
    static public let modelNumberUUID = CBUUID(string: "2A24")
    static public let firmwareRevisionUUID = CBUUID(string: "2A26")
    static public let softwareRevisionUUID = CBUUID(string: "2A28")
    static public let manufacturerNameUUID = CBUUID(string: "2A29")
    static public let PLIPReadUUID = CBUUID(string: "00003A54-4F40-4C51-AD31-C410F4E12C04")
    static public let PLIPWriteUUID = CBUUID(string: "0000038B-4F40-4C51-AD31-C410F4E12C04")
    
    
    static let ConnectionParameter        = "2A04"
}

extension CBUUID {
    
    public var cbUUIDName : String? {
        if self == CBUUID.genericAccessUUID {
            return "Generic Access"
        } else if self == CBUUID.deviceInfoUUID {
            return "Device Information"
        } else if self == CBUUID.deviceNameUUID {
            return "Device Name"
        } else if self == CBUUID.appearanceUUID {
            return "Appearance"
        } else if self == CBUUID.modelNumberUUID {
            return "Model Number String"
        } else if self == CBUUID.firmwareRevisionUUID {
            return "Firmware Revision String"
        } else if self == CBUUID.softwareRevisionUUID {
            return "Software Revision String"
        } else if self == CBUUID.manufacturerNameUUID {
            return "Manufacturer Name String"
        } else if self == CBUUID.proteusUUID {
            return "Proteus"
        } else if self == CBUUID.PLIPReadUUID {
            return "PLIP Read"
        } else if self == CBUUID.PLIPWriteUUID {
            return "PLIP Write"
        }
        return nil
    }
}

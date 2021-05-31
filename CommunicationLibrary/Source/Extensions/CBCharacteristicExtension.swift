//
//  CBCharacteristicExtension.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import CoreBluetooth

extension CBCharacteristic {
    
    public var cbCharacteristicName : String {
        guard let name = self.uuid.cbUUIDName else {
            return "0x" + self.uuid.uuidString
        }
        return name
    }

}

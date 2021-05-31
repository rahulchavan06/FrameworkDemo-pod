//
//  CBServiceExtension.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation

import CoreBluetooth


extension CBService {

    public var cbServiceName : String {
        guard let name = self.uuid.cbUUIDName else {
            return "UUID: " + self.uuid.uuidString
        }
        return name
    }
}

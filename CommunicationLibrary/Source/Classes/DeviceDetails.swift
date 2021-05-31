//
//  PeripheralInfos.swift
//  CommunicationBase
//
//  Created by Rahul C. on 01/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import CoreBluetooth

public class DeviceDetails: Equatable, Hashable {
    
//    public var deviceState: BLECentralState = .unknown

    public let peripheral: CBPeripheral
    public var bleServices: [CBService] = []
    public var RSSI: Int = 0
    
//    public var patchState: BLECentralState = .unknown
    
    public var advertisementData: [String: Any] = [:]
    public var name: String?
    public var address: String?
    public var bondedStatus: Bool = false
    public var plipSchema: Int = 0
    public var deviceType: PeripheralType?
    public var connectionStatus: BLEPeripheralState?

    public var lastUpdatedTimeInterval: TimeInterval

    public init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
//        didSet {
            // store BLE services if available for peripheral.
            if let services = self.peripheral.services {
                for service in services {
                    self.bleServices.append(service)
                }
            }
//        }
//        print("Max write value: \(self.peripheral.maximumWriteValueLength(for: .withResponse))")
//        print("Max Read value: \(self.peripheral.maximumWriteValueLength(for: .withResponse))")

        self.lastUpdatedTimeInterval = Date().timeIntervalSince1970
    }

    static public func == (lhs: DeviceDetails, rhs: DeviceDetails) -> Bool {
        return lhs.peripheral.isEqual(rhs.peripheral)
    }

    public var hashValue: Int {
        return peripheral.hash
    }
}


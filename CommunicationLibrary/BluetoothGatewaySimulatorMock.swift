//
//  BluetoothGatewaySimulatorMock.swift
//  CommunicationLibrary
//
//  Created by Admin on 12/05/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation
import CoreBluetooth

let simulatorPeripheralConnectionTime: TimeInterval = 1

enum BLEStatusKey: String {
    case lastBLEState
    case isPeripheralInRange
    case isBLEOn
}


final class BluetoothGatewaySimulatorMock: BLEGateway {
    
    fileprivate var connectionTimer: Timer?
    
    fileprivate let defaultPatchesScannedFileName = "DefaultScannedPatches"
    fileprivate var defaultPatchesScannedFile: URL!
    var shouldReconnectOnIntialisation = true
    private var defaultBLEStatus: [String: Bool] {
        return [
            BLEStatusKey.isBLEOn.rawValue: true,
            BLEStatusKey.isPeripheralInRange.rawValue: true
        ]
    }
    var bleStatusDict: [String: Bool] {
        get {
            return UserDefaults.standard.value(forKey: BLEStatusKey.lastBLEState.rawValue) as? [String: Bool] ?? defaultBLEStatus
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: BLEStatusKey.lastBLEState.rawValue)
        }
    }

    override init() {
        
        super.init()
        
        self.scanningTimeOut = defaultSimulatorScanningTimeOut
        self.defaultPatchesScannedFile = Bundle(for: type(of: self)).url(forResource: self.defaultPatchesScannedFileName, withExtension: "txt")

    }
}

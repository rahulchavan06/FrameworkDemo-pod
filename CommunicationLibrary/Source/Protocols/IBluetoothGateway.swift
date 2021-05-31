//
//  BLEDelegate.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import CoreBluetooth

public protocol IBluetoothGateway {
    
    /**
     The callback function when the bluetooth has updated its state.
     
     - parameter state: The newest state
     */
    func didUpdateState(_ state: CBManagerState)
    
    /**
     The callback function when the bluetooth has updated.
     
     - parameter peripheral: Peripheral Details
     */
    func willRestoreState(_ peripheral: DeviceDetails)
    
    /**
     The callback function when near by peripheral has been discovered.
     
     - parameter peripheral:        Discovered peripheral device details.
     */
    func didDiscoverPeripheral(_ peripheral: DeviceDetails)
    
    /**
     The callback function when connected peripheral device services has been discovered.
     
     - parameter peripheral:        Peripheral contains services and details.
     */
    func didDiscoverServices(_ peripheral: CBPeripheral)
    
    /**
     The callback function when connected peripheral device services has been discovered.
     
     - parameter peripheral:        Discovered peripheral device details.
     */
    func didDiscoverCharacteritics(_ service: CBService)
    func didDiscoverDescriptors(_ characteristic: CBCharacteristic)

    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral)
    func didDisconnectPeripheral(_ peripheral: CBPeripheral)
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic)

//    func failedToConnectPeripheral(_ peripheral: CBPeripheral, error: Error)
    func failedToConnect(_ errorCode: ConnectionError, attemptCount: Int)
    func didFailedToHandshake(_ peripheral: CBPeripheral)
    func didFailToDiscoverCharacteritics(_ error: Error)
    func didFailToDiscoverDescriptors(_ error: Error)
    func didFailToReadValueForCharacteristic(_ error: Error)
    
    func failedToConnectWithError(_ peripheral: CBPeripheral, error: Error)
    func failedWithError(_ peripheral: DeviceDetails, errorCode: ConnectionError)

}



//MARK:- Default implementations of the optional methods

extension IBluetoothGateway {
    public func didUpdateState(_ state: CBManagerState) { }
    
    public func willRestoreState(_ peripheral: DeviceDetails) { }
    
    public func didDiscoverPeripheral(_ peripheral: DeviceDetails) { }
    public func didDiscoverServices(_ peripheral: CBPeripheral) { }
    public func didDiscoverCharacteritics(_ service: CBService) { }
    public func didDiscoverDescriptors(_ characteristic: CBCharacteristic) { }
    
    public func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) { }
    public func didDisconnectPeripheral(_ peripheral: CBPeripheral) { }
    public func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) { }
    
    public func failedToConnect(_ errorCode: ConnectionError, attemptCount: Int) { }
    public func didFailedToHandshake(_ peripheral: CBPeripheral) { }
    public func didFailToDiscoverCharacteritics(_ error: Error) { }
    public func didFailToDiscoverDescriptors(_ error: Error) { }
    public func didFailToReadValueForCharacteristic(_ error: Error) { }
    
    public func failedToConnectWithError(_ peripheral: CBPeripheral, error: Error) { }
    public func failedWithError(_ peripheral: DeviceDetails, errorCode: ConnectionError) { }

}

//
//  BLEManager.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import CoreBluetooth
import Foundation

public class BLEManager: NSObject, BLEDelegate {
    
    let bleGateway = BLEGateway.getInstance()
    fileprivate var nearbyPeripheralInfos: [PeripheralInfos] = []
    
    
    public static func getInstance() -> BLEManager {
        return instance
    }
    
    static private var instance : BLEManager {
        return sharedInstance
    }
    
    private static let sharedInstance = BLEManager()
    private override init() {
        super.init()
        initAll()
    }
    
    
    //MARK:- Internal methods
    func initAll() {
        print("BLEMnager --> initAll")
        
        nearbyPeripheralInfos.removeAll()
        if bleGateway.connectedPeripheral != nil {
            //bluetoothManager.disconnectPeripheral()
        }
        bleGateway.delegate = self
    }
    
    
    //MARK:- BLEDelegates
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // 1
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            // 2
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            // 3
            if peripherals.count > 0 {
                // 4
                //            connectedPeripheral = peripherals[0]
                // 5
                //            connectedPeripheral?.delegate = self
            }
        }
    }
    
    func willRestoreState(_ central: CBCentralManager, restoreData: [String : AnyObject]) {
        // 1
        if let peripheralsObject = restoreData[CBCentralManagerRestoredStatePeripheralsKey] {
            // 2
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            // 3
            if peripherals.count > 0 {
                // 4
                //      connectedPeripheral = peripherals[0]
                // 5
                //      connectedPeripheral?.delegate = self
            }
        }
    }
    
    public func didDiscoverPeripheral(_ peripheral: CB) {
        
//        if !nearbyPeripheralInfos.contains(peripheral) {
//            nearbyPeripheralInfos.append(peripheral)
//        }
//        peripheralsTb.reloadData()
    }
    
    public func didUpdateState(_ state: CBCentralManagerState) {
        print("MainController --> didUpdateState:\(state)")
        switch state {
        case .resetting:
            print("State: Resetting")
        case .poweredOn:
            bleGateway.startScanPeripheral()
//            UnavailableView.hideUnavailableView()
        case .poweredOff:
            print("State: Powered Off")
            fallthrough
        case .unauthorized:
            print("State: Unauthorized")
            fallthrough
        case .unknown:
            print("State: Unknown")
            fallthrough
        case .unsupported:
            print("State: Unsupported")
            bleGateway.stopScanPeripheral()
            bleGateway.disconnectPeripheral()
//            ConnectingView.hideConnectingView()
//            UnavailableView.showUnavailableView()
        }
    }
    
    public func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {
        print("MainController --> didConnectedPeripheral")
//        connectingView?.tipLbl.text = "Interrogating..."
    }
    
    public func didDiscoverServices(_ peripheral: CBPeripheral) {
        print("MainController --> didDiscoverService:\(peripheral.services?.description ?? "Unknown Service")")
        
        //        let tmp = PeripheralInfos(peripheral)
        //        guard let index = nearbyPeripheralInfos.firstIndex(of: tmp) else {
        //            return
        //        }
//        ConnectingView.hideConnectingView()
//        let peripheralController = PeripheralController()
        //        let peripheralInfo = nearbyPeripheralInfos[index]
//        self.navigationController?.pushViewController(peripheralController, animated: true)
    }
    
    public func didFailedToInterrogate(_ peripheral: CBPeripheral) {
//        ConnectingView.hideConnectingView()
//        AlertUtil.showCancelAlert("Connection Alert", message: "The perapheral disconnected while being interrogated.", cancelTitle: "Dismiss", viewController: self)
    }
}

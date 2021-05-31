//
//  BLEGateway.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 01/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import CoreBluetooth

public class BLEGateway : NSObject, CBPeripheralDelegate {
        
    
    /*fileprivate class DeviceDetails: Equatable, Hashable {
        let peripheral: CBPeripheral
        var RSSI: Int = 0
        var advertisementData: [String: Any] = [:]
        var lastUpdatedTimeInterval: TimeInterval
        
        init(_ peripheral: CBPeripheral) {
            self.peripheral = peripheral
            self.lastUpdatedTimeInterval = Date().timeIntervalSince1970
        }
        
        static func == (lhs: DeviceDetails, rhs: DeviceDetails) -> Bool {
            return lhs.peripheral.isEqual(rhs.peripheral)
        }
        
        var hashValue: Int {
            return peripheral.hash
        }
    }*/
    
    
    var expectedNamePrefix: String { return "RW2-" } // 1.
    fileprivate var nearbyPeripheralInfos: [DeviceDetails] = []

    var scanningTimeOut: TimeInterval = defaultBLEScanningTimeOut

    
    public var _manager : CBCentralManager?
    public var delegate : IBluetoothGateway?
    private(set) var connected = false
    
    fileprivate var isStateRestored = false
    fileprivate var restoredPeripheral : DeviceDetails?
    fileprivate var characteristicsDic = [CBUUID : [CBCharacteristic]]()
    var readCharacteristic : CBCharacteristic?
    var writeCharacteristic : CBCharacteristic?
    fileprivate var isListening = false
//    public var centralState: BLECentralState = .unknown
//    public var peripheralState: BLEPeripheralState = .connecting
    
    var state: CBManagerState? {
        guard _manager != nil else {
            return nil
        }
        return CBManagerState(rawValue: (_manager?.state.rawValue)!)//CBCentralManagerState(rawValue: (_manager?.state.rawValue)!)
    }
    
    private var willRestoreState : Bool? = false
    private var reconnectAttemptCount : Int? = 1
    private var noOfReconnectAttempt : Int = 0

    private var connectionTimer : Timer?
    private var handshakeTimer : Timer?
    private let notifCenter = NotificationCenter.default
    private var isConnecting = false
    var logs = [String]()
    public var connectedPeripheral : CBPeripheral?
    private(set) var connectedServices : [CBService]?
    public var deviceState: BLECentralState = .unknown
    let userDefaults = UserDefaults.standard

    static private var instance : BLEGateway {
        return sharedInstance
    }
    
    private static let sharedInstance = BLEGateway()
    
    //MARK:- Core Methods

    public override init() {
        super.init()
    }
    
    //MARK:- Internal Methods

    func initCBCentralManager() {
        var dic : [String : Any] = Dictionary()
        dic[CBCentralManagerOptionShowPowerAlertKey] = true
//        dic[CBCentralManagerScanOptionAllowDuplicatesKey] = true
        if willRestoreState! {
            dic[CBCentralManagerOptionRestoreIdentifierKey] = centralRestoreIdentifier
        }
        _manager = CBCentralManager(delegate: self, queue: nil, options: dic)
    }
    
    public func configure(config: [String : Any]) {
        print(config)
        willRestoreState = config[ConfigKeys.WILL_RESTORE_STATE.rawValue] as? Bool
        reconnectAttemptCount = config[ConfigKeys.REATTEMPT_COUNT_KEY.rawValue] as? Int
        
        self.initCBCentralManager()

    }
    
    
    public static func getInstance() -> BLEGateway {
        return instance
    }
    
    public func startScanPeripheral() {
        if connectedPeripheral != nil && self.deviceState == .poweredOn /*&& !isStateRestored */ {
            connectPeripheral(connectedPeripheral!)
        } else if self.deviceState == .poweredOn {
            _manager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
    }
    
    public func stopScanPeripheral() {
        _manager?.stopScan()
    }
    
    public func connectPeripheral(_ peripheral: CBPeripheral) {
        if !isConnecting {
            isConnecting = true
            _manager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
            
            if noOfReconnectAttempt < reconnectAttemptCount! {
                noOfReconnectAttempt = noOfReconnectAttempt + 1
            }
            connectionTimer = Timer.scheduledTimer(timeInterval: scanningTimeOut, target: self, selector: #selector(self.connectionTimeout(_:)), userInfo: peripheral, repeats: false)
        }
    }
    
    @objc private func connectionTimeout(_ timer : Timer) {
        if isConnecting {
            if noOfReconnectAttempt <= reconnectAttemptCount! && reconnectAttemptCount! > 1 {
                
                //If Reattempt to connect count is greater than 1
                isConnecting = false
                delegate?.failedToConnect(.RETRYING_TO_CONNECT, attemptCount: noOfReconnectAttempt)
                connectPeripheral(timer.userInfo as! CBPeripheral)
                connectionTimer = nil
            } else if reconnectAttemptCount == 1 {
                
                //If Reattempt to connect count is 1
                isConnecting = false
                delegate?.failedToConnect(.FAILED_TO_CONNECT, attemptCount: noOfReconnectAttempt)
                connectionTimer = nil
                /*isConnecting = false
                connectPeripheral(timer.userInfo as! CBPeripheral)
                connectionTimer = nil*/
            }
        }
    }

    public func disconnectPeripheral() {
        if connectedPeripheral != nil {
            _manager?.cancelPeripheralConnection(connectedPeripheral!)
            nearbyPeripheralInfos.removeAll()
            connectedPeripheral = nil
            startScanPeripheral()
        }
    }
    
    public func temporaryDisconnectPeripheral() {
        if connectedPeripheral != nil {
            _manager?.cancelPeripheralConnection(connectedPeripheral!)
//            nearbyPeripheralInfos.removeAll()
//            connectedPeripheral = nil
//            startScanPeripheral()
        }
    }

    @objc private func handshakeTimeout(_ timer: Timer) {
        disconnectPeripheral()
        
        delegate?.didFailedToHandshake(connectedPeripheral!)
    }
    
    func storeUserDefault(_ identifier: String) {
        userDefaults.setValue(identifier, forKey: connectedPeripheralUserDefaultIdentifier)
        userDefaults.synchronize()

    }
    
    public func discoverDescriptor(_ characteristic: CBCharacteristic) {
        if connectedPeripheral != nil  {
            connectedPeripheral?.discoverDescriptors(for: characteristic)
        }
    }

    public func discoverCharacteristics() {
        if connectedPeripheral == nil {
            return
        }
        let services = connectedPeripheral!.services
        if services == nil || services!.count < 1 { // Validate service array
            return;
        }
        for service in services! {
            connectedPeripheral!.discoverCharacteristics(nil, for: service)
        }
    }

    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        if connectedPeripheral == nil {
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }

    public func setNotification(enable: Bool, forCharacteristic characteristic: CBCharacteristic){
        if connectedPeripheral == nil {
            return
        }
        connectedPeripheral?.setNotifyValue(enable, for: characteristic)
    }

    func writeValue(data: Data, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        if connectedPeripheral == nil {
            return
        }
        connectedPeripheral?.writeValue(data, for: characteristic, type: type)
    }
}


extension BLEGateway: CBCentralManagerDelegate {
    
    //MARK:- CBCentralManager Delegates

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            print("State : Powered Off")
            self.deviceState = .poweredOff
//            nearbyPeripheralInfos.removeAll()
            self.temporaryDisconnectPeripheral()
        case .poweredOn:
            print("State : Powered On")
            self.deviceState = .poweredOn
            if self.connectedPeripheral != nil && !isStateRestored {
                self.connectPeripheral(connectedPeripheral!)
            }
        case .resetting:
            print("State : Resetting")
            self.deviceState = .resetting
        case .unauthorized:
            print("State : Unauthorized")
            self.deviceState = .unauthorized
        case .unknown:
            print("State : Unknown")
            self.deviceState = .unknown
        case .unsupported:
            print("State : Unsupported")
            self.deviceState = .unsupported
        @unknown default:
            break
        }
        
        if isStateRestored {
            self.disconnectPeripheral()
        } else if let state = self.state {
            delegate?.didUpdateState(state)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        // 1
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            for peripheral in peripherals {
//                if peripherals.count > 0 {
//                    let peripheral: CBPeripheral = peripherals[0]
                    let decodedIdentifier: String = userDefaults.value(forKey: connectedPeripheralUserDefaultIdentifier) as! String
                    if decodedIdentifier == peripheral.identifier.uuidString {
                        //isStateRestored = true
                        connectedPeripheral = peripheral
                        
                        let peripheralInfo = DeviceDetails(peripheral)
                        isStateRestored = true
                        restoredPeripheral = peripheralInfo
                        nearbyPeripheralInfos.append(peripheralInfo)
                    }
                    //peripheralInfo.advertisementData = advertisementData
                    
                    //                delegate?.willRestoreState(peripheralInfo)
                    //                self.disconnectPeripheral()
                    //connectPeripheral(connectedPeripheral!)
    //                }
            }
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscover peripheral called")
        
        let peripheralInfo = DeviceDetails(peripheral)
        print("Peripheral Name: \(peripheral.name ?? "")")

        if !nearbyPeripheralInfos.contains(peripheralInfo) {
            
            if (peripheral.name != nil && ((peripheral.name?.hasPrefix(self.expectedNamePrefix)) == true)) {
                peripheralInfo.RSSI = RSSI.intValue
                peripheralInfo.advertisementData = advertisementData
                
                if let name = advertisementData["kCBAdvDataLocalName"] {
                    
                    peripheralInfo.name = name as? String
                    print(peripheralInfo.name!) //->000D
                }
                
                if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                    assert(manufacturerData.count >= 5)
                    //0d00 - TI manufacturer ID
                    //Constructing 2-byte data as little endian (as TI's manufacturer ID is 000D)
                    let manufactureID = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8
                    print(String(format: "%04X", manufactureID)) //->000D
                    //fe - the node ID that I have given
                    let state = manufacturerData[2]
                    print(String(format: "%02X", state)) //->01
                    //05 - state of the node (something that remains constant
                    let deviceType = manufacturerData[3]
                    print(String(format: "%02X", deviceType)) //->03
                    //c6f - is the sensor tag battery voltage
                    //Constructing 2-byte data as big endian (as shown in the Java code)
                    let plipSchema = UInt16(manufacturerData[4])
                    print(String(format: "%02X", plipSchema)) //->08
                    
                    switch deviceType {
                    case 01:
                        peripheralInfo.deviceType = .DW2
                        break
                    case 02:
                        peripheralInfo.deviceType = .DW5
                        break
                    case 03:
                        peripheralInfo.deviceType = .RW2
                        break

                    default:
                        break
                    }
                    peripheralInfo.bondedStatus = (Int(state) != 0)
                    peripheralInfo.plipSchema = Int(plipSchema)
                }
                
                nearbyPeripheralInfos.append(peripheralInfo)

                if isStateRestored && restoredPeripheral?.peripheral.name == peripheral.name {
                    self.connectPeripheral(peripheral)
                } else {
                    delegate?.didDiscoverPeripheral(peripheralInfo)
                }
                
//                delegate?.didDiscoverPeripheral(peripheralInfo)

                return
            }
        } else {
            guard let index = nearbyPeripheralInfos.firstIndex(of: peripheralInfo) else {
                return
            }
            
            let originPeripheralInfo = nearbyPeripheralInfos[index]
            let nowTimeInterval = Date().timeIntervalSince1970
            
            // If the last update within one second, then ignore it
            guard nowTimeInterval - originPeripheralInfo.lastUpdatedTimeInterval >= 1.0 else {
                return
            }
            
            originPeripheralInfo.lastUpdatedTimeInterval = nowTimeInterval
            originPeripheralInfo.RSSI = RSSI.intValue
            originPeripheralInfo.advertisementData = advertisementData
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect peripheral called")
        isConnecting = false
        if connectionTimer != nil {
            connectionTimer!.invalidate()
            connectionTimer = nil
        }
        connected = true
        connectedPeripheral = peripheral
        
        self.storeUserDefault((connectedPeripheral?.identifier.uuidString)!)
        
        delegate?.didConnectedPeripheral(peripheral)
        stopScanPeripheral()
//        isStateRestored = false
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        handshakeTimer = Timer.scheduledTimer(timeInterval: scanningTimeOut, target: self, selector: #selector(self.handshakeTimeout(_:)), userInfo: peripheral, repeats: false)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect peripheral called")
        print("didFailToConnect Error\(String(describing: error))")

        isConnecting = false
        if connectionTimer != nil {
            connectionTimer!.invalidate()
            connectionTimer = nil
        }
        connected = false
        
        if let connectedPeri = connectedPeripheral,
           connectedPeri.identifier == peripheral.identifier {
            if let error = error {
                print("Connection failed: \(error)")
            } else {
                print("Connection failed: No error")
            }
            connectedPeripheral = nil
            let peripheralInfo = DeviceDetails(peripheral)
            delegate?.failedWithError(peripheralInfo, errorCode: .FAILED_TO_CONNECT)
            return
        }
//        delegate?.failedToConnectWithError(peripheral, error: error!)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscover services called")
//        connectedPeripheral = peripheral
//        if error != nil {
//            print("Discover Services Error:\(error?.localizedDescription ?? "")")
//            return;
//        }
        
        if let connectedPeri = connectedPeripheral,
           connectedPeri.identifier == peripheral.identifier {
            if let error = error {
                print("DiscoverServices failed: \(error)")
                connectedPeripheral = nil
                let peripheralInfo = DeviceDetails(peripheral)
                delegate?.failedWithError(peripheralInfo, errorCode: .FAILED_TO_DISCOVER_SERVICES)
                return
            } else {
                print("DiscoverServices failed: No error")
            }
        }
        
        connectedPeripheral = peripheral
        
        // If discover services, then invalidate the timeout monitor
        if handshakeTimer != nil {
            handshakeTimer?.invalidate()
            handshakeTimer = nil
        }

        self.discoverCharacteristics()
        self.delegate?.didDiscoverServices(peripheral)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor service called")
        if error != nil {
            print("Fail to discover characteristics! Error: \(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverCharacteritics(error!)
            return
        }
        
        characteristicsDic[service.uuid] = service.characteristics

        if characteristicsDic.keys.contains(.proteusUUID) {
            
            let cbCharacteristic: [CBCharacteristic] = characteristicsDic[.proteusUUID]!
            
            for readChar in cbCharacteristic {
                if readChar.cbCharacteristicName == CBUUID.PLIPReadUUID.cbUUIDName {
                    //bleGateway.discoverDescriptor(readChar)
                    self.readCharacteristic = readChar
                }
                if readChar.cbCharacteristicName == CBUUID.PLIPWriteUUID.cbUUIDName {
                    //bleGateway.discoverDescriptor(readChar)
                    self.writeCharacteristic = readChar
                }
            }
            
            if self.readCharacteristic != nil, self.writeCharacteristic != nil {
                self.discoverDescriptor(self.readCharacteristic!)
            }
            assert(cbCharacteristic != nil, "The Characteristic CAN'T be nil")
            //self.title = characteristic?.name
        }
        
//        delegate?.didDiscoverCharacteritics(service)
    }
    
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor characteristic called")
        if error != nil {
            print("Fail to discover descriptor for characteristic Error:\(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverDescriptors(error!)
            return
        }
        
        if characteristic.cbCharacteristicName == CBUUID.PLIPReadUUID.cbUUIDName {
            self.readCharacteristic = characteristic
            self.isListening = true
            self.setNotification(enable: self.isListening, forCharacteristic: self.readCharacteristic!)
            if isStateRestored {
                isStateRestored = false
                restoredPeripheral = nil
            }
            
            for peripheral in nearbyPeripheralInfos {
                if peripheral.peripheral.name == connectedPeripheral?.name {
                    delegate?.didDiscoverPeripheral(peripheral)
                }
            }
        }
        
        if characteristic.cbCharacteristicName == CBUUID.PLIPReadUUID.cbUUIDName {
            self.writeCharacteristic = characteristic
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnect peripheral called")
        connected = false
        
        //noOfReconnectAttempt <= reconnectAttemptCount!
        if noOfReconnectAttempt == reconnectAttemptCount {
            //bleGateway.connectPeripheral(peripheral)
//            isConnecting = false
            if connectionTimer != nil {
                connectionTimer!.invalidate()
                connectionTimer = nil
            }
            connected = false
            delegate?.failedToConnect(.FAILED_TO_RECONNECT, attemptCount: noOfReconnectAttempt)
        } else if !isStateRestored {
            self.delegate?.didDisconnectPeripheral(peripheral)
        }
        
        notifCenter.post(name: NSNotification.Name(rawValue: DisconnectNotif), object: self)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor characteristic called")
        if error != nil {
            print("Failed to read value for the characteristic. Error:\(error!.localizedDescription)")
            delegate?.didFailToReadValueForCharacteristic(error!)
            return
        }
            
        if characteristic.value != nil && characteristic.value!.count != 0 {
            let data = characteristic.value!
            
            let charSet = CharacterSet(charactersIn: "<>")
            let nsdataStr = NSData.init(data: data)
            let str = nsdataStr.description.trimmingCharacters(in:charSet).replacingOccurrences(of: " ", with: "")
            print(str) // you will get String or Hex value (if its Hex need one more conversion)

//            let str = String(decoding: data, as: UTF8.self)
            print(data)

            let rangeOfData = (data.description.index(after: data.description.startIndex) ..< data.description.index(before: data.description.endIndex))
                print(data.description[rangeOfData])
        } else {
//            timeAndValues[timeStr] = "No value"
        }

        print("Read Data :",characteristic)
        delegate?.didReadValueForCharacteristic(characteristic)
        
    }
    
    public func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {

        print("didUpdateNotificationStateFor characteristic called, status: \(characteristic.isNotifying)")
    }
    
}

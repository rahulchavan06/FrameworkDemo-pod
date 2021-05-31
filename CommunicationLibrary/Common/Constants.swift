//
//  Constants.swift
//  CommunicationLibrary
//
//  Created by Rahul C. on 08/04/21.
//  Copyright © 2021 Harman. All rights reserved.
//

import Foundation

let PLIP_VERSION_REQ = "0x01"
let PLIP_VERSION_CFM = "0x02"
let PLIP_TERMINATE_REQ = "0x12"
let PLIP_TERMINATE_CFM = "0x13"
let PLIP_STREAMING_DATA_REQ = "0x16"
let PLIP_STREAMING_DATA_CFM = "0x17"
let PLIP_STOP_STREAM_DATA_REQ = "0x1C"
let PLIP_STOP_STREAM_DATA_CFM = "0x1D"
let PLIP_PRIORITIZED_STREAM_DATA_REQ = "0x48"
let PLIP_PRIORITIZED_STREAM_DATA_CFM = "0x49"

let DisconnectNotif = "disconnectedPeripheral"
let centralRestoreIdentifier = "io.otuska.bleConnect.CentralManager"
let peripheralRestoreIdentifier = "io.otuska.bleConnect.PeripheralManager"
let connectedPeripheralUserDefaultIdentifier = "connectedPeripheral"


let defaultBLEScanningTimeOut: TimeInterval = 120 // Scanning timeout of 2 minutes for BLEPatchClient
let defaultSimulatorScanningTimeOut: TimeInterval = 30 // Scanning timeout of 30 seconds for SimulatorPatchClient

let attemptCount = "retryAttemptCount"


//keys
let errorMessageKey = "ErrorMessage"

// Patch
let patchManagerInitWithoutLoginMessage = "Tried to initialize PatchManager without login."
let patchManagerInitWithDifferentPurposeMessage = "Wrong usage of Patch Manager initialization."
let patchManagerNotInitializedMessage = "patchManager is not initialized."

let connectToInvalidPatchMessage = "Tried to connect Invalid Patch"
let connectToNilPatchPeripheralMessage = "Tried to connect with nil CBPeripheral object."
let connectToNotFoundPatchMessage = "Tried to connect patch which is not in found patches."
let connectToFinalUploadPatchMessage = "Tried to connect patch which has already completed/ canceled final upload."
let patchTryingToConnectMessage = "Patch is already trying to connect."

let disconnectToNotConnectedPatchMessage = "Tried to disconnect patch which is not in currently connected patches."
let disconnectToFinalUploadPatchMessage = "Tried to disconnect patch which has already completed/ canceled final upload."
let errorWhileStoringDataInDB = "Error occured while storing data in masterManagedObjectContext."


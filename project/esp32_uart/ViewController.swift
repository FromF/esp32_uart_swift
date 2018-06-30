//
//  ViewController.swift
//  esp32_uart
//
//  Created by 藤　治仁 on 2018/07/01.
//  Copyright © 2018年 Personal. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController , CBCentralManagerDelegate , CBPeripheralDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    private var centralManager: CBCentralManager!
    private let targetLocalName = "UART Service"
    private var targetPeripheral: CBPeripheral!
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeCBCentralManager()
        
        labelWrite(text: "initialize")
        sendButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- UIButton
    @IBAction func sendButtonAction(_ sender: UIButton) {
        let sendText = "send Data"
        if let sendData = sendText.data(using: .utf8, allowLossyConversion: true) , let characteristic = writeCharacteristic {
            targetPeripheral.writeValue(sendData, for: characteristic, type: .withResponse)
        }
    }
    
    //MARK:- Label
    private func labelWrite(text:String) {
        if Thread.isMainThread {
            statusLabel.text = text
        } else {
            DispatchQueue.main.async {
                self.statusLabel.text = text
            }
        }
    }

    //MARK:- CBCentralManagerDelegate
    private func initializeCBCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    private func scanForPeripherals() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        labelWrite(text: "Scaning...")
    }
    
    private func connectPeripheral() {
        centralManager.connect(targetPeripheral, options: nil)
        labelWrite(text: "Connecting...")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            debugLog("poweredOff")
        case .unknown:
            debugLog("unknown")
        case .resetting:
            debugLog("resetting")
        case .unsupported:
            debugLog("unsupported")
        case .unauthorized:
            debugLog("unauthorized")
        case .poweredOn:
            debugLog("poweredOn")
            scanForPeripherals()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uuid = UUID(uuid: peripheral.identifier.uuid)
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            debugLog("UUID=[\(uuid)] Name=[\(localName)")
            if localName == targetLocalName {
                targetPeripheral = peripheral
                connectPeripheral()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        sendButton.isEnabled = true
        peripheralDiscoverServices()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            debugLog("error:unkown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        scanForPeripherals()
    }
    
    //MARK:- CBPeripheralDelegate
    private func peripheralDiscoverServices() {
        targetPeripheral.delegate = self
        targetPeripheral.discoverServices(nil)
        labelWrite(text: "Serach Service...")
    }
    
    private func peripheralDiscoverCharacteristics(service: CBService) {
        targetPeripheral.discoverCharacteristics(nil, for: service)
    }
    
    private func peripheralNotifyStart() {
        if let characteristic = notifyCharacteristic {
            targetPeripheral.setNotifyValue(true, for: characteristic)
        }
    }

    private func peripheralNotifyStop() {
        if let characteristic = notifyCharacteristic {
            targetPeripheral.setNotifyValue(false, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            if let services = peripheral.services {
                for service in services {
                    debugLog("service uuid = \(service.uuid.uuidString)")
                    peripheralDiscoverCharacteristics(service: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            var str = "Characteristic"
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    debugLog("characteristic = \(characteristic)")
                    switch characteristic.properties {
                    case .read:
                        debugLog("read")
                        readCharacteristic = characteristic
                        str += "[r]"
                    case .write:
                        debugLog("write")
                        writeCharacteristic = characteristic
                        str += "[w]"
                    case .notify:
                        debugLog("notify")
                        notifyCharacteristic = characteristic
                        peripheralNotifyStart()
                        str += "[n]"
                    default:
                        debugLog("unknown")
                    }
                }
                labelWrite(text: str)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            debugLog("ok")
            labelWrite(text: "send ok")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            debugLog("ok")
            labelWrite(text: "notify ok")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugLog("error:\(error)")
        } else {
            if let value = characteristic.value , let str = String(data: value, encoding: .utf8) {
                debugLog("\(str)")
            }
        }
    }
}


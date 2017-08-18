//
//  IRRemoteController.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class IRRemoteController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource{
    
    
    
    @IBOutlet weak var deviceChoose: UIPickerView!
    
    var deviceInfo = Dictionary<String, Any>.init()
    
    @IBOutlet weak var timeForInterval: UILabel!
    
    @IBOutlet weak var timeStep: UIStepper!
    
    @IBOutlet weak var key_num: UITextField!
    
    @IBOutlet weak var codeIndex: UITextField!
    @IBOutlet weak var favoriteNum: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        timeForInterval.text = timeStep.value.description + "毫秒";
        // Do any additional setup after loading the view.
    }
    
    @IBAction func test(_ sender: Any) {
        let deviceType = RemoteDevice.init(rawValue: UInt(deviceChoose.selectedRow(inComponent: 0)))
        let deviceIndexStrings = ToolsFuntion.getAllDeviceNum(withDeviceType: deviceType!)
        
//        let deviceIndexString = codeIndex.text
        
        let functionsStrs = ToolsFuntion.getfuntionOrder(deviceType!)
        let deviceID = "IRRemoteControllerA"
        var commands = Array<String>.init()
        deviceIndexStrings?.forEach({ (deviceIndexString) in
            guard deviceIndexString != "125" && deviceIndexString != "158" && deviceIndexString != "023" else{
                return
            }
            functionsStrs?.forEach({ (funStr) in
                    autoreleasepool(invoking: { () -> Void in
                        let codeString =  ToolsFuntion.getFastCodeDeviceIndex(deviceIndexString, deviceType: deviceType!, keynum: UInt(funStr)!)
                        print(codeString!)
                    })
                    
                
//                let codeString =  ToolsFuntion.getFastCodeDeviceIndex(deviceIndexString, deviceType: deviceType!, keynum: UInt(funStr)!)
//                print(codeString!)
//                commands.append(codeString!)
//                BluetoothManager.getInstance()?.sendByteCommand(with: codeString!, deviceID: deviceID!, sendType: .remoteNew, success: { (data) in
//                    print(data!)
//                }, fail: { (failcode) -> UInt in
//                    return 0
//                })
            })
        })
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID, sendType: .remoteNew, commands: commands, success: { (deviceIndex, data) in
            
        }, fail: { (failCode) -> UInt in
            return 0
        }, finish: { (finish) in
            
        })
        
        
    }
    
    @IBAction func sendFastCode(_ sender: UIButton) {
        let deviceType = RemoteDevice.init(rawValue: UInt(deviceChoose.selectedRow(inComponent: 0)))
        let deviceIndexString = codeIndex.text
        let keynum = UInt(key_num.text!)
        let codeString =  ToolsFuntion.getFastCodeDeviceIndex(deviceIndexString, deviceType: deviceType!, keynum: keynum!)
        let deviceID = self.deviceID(with: self.deviceInfo)
        BluetoothManager.getInstance()?.sendByteCommand(with: codeString!, deviceID: deviceID!, sendType: .remoteNew, success: { (data) in
            print(data!)
        }, fail: { (failcode) -> UInt in
            return 0
        })
    }
    
    @IBAction func sendDownload(_ sender: UIButton) {
        let deviceType = RemoteDevice.init(rawValue: UInt(deviceChoose.selectedRow(inComponent: 0)))
        let deviceIndexString = codeIndex.text
        let codeStrings = ToolsFuntion.getDownloadCode(withDeviceIndex: deviceIndexString, deviceType: deviceType!)
        let deviceID = self.deviceID(with: self.deviceInfo)
        
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID!, sendType: .remoteNew, commands: codeStrings, success: { (deviceIndex, data) in
            
        }, fail: { (failcode) -> UInt in
            return 0
        }, finish: { (isFinish) in
            
        })
        
    }
    
    @IBAction func sendfFavorite(_ sender: UIButton) {
        let deviceType = RemoteDevice.init(rawValue: UInt(deviceChoose.selectedRow(inComponent: 0)))
        ToolsFuntion.getFavoriteCode(withDeviceIndex: "255", deviceType: deviceType!, channelIndex: favoriteNum.text!)
    }
    
    
    @IBAction func changeInterval(_ sender: UIStepper) {
        timeForInterval.text = sender.value.description + "毫秒";
        BluetoothManager.getInstance()?.setInterval(sender.value/1000)
    }
    

    @IBAction func foundRemote(_ sender: UIButton) {
        sender.isEnabled = false
        let command = ("254168" as NSString).full(withLengthCountBehide: 57)
        let deviceID = self.deviceID(with: self.deviceInfo)
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID!, sendType: .remoteNew, commands: [command!], success: { (data) in
            sender.isEnabled = true
        }, fail: { (failCode) -> UInt in
            sender.isEnabled = true
            return 0
        })
    }
    
    
    
    func deviceID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        let deviceID =  advdic.object(forKey: "kCBAdvDataLocalName") as! String
        let indexOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 7)
        let deviceMACID = deviceID.substring(from: indexOfDeviceID)
        return deviceMACID
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return ["TV","DVD","AUX","SAT"][row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}

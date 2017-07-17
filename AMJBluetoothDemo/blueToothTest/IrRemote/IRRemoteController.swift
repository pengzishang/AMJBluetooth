//
//  IRRemoteController.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class IRRemoteController: UIViewController {

    var deviceInfo = Dictionary<String, Any>.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func didFinishEdit(_ sender: UITextField) {
        //254 168 001 003 002 001 002 189 001
        if sender.text?.characters.count == 0 {
            let command = ("254168001003002001002189001" as NSString).full(withLengthCountBehide: 57)
            sender.text = command
            let deviceID = self.deviceID(with: self.deviceInfo)

            
            BluetoothManager.getInstance()?.sendByteCommand(with: command!, deviceID: deviceID!, sendType: .remoteNew, retryTime: 3, success: { (data) in
                print(data!)
            }, fail: { (failcode) -> UInt in
                return 0
            })
        }
        else
        {
            let command = sender.text
            sender.text = command
            let deviceID = self.deviceID(with: self.deviceInfo)
            
            BluetoothManager.getInstance()?.sendByteCommand(with: command!, deviceID: deviceID!, sendType: .remoteNew, retryTime: 3, success: { (data) in
                print(data!)
            }, fail: { (failcode) -> UInt in
                return 0
            })
        }
        
    }
    
    @IBAction func sendQuickCommand(_ sender: UIButton) {
        let command = ("254168001003002001002189001" as NSString).full(withLengthCountBehide: 57)
        let deviceID = self.deviceID(with: self.deviceInfo)
        
        BluetoothManager.getInstance()?.sendByteCommand(with: command!, deviceID: deviceID!, sendType: .remoteNew, retryTime: 3, success: { (data) in
            print(data!)
        }, fail: { (failcode) -> UInt in
            return 0
        })
    }
    @IBAction func mutiCommands(_ sender: UITextField) {
        if sender.text?.characters.count == 0 {
            let command1 = ("254168001003002001002189001" as NSString).full(withLengthCountBehide: 57)
            let command2 = ("254168001003002001002189002" as NSString).full(withLengthCountBehide: 57)
            let command3 = ("254168001003002001002189003" as NSString).full(withLengthCountBehide: 57)
            let command4 = ("254168001003002001002189004" as NSString).full(withLengthCountBehide: 57)
            let command5 = ("254168001003002001002189005" as NSString).full(withLengthCountBehide: 57)
            let commandarr = [command1,command2,command3,command4,command5]
            sender.text = command1
            let deviceID = self.deviceID(with: self.deviceInfo)
            
            BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID!, sendType: .remoteNew, retryTime: 3 ,commands: commandarr as! [String], success: { (data) in
                
            }, fail: { (failCode) -> UInt in
                return 0
            })
        }
        else
        {
            let command = sender.text
            let deviceID = self.deviceID(with: self.deviceInfo)
            
            BluetoothManager.getInstance()?.sendByteCommand(with: command!, deviceID: deviceID!, sendType: .remoteNew, retryTime: 3, success: { (data) in
                print(data!)
            }, fail: { (failcode) -> UInt in
                return 0
            })
        }
        
    }
    
    @IBAction func sendMutiCommands(_ sender: UIButton) {
        let command1 = ("254168001003002001002189001" as NSString).full(withLengthCountBehide: 57)
        let command2 = ("254168001003002001002189002" as NSString).full(withLengthCountBehide: 57)
        let command3 = ("254168001003002001002189003" as NSString).full(withLengthCountBehide: 57)
        let command4 = ("254168001003002001002189004" as NSString).full(withLengthCountBehide: 57)
        let command5 = ("254168001003002001002189005" as NSString).full(withLengthCountBehide: 57)
        let commandarr = [command1,command2,command3,command4,command5]
        
        let deviceID = self.deviceID(with: self.deviceInfo)
        
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID!, sendType: .remoteNew, retryTime: 3, commands: commandarr as! [String], success: { (data) in
            
        }, fail: { (failCode) -> UInt in
            return 0
        })
    }
    
    @IBAction func foundRemote(_ sender: UIButton) {
        let command = ("254168" as NSString).full(withLengthCountBehide: 57)
        let deviceID = self.deviceID(with: self.deviceInfo)
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: deviceID!, sendType: .remoteNew, retryTime: 3, commands: [command!], success: { (data) in
            
        }, fail: { (failCode) -> UInt in
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

//
//  SendController.swift
//  blueToothTest
//
//  Created by 彭子上 on 2016/11/25.
//  Copyright © 2016年 彭子上. All rights reserved.
//

import UIKit

class SendController: UIViewController {
    public var deviceInfo = Dictionary<String, Any>.init()
    let test = BluetoothManager.getInstance()//初始化
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var command: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(deviceInfo)
        let deviceAdv = deviceInfo[AdvertisementData] as! Dictionary<String,Any>
        let deviceID = deviceAdv["kCBAdvDataLocalName"] as! String
        navTitle.title=deviceID
        // Do any additional setup after loading the view.
    }
    @IBAction func send(_ sender: Any) {
        let deviceAdv = deviceInfo[AdvertisementData] as! Dictionary<String,Any>
        let deviceID = deviceAdv["kCBAdvDataLocalName"] as! String
        let indexOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 7)
        let deviceMACID = deviceID.substring(from: indexOfDeviceID)
        
        if deviceID.contains("Name26") {
            command.text = "203237038002002000001000000000"
            test?.sendByteCommand(with: command.text!, deviceID: deviceMACID, sendType: .sellMachine, retryTime: 3, success: { (data) in
                print("成功后的返回值:" + (data?.description)!)
            }, fail: { (failStr) -> UInt in
                return 0
            })
        }
        else
        {
            test?.sendByteCommand(with: command.text!, deviceID: deviceID, sendType: SendType.single, retryTime: 3, success: { (stateCode) in
                print(stateCode!)
            }, fail: { (errorCode) -> UInt in
                let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + errorCode!, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: {
                    
                })
                return 0
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

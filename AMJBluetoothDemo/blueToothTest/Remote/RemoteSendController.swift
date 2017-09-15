//
//  RemoteSendController.swift
//  blueToothTest
//
//  Created by pzs on 2017/9/14.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class RemoteSendController: UIViewController {
    
    public var deviceInfo = Dictionary<String, Any>.init()
    
    @IBOutlet weak var targetServer: UILabel!
    @IBOutlet weak var targetRemote: UILabel!
    @IBOutlet weak var targetDevice: UILabel!
    @IBOutlet weak var commandText: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var resultLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let deviceID =  (deviceInfo["advertisementData"] as! Dictionary<String, Any>)["kCBAdvDataLocalName"] as! String
        targetDevice.text = deviceID
        targetRemote.text = "远程控制器:" + (UserDefaults.standard.object(forKey: "Remote") as! String)
        targetServer.text = "服务器:" + (UserDefaults.standard.object(forKey: "Server") as! String)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendCommand(_ sender: UIButton) {
        let serverAdd  = UserDefaults.standard.object(forKey: "Server") as? String
        let wifiMac  = UserDefaults.standard.object(forKey: "Remote") as? String
        var servicesURL = ""
        if serverAdd != nil {
            servicesURL = "http://" + serverAdd! + "/PMSWebService/services/"
            UserDefaults.standard.set(servicesURL, forKey: "servicesURL")
        }
        else {
            UserDefaults.standard.set("120.24.223.86", forKey: "Server")
            servicesURL = "http://120.24.223.86/PMSWebService/services/"
            UserDefaults.standard.set(servicesURL, forKey: "servicesURL")
        }
        
        if wifiMac != nil
        {
            self.sendCommand(with: wifiMac!)
        }
        else {
            let alert = UIAlertController.init(title: "错误", message: "没有绑定远程控制器", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
                return
            }))
            self.dismiss(animated: true, completion: {
                return
            })
        }
        
    }
    
    func sendCommand(with wifiMac:String) -> Void {
        var deviceID =  (deviceInfo["advertisementData"] as! Dictionary<String, Any>)["kCBAdvDataLocalName"] as! NSString
        deviceID = deviceID.substring(from: 7) as NSString
        sendBtn.isEnabled = false
        NewRemote.getInstance()?.lockControl(withPassword: commandText.text!, deviceID: deviceID as String, endtime: "2018-09-13 00:00:00", success: { (data) in
            self.resultLab.text = data as? String
            self.sendBtn.isEnabled = true
        }, fail: { (failCode) in
            self.resultLab.text = failCode!
            self.sendBtn.isEnabled = true
        })
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

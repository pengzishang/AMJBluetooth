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
    
    @IBOutlet weak var commandText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendCommand(_ sender: UIButton) {
        let serverAdd  = UserDefaults.standard.object(forKey: "Server") as? String
        let wifiMac  = UserDefaults.standard.object(forKey: "Remote") as? String
        var servicesURL = ""
//        servicesURL
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
            let alert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "", style: .default, handler: { (action) in
                return
            }))
            self.dismiss(animated: true, completion: {
                return
            })
        }
        
    }
    
    func sendCommand(with wifiMac:String) -> Void {
        NewRemote.getInstance()?.lockControl(withPassword: "123456", deviceID: "", endtime: "", success: { (data) in
            
        }, fail: { (failCode) in
            
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

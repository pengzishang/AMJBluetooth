//
//  WIFIController.swift
//  blueToothTest
//
//  Created by pzs on 2017/9/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class WIFIController: UIViewController {

    var deviceInfo = Dictionary<String, Any>.init()
    
    
    @IBOutlet weak var deviceLab: UILabel!
    
    @IBOutlet weak var pwd: UITextField!
    
    @IBOutlet weak var activtion: UIActivityIndicatorView!
    
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deviceLab.text = self.deviceID(with: self.deviceInfo)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startOpertion(_ sender: UIButton) {
        let manger = HiJoine.init()
        manger.setBoardDataWithPassword(self.pwd.text!) { (result, message) in
            print(result.description + "  :  " + message!)
        }
        
    }
    
    
    
    @IBAction func changeMode(_ sender: UIButton) {
        sender.isEnabled = false
        BluetoothManager.getInstance()?.sendByteCommand(with: "01", deviceID: self.deviceID(with: self.deviceInfo), sendType: .single, success: { (data) in
            sender.isEnabled = false
            sender.setTitle("已经切换", for: .normal)
            self.startBtn.isEnabled = true
            self.pwd.isEnabled = true
        }, fail: { (failCode) -> UInt in
            sender.setTitle("请重试", for: .normal)
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

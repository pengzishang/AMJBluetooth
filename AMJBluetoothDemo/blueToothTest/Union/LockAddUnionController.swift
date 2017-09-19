//
//  LockAddUnionController.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/3.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class LockAddUnionController: UITableViewController {
    ///数据库中数据
    var devices = Array<Dictionary<String, String>>.init()
    var deviceInfo = Dictionary<String, Any>.init()//锁的信息
    var notExist = Array<Dictionary<String, Any>>.init()
    
    /// 周边设备
    let allDevice = BluetoothManager.getInstance()?.peripheralsInfo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(deviceInfo)
        allDevice?.forEach({ (singleDeviceInfo) in
            
            let deviceTypeString = self.deviceType(with: singleDeviceInfo as! Dictionary<String, Any>)
            
            if Int(deviceTypeString!) != nil
            {
                let deviceTypeInt = Int(deviceTypeString!)
                
                guard (deviceTypeInt! <= 5 || (deviceTypeInt! <= 13&&deviceTypeInt! >= 11) || (deviceTypeInt! <= 23&&deviceTypeInt! >= 21))else
                {
                    return
                }
            }
            
            
            let deviceFullName = self.deviceFullID(with: singleDeviceInfo as! Dictionary<String, Any>)
            guard (deviceFullName?.contains("Name"))! else{
                return
            }
            
            if devices.contains(where: { (dic) -> Bool in
                return dic["deviceID"] == deviceFullName ? true:false
            }) == false
            {
                notExist.append(singleDeviceInfo as! [String : Any])
            }
        })
        
        self.tableView.reloadData()

    }
    
    func deviceID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        let deviceID =  advdic.object(forKey: "kCBAdvDataLocalName") as! String
        let indexOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 7)
        let deviceMACID = deviceID.substring(from: indexOfDeviceID)
        return deviceMACID
    }
    
    func deviceType(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        let deviceID =  advdic.object(forKey: "kCBAdvDataLocalName") as! String
        let startOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 4)
        let devicesub1 = deviceID.substring(from: startOfDeviceID)
        let endOfDeviceID = devicesub1.index(devicesub1.startIndex, offsetBy: 2)
        let deviceType = devicesub1.substring(to: endOfDeviceID)
        return deviceType
    }
    
    func deviceFullID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        return advdic.object(forKey: "kCBAdvDataLocalName") as! String?
    }
    
    func lockID() -> String! {
        return self.deviceID(with: self.deviceInfo)
    }
    
    
    
    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notExist.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        let deviceID = cell.viewWithTag(1001) as! UILabel
        deviceID.text = self.deviceFullID(with: notExist[indexPath.row])
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController.init(title: "状态", message: "输入要设定的状态", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            
            if UserDefaults.standard.array(forKey: self.lockID()) as? Array<Dictionary<String, String>> != nil{
                var deviceArray =  UserDefaults.standard.array(forKey: self.lockID()) as! Array<Dictionary<String, String>>
                deviceArray.append(["deviceID":self.deviceFullID(with: self.notExist[indexPath.row]),"deviceStatus":(alert.textFields?.first?.text)!])
                UserDefaults.standard.set(deviceArray, forKey: self.lockID())
            }
            else
            {
                var deviceArray = Array<Dictionary<String, String>>.init()
                deviceArray.append(["deviceID":self.deviceFullID(with: self.notExist[indexPath.row]),"deviceStatus":(alert.textFields?.first?.text)!])
                UserDefaults.standard.set(deviceArray, forKey: self.lockID())
            }
            
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true) {
            
        }
    }

}

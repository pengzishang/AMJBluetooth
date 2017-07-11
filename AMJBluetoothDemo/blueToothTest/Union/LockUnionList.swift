//
//  LockUnionList.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/3.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class LockUnionList: UITableViewController {
    var deviceInfo = Dictionary<String, Any>.init()
    
    var devices = Array<Dictionary<String, String>>.init()
    var globalBtn = UIButton.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.array(forKey: self.deviceID(with: self.deviceInfo)) as? Array<Dictionary<String, String>> != nil {
            devices =  UserDefaults.standard.array(forKey: self.deviceID(with: self.deviceInfo)) as! Array<Dictionary<String, String>>
            self.tableView.reloadData()
        }
        
    }

    func deviceFullID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        return advdic.object(forKey: "kCBAdvDataLocalName") as! String?
    }
    
    func deviceID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        let deviceID =  advdic.object(forKey: "kCBAdvDataLocalName") as! String
        let indexOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 7)
        let deviceMACID = deviceID.substring(from: indexOfDeviceID)
        return deviceMACID
    }

    @IBAction func relatLock(_ sender: UIButton) {
        self.performSegue(withIdentifier: "lockList", sender: nil)
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        let lockID  = self.deviceID(with: self.deviceInfo)
        var command :NSString = "003001"
        command = command.full(withLengthCountBehide: 30)! as NSString
        BluetoothManager.getInstance()?.sendByteCommand(with: command as String, deviceID: lockID!, sendType: .lock, success: { (data) in
            
        }, fail: { (failCode) -> UInt in
            
            return 0
        })
    }
    
    @IBAction func addUnion(_ sender: UIButton) {
        self.performSegue(withIdentifier: "lockaddunion", sender: nil)
    }
    
   
    @IBAction func record(_ sender: UIButton) {
        
        sender.isHidden = true
        let acitionIndicator = sender.superview?.superview?.viewWithTag(1003) as! UIActivityIndicatorView
        acitionIndicator.startAnimating()
        let deviceIndex = (sender.superview?.superview?.tag)! - 10000
        let lockID  = self.deviceID(with: self.deviceInfo)
        var deviceID = (sender.superview?.superview?.viewWithTag(1001) as! UILabel).text! as NSString
        deviceID = deviceID.substring(from: 7) as NSString
        var command = "003000" + (devices[deviceIndex]["deviceStatus"]! as NSString ).full(withLengthCount: 3)
        command.append(NSString.convertMacID(deviceID as String!, reversed: true))
        command.append("255")
        
        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: lockID!, sendType: .lock, success: { (data) in
            sender.isHidden = false
            acitionIndicator.stopAnimating()
        }, fail: { (failCode) -> UInt in
            sender.isHidden = false
            acitionIndicator.stopAnimating()
            return 0
        })
        
    }
        // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == devices.count{
            return 100
        }
        else
        {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == devices.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "func", for: indexPath)
            let deviceInfoID = cell.viewWithTag(1001) as! UILabel
            deviceInfoID.text = "当前取电器: " + self.deviceFullID(with: deviceInfo)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
            cell.tag = 10000 + indexPath.row
            let deviceID = cell.viewWithTag(1001) as! UILabel
            let deviceStatus = cell.viewWithTag(1002) as! UILabel
            deviceID.text = devices[indexPath.row]["deviceID"]
            deviceStatus.text = devices[indexPath.row]["deviceStatus"]
            
            return cell

        }
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row != devices.count {
            return true
        }
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            devices.remove(at: indexPath.row)
            UserDefaults.standard.set(devices, forKey: self.deviceID(with: self.deviceInfo))
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockaddunion" {
            let target :LockAddUnionController = segue.destination as! LockAddUnionController
            target.devices = self.devices
            target.deviceInfo = self.deviceInfo
        }
        else if segue.identifier == "lockList" {
            let target :LockListController = segue.destination as! LockListController
            target.deviceInfo = self.deviceInfo
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

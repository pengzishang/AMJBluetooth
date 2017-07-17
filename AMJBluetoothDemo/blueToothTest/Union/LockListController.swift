//
//  LockListController.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/7.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class LockListController: UITableViewController {
    var deviceInfo = Dictionary<String, Any>.init()
    var devices = Array<Dictionary<String, Any>>.init()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devices = {
            var temp = Array<Dictionary<String, Any>>.init()
            BluetoothManager.getInstance()?.peripheralsInfo?.forEach({ (singleDeviceInfo) in
                let lockDeviceID = self.deviceFullID(with: singleDeviceInfo as! Dictionary<String, Any>)
                if (lockDeviceID?.contains("Name08"))!{
                    temp.append(singleDeviceInfo as! [String : Any])
                }
            })
            return temp
        }()
        self.tableView.reloadData()
    }

    @IBAction func setLock(_ sender: UIButton) {
        sender.isHidden = true
        let acitionIndicator = sender.superview?.superview?.viewWithTag(1003) as! UIActivityIndicatorView
        acitionIndicator.startAnimating()
//        let deviceIndex = (sender.superview?.superview?.tag)! - 10000
        let unionID  = self.deviceID(with: self.deviceInfo)
        var lockID = (sender.superview?.superview?.viewWithTag(1001) as! UILabel).text! as NSString
        lockID = lockID.substring(from: 7) as NSString
        let command = "003003000" + NSString.convertMacID(lockID as String!, reversed: true) + "255"

        BluetoothManager.getInstance()?.sendByteCommand(with: command, deviceID: unionID!, sendType: .lock, retryTime: 3, success: { (data) in
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
        // #warning Incomplete implementation, return the number of rows
        return devices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lock", for: indexPath)
        cell.tag = 10000 + indexPath.row
        let deviceDic = devices[indexPath.row]
        let deviceID = cell.viewWithTag(1001) as! UILabel
        
        deviceID.text = self.deviceFullID(with: deviceDic)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  RemoteTestController.swift
//  blueToothTest
//
//  Created by pzs on 2017/9/14.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class RemoteTestController: UITableViewController {
    
    var devicesArray = Array<Dictionary<String, Any>>.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothManager.getInstance()?.peripheralsInfo?.forEach({ (infoDic) in
            let deviceInfo = infoDic as! NSDictionary
            let deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! String
            if deviceID.contains("Name00")||deviceID.contains("Name01")||deviceID.contains("Name02")||deviceID.contains("Name03")||deviceID.contains("Name04")||deviceID.contains("Name05")||deviceID.contains("Name08"){
                self.devicesArray .append(infoDic as! [String : Any])
            }
        })
        self.tableView.reloadData()
        
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlueToothMangerDidDiscoverNewItem), object: nil, queue: nil) { (notice) in
            let infoDic = notice.userInfo;
            let deviceInfo = infoDic! as NSDictionary
            let deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! String
            if deviceID.contains("Name00")||deviceID.contains("Name01")||deviceID.contains("Name02")||deviceID.contains("Name03")||deviceID.contains("Name04")||deviceID.contains("Name05")||deviceID.contains("Name08"){
                self.devicesArray .append(infoDic as! [String : Any])
                self.tableView.reloadData()
            }
            //            print(notice.userInfo!)//userinfo内有信息
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        BluetoothManager.getInstance()?.cleanAllPeripheralsInfo()
        self.devicesArray.removeAll()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "附近的设备"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "remotecell", for: indexPath)
        let infoDic = self.devicesArray[indexPath.row]
        let deviceInfo = infoDic as NSDictionary
        let deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! String
        let deviceLab = cell.viewWithTag(1000) as! UILabel
        deviceLab.text = deviceID
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let infoDic = self.devicesArray[indexPath.row]
        self.performSegue(withIdentifier: "testremote", sender: infoDic)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "testremote" {
            let target = segue.destination as! RemoteSendController
            target.deviceInfo = sender as! [String : Any]
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

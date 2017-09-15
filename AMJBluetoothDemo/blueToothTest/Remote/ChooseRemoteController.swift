//
//  ChooseRemoteController.swift
//  blueToothTest
//
//  Created by pzs on 2017/9/14.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class ChooseRemoteController: UITableViewController {
    
    var devicesArray = Array<Dictionary<String, Any>>.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        BluetoothManager.getInstance()?.peripheralsInfo?.forEach({ (infoDic) in
            let deviceInfo = infoDic as! NSDictionary
            let deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! String
            if deviceID.contains("WIFI"){
                self.devicesArray .append(infoDic as! [String : Any])
            }
        })
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlueToothMangerDidDiscoverNewItem), object: nil, queue: nil) { (notice) in
            let infoDic = notice.userInfo;
            let deviceInfo = infoDic! as NSDictionary
            let deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! String
            if deviceID.contains("WIFI"){
                self.devicesArray .append(infoDic as! [String : Any])
                self.tableView.reloadData()
            }
            //            print(notice.userInfo!)//userinfo内有信息
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let infoDic = self.devicesArray[indexPath.row]
        let deviceInfo = infoDic as NSDictionary
        var deviceID = (deviceInfo.object(forKey: AdvertisementData) as! NSDictionary).object(forKey: "kCBAdvDataLocalName") as! NSString
        deviceID = deviceID.replacingOccurrences(of: " ", with: "") as NSString
        deviceID = deviceID.substring(from: 6) as NSString
        UserDefaults.standard.set(deviceID, forKey: "Remote")
        tableView .deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.nanoseconds(300), execute: {
            self.navigationController?.popViewController(animated: true)
        })
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

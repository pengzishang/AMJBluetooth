//
//  TestController.swift
//  blueToothTest
//
//  Created by 彭子上 on 2016/11/25.
//  Copyright © 2016年 彭子上. All rights reserved.
//

import UIKit

class TestController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var mainTableView: UITableView!
    var devicesArray = Array<Dictionary<String, Any>>.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlueToothMangerDidDiscoverNewItem), object: nil, queue: nil) { (notice) in
            let infoDic = notice.userInfo;
            let isContain = (infoDic?["isContain"] as! NSNumber).boolValue
            if !isContain {
                self.devicesArray.append(notice.userInfo as! [String : Any])
                self.mainTableView.reloadData()
            }
//            print(notice.userInfo!)//userinfo内有信息
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlueToothMangerDidRefreshInfo), object: nil, queue: nil) { (notice) in
            self.devicesArray = notice.object as! Array<Dictionary<String, Any>>
            self.mainTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        BluetoothManager.getInstance()?.cleanAllPeripheralsInfo()
        self.devicesArray.removeAll()
        self.mainTableView.reloadData()
    }
    
    
    
    @IBAction func test(_ sender: UIBarButtonItem) {
//        BluetoothManager.getInstance()?.sendMutiCommands(["192","192","192","192"], withMutiDevices: ["7CEC79486F6B","7CEC794873D7","7CEC794873DD","D0B5C2A405CF"], withSendTypes: [(0),(0),(0),(0)], report: { (index, isSuccess, userInfo) in
//
//        }, finish: { (finish) in
//            print("完成")
//        })
        
        BluetoothManager.getInstance()?.notify(withID: "BB2707-30_0010", success: {
            
        }, fail: { (failCode) in
            
        })
        
    }
    
    @IBAction func startPeripheral(_ sender: UIBarButtonItem) {
        BlueToothPeripheral.getInstance()?.startAdvise()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesArray.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as UITableViewCell;
        let deviceInfoDic=devicesArray[indexPath.row]
        
        let lab1 = cell .viewWithTag(1001) as! UILabel
        let lab2 = cell.viewWithTag(1002) as! UILabel
        lab1.text = self.deviceFullID(with: deviceInfoDic)
        let rssi = deviceInfoDic[RSSI_VALUE] as!NSNumber
        lab2.text = rssi.stringValue;
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "附近的设备"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let deviceInfoDic=devicesArray[indexPath.row]
        if self.deviceFullID(with: deviceInfoDic) .contains("Name08")||self.deviceFullID(with: deviceInfoDic) .contains("AMJe08") {
            self .performSegue(withIdentifier: "viewLock", sender: indexPath)
        }
        else if self.deviceFullID(with: deviceInfoDic) .contains("Name19"){
            self .performSegue(withIdentifier: "union", sender: indexPath)
        }
        else if self.deviceFullID(with: deviceInfoDic) .contains("IrRemoteControllerA"){
            self .performSegue(withIdentifier: "irremote", sender: indexPath)
        }
        else if self.deviceFullID(with: deviceInfoDic).hasPrefix("BB") {
            self .performSegue(withIdentifier: "sellmachine", sender: indexPath)
        }
//        else if self.deviceFullID(with: deviceInfoDic).hasPrefix("WIFI") {
//            self .performSegue(withIdentifier: "wifi", sender: indexPath)
//        }
        else
        {
            self .performSegue(withIdentifier: "chooseVersion", sender: indexPath)
        }
    }

    
    func deviceFullID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        return advdic.object(forKey: "kCBAdvDataLocalName") as! String?
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewLock" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target = segue.destination as! LockViewController
            target.deviceInfo = deviceInfo
        }
        else if segue.identifier == "chooseVersion" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target=segue.destination as! SendController
            target.deviceInfo = deviceInfo
        }
        else if segue.identifier == "union" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target=segue.destination as! LockUnionList
            target.deviceInfo = deviceInfo
        }
        else if segue.identifier == "irremote" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target=segue.destination as! IRRemoteController
            target.deviceInfo = deviceInfo
        }
        else if segue.identifier == "sellmachine" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target=segue.destination as! SellMachineController
            target.deviceInfo = deviceInfo
        }
        else if segue.identifier == "wifi" {
            let deviceInfo=devicesArray[(sender as! NSIndexPath).row]
            let target=segue.destination as! WIFIController
            target.deviceInfo = deviceInfo
        }

        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

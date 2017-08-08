//
//  LockViewController.swift
//  blueToothTest
//
//  Created by pzs on 2017/6/29.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class LockViewController: UITableViewController {
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var deviceInfo = Dictionary<String, Any>.init()
    
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var checkInTimeLab: UILabel!
    @IBOutlet weak var checkInTimeRetryBtn: UIButton!
    
    @IBOutlet weak var checkOutTimeLab: UILabel!
    @IBOutlet weak var checkOutTimeBtn: UIButton!
    
    
    @IBOutlet weak var batteryLifeLab: UILabel!
    @IBOutlet weak var hardWareLab: UILabel!
    @IBOutlet weak var versionLab: UILabel!
    
    
    @IBOutlet weak var timePwdField: UITextField!
    @IBOutlet weak var addPwdField: UITextField!
    @IBOutlet weak var openPwdField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BluetoothManager.getInstance()?.setInterval(1)
        BluetoothManager.getInstance()?.queryDeviceStatus(self.deviceID(with: deviceInfo), success: { (data) in
            let dataStr  = NSString.data(toString: data) as NSString?
            self.batteryLifeLab.text = dataStr?.substring(with: NSMakeRange(8, 2))
            self.hardWareLab.text = dataStr?.substring(with: NSMakeRange(0, 2))
            self.versionLab.text = dataStr?.substring(with: NSMakeRange(2, 6))
            self.getTime()
        }, fail: { (failCode) -> UInt in
            self.getTime()
            let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return 0
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        BluetoothManager.getInstance()?.interruptCurrentOpertion()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.setEditing(false, animated: true)
    }
    
    
    @IBAction func test(_ sender: Any) {
        self.getTime()
    }
    
    @IBAction func test1(_ sender: Any) {
        let code = ToolsFuntion.queryOpenTimeCode()
        BluetoothManager.getInstance()?.sendByteCommand(with: code!, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
            
        }, fail: { (failCode) -> UInt in
            return 0
        })
        
    }
    
    func getTime() -> () {
        let commands = { () -> [String?] in
            let lockTimeCmds = ToolsFuntion.querySYSTimeCode();
            let checkInTimeCmds = ToolsFuntion.queryCheckInTimeCode()
            let checkOutTimeCmds = ToolsFuntion.queryCheckOutTimeCode()
            let temp = [lockTimeCmds,checkInTimeCmds,checkOutTimeCmds]
            return temp
        }()
        BluetoothManager.getInstance()?.sendMutiCommand(withSingleDeviceID: self.deviceID(with: deviceInfo), sendType: .lock, commands: commands as? [String], success: { (deviceIndex, data) in
            if deviceIndex == 0
            {
                if data != nil{
                    self.timeLab.text = self.translateToDate(with: data!)
                }
                
            }
            else if deviceIndex == 1
            {
                if data != nil{
                    self.checkInTimeLab.text = self.translateToDate(with: data!)
                }
                
            }
            else if deviceIndex == 2
            {
                if data != nil{
                    self.checkOutTimeLab.text = self.translateToDate(with: data!)
                }
                
            }//12.8
        }, fail: { (failCode) -> UInt in
            return 0
        }, finish: { (finish) in
            
        })
    }
    
    func translateToDate(with data:Data) -> String! {
        var dateString = NSString.data(toString: data)! as NSString
        dateString = dateString.substring(with: NSMakeRange(10, 10)) as NSString
        dateString = "20" + dateString.description as NSString
//      201708071704
        let year = dateString.substring(to: 4) + "年"
        let month = dateString.substring(with: NSMakeRange(4, 2)) + "月"
        let day = dateString.substring(with: NSMakeRange(6, 2)) + "日"
        let hour = dateString.substring(with: NSMakeRange(8, 2)) + "时"
        let min = dateString.substring(with: NSMakeRange(10, 2)) + "分"
        return year + month + day + hour + min
    }
    
    
    
    @IBAction func retry(_ sender: UIButton) {
        sender.isEnabled = false
        
        let lockTimeCmds = ToolsFuntion.querySYSTimeCode()
        BluetoothManager.getInstance()?.sendByteCommand(with: lockTimeCmds!, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
            sender.isEnabled = true
            self.timeLab.text = self.translateToDate(with: data!)
        }, fail: { (failCode) -> UInt in
            sender.isEnabled = true
            let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return 0
        })
        
    }
    
    @IBAction func checkInTimeRetry(_ sender: UIButton) {
        sender.isEnabled = false
        
        let checkInTimeCmds = ToolsFuntion.queryCheckInTimeCode()
        BluetoothManager.getInstance()?.sendByteCommand(with: checkInTimeCmds!, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
            sender.isEnabled = true
            self.checkInTimeLab.text = self.translateToDate(with: data!)
        }, fail: { (failCode) -> UInt in
            sender.isEnabled = true
            let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return 0
        })
    }
    
    @IBAction func checkOutTimeRetry(_ sender: UIButton) {
        sender.isEnabled = false
        
        let checkOutTimeCmds = ToolsFuntion.queryCheckOutTimeCode()
        BluetoothManager.getInstance()?.sendByteCommand(with: checkOutTimeCmds!, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
            sender.isEnabled = true
            self.checkOutTimeLab.text = self.translateToDate(with: data!)
        }, fail: { (failCode) -> UInt in
            sender.isEnabled = true
            let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return 0
        })
    }
    
    
    @IBAction func batteryLife(_ sender: UIButton) {
        sender.isEnabled = false
        
        BluetoothManager.getInstance()?.queryDeviceStatus(self.deviceID(with: deviceInfo), success: { (data) in
            sender.isEnabled = true
            let dataStr  = NSString.data(toString: data) as NSString?
            self.batteryLifeLab.text = dataStr?.substring(with: NSMakeRange(8, 2))
            self.hardWareLab.text = dataStr?.substring(with: NSMakeRange(0, 2))
            self.versionLab.text = dataStr?.substring(with: NSMakeRange(2, 6))
        }, fail: { (failCode) -> UInt in
            sender.isEnabled = true
            let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            return 0
        })
    }
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if indexPath.section==0{
            if indexPath.row == 4
            {
                self.performSegue(withIdentifier: "history", sender: self.deviceID(with: deviceInfo))
            }
        }
        else if indexPath.section==1 {
            var APPOpertingEnterCommandPrefix: String = "00"
            var APPOpertingEnterCommandAll: String = ""
            
            
            if indexPath.row==0 {
                //开
                APPOpertingEnterCommandPrefix.append("1")
                
                APPOpertingEnterCommandAll = APPOpertingEnterCommandPrefix.appending(NSString.initWith(NSDate(timeIntervalSinceNow: 10000) as Date!, isRemote: false))
                APPOpertingEnterCommandAll = APPOpertingEnterCommandAll.appending(NSString.convertPassWord(openPwdField.text))
                BluetoothManager.getInstance()?.sendByteCommand(with: APPOpertingEnterCommandAll, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
                    
                }, fail: { (failCode) -> UInt in
                    let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: {
                        
                    })
                    return 0
                })
            }
            else if indexPath.row==1 {
                //加密码
                let validTime = TimeInterval(timePwdField.text!)
                APPOpertingEnterCommandPrefix.append("2")
                APPOpertingEnterCommandAll = APPOpertingEnterCommandPrefix.appending(NSString.initWith(NSDate(timeIntervalSinceNow: validTime!) as Date!, isRemote: false))
                APPOpertingEnterCommandAll = APPOpertingEnterCommandAll.appending(NSString.convertPassWord(addPwdField.text))
                BluetoothManager.getInstance()?.sendByteCommand(with: APPOpertingEnterCommandAll, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
                    
                }, fail: { (failCode) -> UInt in
                    let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: {
                        
                    })
                    return 0
                })
            }
            else if indexPath.row==2 {
                //清除密码
                APPOpertingEnterCommandPrefix.append("3")
                APPOpertingEnterCommandAll = APPOpertingEnterCommandPrefix.appending(NSString.initWith(NSDate(timeIntervalSinceNow: 10000) as Date!, isRemote: false))
                APPOpertingEnterCommandAll = APPOpertingEnterCommandAll.appending(NSString.convertPassWord("123456"))
                
                BluetoothManager.getInstance()?.sendByteCommand(with: APPOpertingEnterCommandAll, deviceID: self.deviceID(with: deviceInfo), sendType: .lock, success: { (data) in
                    
                }, fail: { (failCode) -> UInt in
                    let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: {
                        
                    })
                    return 0
                })
            }
            else if indexPath.row==3 {
                //同步时间
                APPOpertingEnterCommandPrefix.append("8")
                APPOpertingEnterCommandAll = APPOpertingEnterCommandPrefix.appending(NSString.initWith(Date.init(), isRemote: false))
                APPOpertingEnterCommandAll.append("000000000")
                
                BluetoothManager.getInstance()?.sendByteCommand(with: APPOpertingEnterCommandAll, deviceID: self.deviceID(with: deviceInfo), sendType: .lock,success: { (data) in
                    
                }, fail: { (failCode) -> UInt in
                    let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: {
                        
                    })
                    return 0
                })
            }
            else if indexPath.row==4 {
                APPOpertingEnterCommandAll = "100255255255255255255255255255"
                BluetoothManager.getInstance()?.sendByteCommand(with: APPOpertingEnterCommandAll, deviceID: self.deviceID(with: deviceInfo), sendType: .lock,success: { (data) in
                    
                }, fail: { (failCode) -> UInt in
                    let alert = UIAlertController.init(title: "发生错误", message: "错误代码:" + failCode!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: {
                        
                    })
                    return 0
                })
            }
        }
        
        
        
        
    }
    
    func deviceID(with infoDic:Dictionary<String, Any>) -> String! {
        let advdic=infoDic[AdvertisementData] as! NSDictionary
        let deviceID =  advdic.object(forKey: "kCBAdvDataLocalName") as! String
        let indexOfDeviceID = deviceID.index(deviceID.startIndex, offsetBy: 7)
        let deviceMACID = deviceID.substring(from: indexOfDeviceID)
        return deviceMACID
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//        let target = segue.destination as! LockUnionList
//        target.deviceInfo = sender as! Dictionary<String, Any>
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

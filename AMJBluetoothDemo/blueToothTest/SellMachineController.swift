//
//  SellMachineController.swift
//  blueToothTest
//
//  Created by pzs on 2017/8/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class SellMachineController: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource{
    var deviceInfo = Dictionary<String, Any>.init()
    var i = 0
    @IBOutlet weak var methoes: UIPickerView!
    
    @IBOutlet weak var dataLab: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var stepper: UIStepper!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Int.init(stepper.value)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 3 : 24
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let datas = ["开门","补货","查询"]
            return datas[row]
        } else {
            let datas = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"]
            return datas[row]
        }
    }
    @IBAction func countOfBox(_ sender: UIStepper) {
        methoes.reloadAllComponents()
    }
    
    @IBAction func sendCommand(_ sender: UIButton) {
        sender.isEnabled = false
        activity.startAnimating()
        let deviceID = self.getDevieID(in: deviceInfo)
        let methoesIndex = methoes.selectedRow(inComponent: 0)
        let doorIndex = { () -> [NSNumber] in
            var temp = Array<NSNumber>.init()
            var count = Int.init(self.stepper.value) - 1
            while count>0 {
                let boxindex = NSNumber.init(value: self.methoes.selectedRow(inComponent: count) + 1)
                temp.append(boxindex)
                count -= 1
            }
            return temp
        }()
        
        
        if methoesIndex == 0  {
            BlueToothMethoes.getInstance().sellMachine_buyGood(withID: deviceID!, goodIndex: doorIndex[0].uintValue, success: { (data) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            }, fail: { (failCode) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            })
        } else if methoesIndex == 1{
            BlueToothMethoes.getInstance().sellMachine_initGoods(withID: deviceID!, includeIndex: doorIndex, success: { (data) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            }, fail: { (failCode) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            })
        } else if methoesIndex == 2{
            BlueToothMethoes.getInstance().sellMachine_query(withID: deviceID!, success: { (data) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            }, fail: { (failCode) in
                sender.isEnabled = true
                self.activity.stopAnimating()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SellMachineUpdataValue), object: nil, queue: nil) { (notice) in
            let openBox = notice.object as! Array<NSNumber> ;
            
            self.dataLab.text = {
                var temp = "已关闭的柜子:"
                openBox.forEach({ (boxIndex) in
                    temp = temp + boxIndex.stringValue + "号 "
                })
                return temp
            }()
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func test(_ sender: UIBarButtonItem) {
        let deviceID = self.getDevieID(in: deviceInfo)
        BlueToothMethoes.getInstance().sellMachine_initGoods(withID: deviceID!, includeIndex: [(6)], success: { (data) in
            
        }) { (failCode) in
            
        }
        
    }
    
    
    
    
    
    
    func getDevieID(in infoDic:Dictionary<String, Any>) -> String! {
        let deviceAdv = infoDic[AdvertisementData] as! Dictionary<String,Any>
        let deviceID = deviceAdv["kCBAdvDataLocalName"] as! String
        return deviceID
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

//
//  IRRemoteController.swift
//  blueToothTest
//
//  Created by pzs on 2017/7/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class IRRemoteController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func didFinishEdit(_ sender: UITextField) {
        
        print(sender.text!)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

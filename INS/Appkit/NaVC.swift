//
//  NaVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/19.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit

class NaVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //导航栏Title颜色
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        //导航栏按钮颜色
        self.navigationBar.tintColor = UIColor.white
        //导航栏背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0  / 255.0, blue: 136.0  / 255.0, alpha: 1)
        //不允许透明
        self.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
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

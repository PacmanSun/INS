//
//  SignInVC.swift
//  INS
//
//  Created by 孙岦 on 2017/11/20.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

class SignInVC: UIViewController {
    @IBOutlet weak var lable: UILabel!
    //text field
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    //button
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)

        lable.frame = CGRect(x: 10, y: 80, width: self.view.frame.width-20, height: 50)
        
        usernameTxt.frame = CGRect(x: 10, y: lable.frame.origin.y + 70, width: self.view.frame.width-20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: self.view.frame.width-20, height: 30)
        
        forgotBtn.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 30, width: self.view.frame.width / 4 - 10, height: 30)
        signInBtn.frame = CGRect(x: 20, y: forgotBtn.frame.origin.y + 40, width: self.view.frame.width / 4, height: 30)
        signUpBtn.frame = CGRect(x: self.view.frame.width - signInBtn.frame.width - 20, y: signInBtn.frame.origin.y, width: signInBtn.frame.width, height: signInBtn.frame.height)
        
        //设置按钮圆角
        signUpBtn.layer.cornerRadius = signUpBtn.frame.width / 20
        signInBtn.layer.cornerRadius = signInBtn.frame.width / 20
        
        //设置字体
        lable.font = UIFont(name: "Pacifico", size: 25)
        //设置背景图
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInBtn_clicked(_ sender: UIButton) {
        print("登陆按钮被单击")
        
        //隐藏键盘
        self.view.endEditing(true)
        //警告对话框
        if usernameTxt.text!.isEmpty ||
            passwordTxt.text!.isEmpty{
            let alert = UIAlertController(title: "请注意", message: "请填写好所有字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        //实现用户登陆功能
        AVUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user:AVUser?, error:Error?) in
            if error == nil{
                //记住用户
                UserDefaults.standard.set(user?.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //调用APPDelegate的login方法
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
         }
    }
    
    // 隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
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

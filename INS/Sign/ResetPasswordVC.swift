//
//  ResetPasswordVC.swift
//  INS
//
//  Created by 孙岦 on 2017/11/20.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBAction func resetBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        
        if emailTxt.text! .isEmpty {
            let alert = UIAlertController(title: "请注意", message: "电子邮件不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success:Bool, error:Error?) in
            if success {
                let alert = UIAlertController(title: "请注意", message: "重置密码已发送到您的邮箱", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTxt.frame = CGRect(x: 10, y: 120, width: self.view.frame.width-20, height: 30)
        
        resetBtn.frame = CGRect(x: 20, y: emailTxt.frame.origin.y + 50, width: self.view.frame.width / 4, height: 30)
        cancelBtn.frame = CGRect(x: self.view.frame.width - resetBtn.frame.width - 20, y: resetBtn.frame.origin.y, width: resetBtn.frame.width, height: resetBtn.frame.height)
        //设置按钮圆角
        resetBtn.layer.cornerRadius = resetBtn.frame.width / 20
        cancelBtn.layer.cornerRadius = cancelBtn.frame.width / 20
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
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

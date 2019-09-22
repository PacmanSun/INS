//
//  EditVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/13.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class EditVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // 根据需要，设置滚动视图的高度
    var scrollViewHeight:CGFloat = 0

    //pickerView pickerData
    var genderPicker:UIPickerView = UIPickerView()
    let genders = ["男","女"]
    
    var keyboard = CGRect()
    
    //设置获取器的组件数量
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //选项数量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    //设置选项Title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    //从获取器取得的Item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    
    @IBAction func save_clicked(_ sender: Any) {
        if !validateEmail(email: emailTxt.text!){
            alert(error: "错误的Email地址", message: "请输入正确的Email地址")
            return
        }
        if !validateWeb(web: webTxt.text!){
            alert(error: "错误的网页链接", message: "请输入正确的网址")
            return
        }
        if !validateMobilePhoneNumber(mobilePhoneNumber: telTxt.text!){
            alert(error: "错误的手机号码", message: "请输入正确的手机号码")
            return
        }
        
        //保存Field信息到服务器
        let user = AVUser.current()
        user?.username = usernameTxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = fullnmeTxt.text?.lowercased()
        user?["web"] = webTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        
        //如果tel为空，则发送“”给mobilePhoneNumber字段，否则传入信息
        if telTxt.text!.isEmpty{
            user?.mobilePhoneNumber = ""
        }else{
            user?.mobilePhoneNumber = telTxt.text
        }
        //如果gender为空，则发送“”给gender字段，否则传入信息
        if genderTxt.text!.isEmpty {
            user?["gender"] = ""
        }else{
            user?["gender"] = genderTxt.text
        }

        //发送用户信息到服务器
        user?.saveInBackground({ (success:Bool, error:Error?) in
            if success{
                //隐藏键盘
                self.view.endEditing(true)
                
                self.dismiss(animated: true, completion: nil)
            }else{
                print(error!.localizedDescription)
            }
        })
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"reload"), object: nil)
    }
    @IBAction func cancel_clicked(_ sender: Any) {
        //隐藏键盘
        self.view.endEditing(true)
        //销毁EditVC
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var fullnmeTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //调用布局
        alignment()
        //调用信息载入
        information()
        
        //在视图中创建PickerView
        //genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        
        scrollViewHeight = self.view.frame.height
        // 检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg(recognizer:)))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //界面布局
    func alignment() -> Void {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaImg.frame = CGRect(x: width - 68 - 10, y: 68, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        fullnmeTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnmeTxt.frame.origin.y + 40, width: width - avaImg.frame.width - 30, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        //创建边线并设置颜色
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        //设置圆角
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
        
        titleLbl.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100, width: width - 20, height: 30)
        
        emailTxt.frame = CGRect(x: 10, y: titleLbl.frame.origin.y + 40, width: width - 20, height: 30)
        telTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telTxt.frame.origin.y + 40, width: width - 20, height: 30)
    }
    
    
    @objc func showKeyboard(notificaton:Notification)  {
        // 定义keyboard大小
        let rect = notificaton.userInfo![UIResponder.keyboardFrameEndUserInfoKey]as!NSValue
        keyboard =  rect.cgRectValue
        // 当虚拟键盘出现以后，将滚动视图的实际高度缩小为屏幕高度减去键盘的高度。
        UIView.animate(withDuration: 0.5, animations:
            {
                //self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
                self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.size.height / 2
        })
    }
    @objc func hideKeyboard(notification:Notification) {
        // 当虚拟键盘消失后，将滚动视图的实际高度改变为屏幕的高度值。
        UIView.animate(withDuration: 0.5, animations:
            {
                //self.scrollView.frame.size.height = self.scrollViewHeight
                self.scrollView.contentSize.height = 0
        })
    }
    
    // 隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
    
    // 调出照片获取器选择照片
    @objc func loadImg(recognizer:UITapGestureRecognizer) -> Void {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    // 关联选择好的照片图像到image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        avaImg.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    // 用户取消获取器操作时调用的方法
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //    self.dismiss(animated: true, completion: nil)
    //}

    //获取用户信息
    func information() -> Void {
        //let ava = AVUser.current()?.object(forKey: "ava") as! AVFile
        let ava = AVUser.current()?.object(forKey: "ava") as! AVFile
        ava.getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                self.avaImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        usernameTxt.text = AVUser.current()?.username
        fullnmeTxt.text = AVUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        emailTxt.text = AVUser.current()?.email
        telTxt.text = AVUser.current()?.mobilePhoneNumber
        genderTxt.text = AVUser.current()?.object(forKey: "gender") as? String

    }
    
    //正则检查Email有效性
    func validateEmail(email:String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: String.CompareOptions.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    // 正则检查Web有效性
    func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    // 正则检查手机号码有效性
    func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }

    //消息警告
    func alert(error:String,message:String ) -> Void {
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

//
//  UploadVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/18.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class UploadVC: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    @IBAction func publishBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        let uuid = NSUUID().uuidString
        object["puuid"] = "\( (AVUser.current()?.username)!) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else{
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        //生成照片数据
        let imageData = picImg.image!.jpegData(compressionQuality: 0.5)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        //发送服务器
        object.saveInBackground { (success:Bool, error:Error?) in
            if error == nil{
                //发送upload通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"upload"), object: nil)
                //将tabbar控制器中索引值为0的子控制器，显示在手机屏幕上
                self.tabBarController?.selectedIndex = 0
                
                //reset
                self.viewDidLoad()

            }
        }
        
        //发送hashtag到云端
        let words:[String] = titleTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            //定义正则表达式
            let pattern = "#[^#]+"
            let regular = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let results = regular.matches(in: word, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, word.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for result in results{
                word = (word as NSString).substring(with: result.range)
            }
            
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                hashtagObj["to"] = "\( (AVUser.current()?.username)!) \(uuid)"
                hashtagObj["by"] = AVUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackground({ (success, error:Error?) in
                    if success{
                        print("hashtag已经创建")
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
        }

    }
    @IBAction func removeBtn_clicked(_ sender: Any) {
        
        //reset
        viewDidLoad()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //alignment()
        //默认禁用publishBtn
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = UIColor.lightGray
        //默认隐藏removeBtn
        removeBtn.isHidden = true
        //单击image view
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
        //
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        //UI控件回到初始状态
        picImg.image = UIImage(named: "pbg.jpg")
        titleTxt.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alignment()
    }

    //布局
    func alignment() -> Void {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        picImg.frame = CGRect(x: 15, y:/* (self.navigationController?.navigationBar.frame.height)! + 35*/15, width: width / 4.5, height: width / 4.5)
        titleTxt.frame = CGRect(x: /*width - titleTxt.frame.width - 10*/picImg.frame.width + picImg.frame.origin.x + 10, y: picImg.frame.origin.y, width: width - (picImg.frame.width + picImg.frame.origin.x + 10) - 10, height: picImg.frame.height)
        publishBtn.frame = CGRect(x: 0, y: /*(self.tabBarController?.tabBar.frame.origin.y)!*/height - width / 8, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.height, width: picImg.frame.width, height: 30)
        
        self.view.backgroundColor = UIColor.white
        self.titleTxt.alpha = 1
        self.publishBtn.alpha = 1
        self.removeBtn.alpha = 1

    }
    
    @objc func selectImg() -> Void {
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

        picImg.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //允许publishBtn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        
        //显示移除按钮
        removeBtn.isHidden = false
        
        //二次单击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    //缩放照片
    @objc func zoomImg() -> Void {
        //放大后的Image View位置
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - (self.navigationController?.navigationBar.frame.height)! - 20, width: self.view.frame.width, height:  self.view.frame.width)
        //Image View还原到初始位置
        let unzoomed = CGRect(x: 15, y: /*(self.navigationController?.navigationBar.frame.height)! + 35*/15, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)

        if picImg.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                
                self.view.backgroundColor = UIColor.black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                
                self.view.backgroundColor = UIColor.white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

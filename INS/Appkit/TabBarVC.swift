//
//  TabBarVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/19.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

//关于icons的全局变量
var icons = UIScrollView()
var corner = UIImageView()
var dot = UIView()


class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //每个Item的文字颜色为白色
        self.tabBar.tintColor = UIColor.white
        //标签栏的背景色
        self.tabBar.barTintColor = UIColor(red: 37.0  / 255.0, green: 39.0  / 255.0, blue: 42.0  / 255.0, alpha: 1)
        
        self.tabBar.isTranslucent = false
        
        //创建icon条
        icons.frame = CGRect(x: self.view.frame.width / 5 * 3 + 10, y: self.view.frame.height - self.tabBar.frame.height * 2 - 3, width: 50, height: 35)
        self.view.addSubview(icons)
        //创建corner
        corner.frame = CGRect(x: icons.frame.origin.x, y: icons.frame.origin.y + icons.frame.height, width: 20, height: 14)
        corner.center.x = self.view.frame.width / 5 * 3 + (self.view.frame.width / 5) / 2
        corner.image = UIImage(named: "corner.png")
        corner.isHidden = true
        self.view.addSubview(corner)
        //创建dot
        dot.frame = CGRect(x: self.view.frame.width / 5 * 3, y: self.view.frame.height - 5, width: 7, height: 7)
        dot.center.x = self.view.frame.width / 5 * 3 + (self.view.frame.width / 5) / 2
        dot.backgroundColor = UIColor(red: 251/255, green: 103/255, blue: 29/255, alpha: 1.0)
        dot.layer.cornerRadius = dot.frame.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
        //
        //corner.isHidden = false
        //dot.isHidden = false
        
        //自定义标签按钮代替upload按钮
        let itemWidth = self.view.frame.width / 5
        let itemHeight = self.tabBar.frame.height
        let button = UIButton(frame: CGRect(x: (itemWidth * 2.5) - (itemHeight *  0.675), y:0, width: itemHeight * 1.35 , height: itemHeight))
        button.setBackgroundImage(UIImage.init(named: "upload.png"), for: UIControlState.normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(upload), for: UIControlEvents.touchUpInside)
//        self.view.addSubview(button)
        self.tabBar.addSubview(button)
        
        //显示所有通知
        query(type: ["like"], image: UIImage(named: "likeIcon.png")!)
        query(type: ["follow"], image: UIImage(named: "followIcon.png")!)
        query(type: ["mention","comment"], image: UIImage(named: "commentIcon.png")!)
    
        
        UIView.animate(withDuration: 1, delay: 8, options: [], animations: {() -> Void in
            icons.alpha = 0
            corner.alpha = 0
            dot.alpha = 0
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func query(type:[String],image:UIImage) -> Void {
        let query = AVQuery(className: "News")
        query.whereKey("to", equalTo: AVUser.current()!.username!)
        //query.whereKey("checked", equalTo: "no")
        query.whereKey("type", containedIn: type)
        
        query.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                if count > 0{
                    self.placeIcon(image: image, text: "\(count)")
                    
                    corner.isHidden = false
                    dot.isHidden = false
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        
    }
    
    func placeIcon(image:UIImage,text:String) -> Void {
        //创建某个独立的通知提示
        let view = UIImageView(frame: CGRect(x: icons.contentSize.width, y: 0, width: 50, height: 35))
        view.image = image
        icons.addSubview(view)
        
        //创建label
        let label = UILabel(frame: CGRect(x: view.frame.width / 2, y: 0, width: view.frame.width / 2, height: view.frame.height))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        view.addSubview(label)
        
        //调整icons视图的frame
        icons.frame.size.width = icons.frame.width + view.frame.width - 4
        icons.contentSize.width = icons.contentSize.width + view.frame.width - 4
        icons.center.x = self.view.frame.width / 6 + 23
        
        //显示隐藏控件
        corner.isHidden = false
        dot.isHidden = false
    }

    @objc func upload(sender:UIButton) -> Void {
        self.selectedIndex = 2
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

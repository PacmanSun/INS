//
//  HeaderView.swift
//  INS
//
//  Created by 孙岦 on 2017/12/1.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class HeaderView: UICollectionReusableView {
        
    @IBOutlet weak var avaImg: UIImageView!                 //用户头像
    @IBOutlet weak var fullnameLbl: UILabel!                //用户名称
    @IBOutlet weak var webTxt: UITextView!                  //个人主页
    @IBOutlet weak var bioLbl: UILabel!                     //个人简介
    
    @IBOutlet weak var posts: UILabel!                      //帖子数
    @IBOutlet weak var followers: UILabel!                  //关注者数
    @IBOutlet weak var followings: UILabel!                 //关注数
    
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = button.title(for: .normal)
        //获取当前对象
        let user = guestArray.last
        
        
        if title == "关 注" {
            guard let user = user else {
                return
            }
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.button.setTitle("✓已关注", for:.normal)
                    self.button.backgroundColor = .green
                    
                    //发送关注通知
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                        newsObj["to"] = user.username
                        newsObj["owner"] = ""
                        newsObj["puuid"] = ""
                        newsObj["type"] = "follow"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()

                }else{
                    print(error!.localizedDescription)
                }
            })
        }else{
            guard let user = user else {
                return
            }
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.button.setTitle("关 注", for:.normal)
                    self.button.backgroundColor = .lightGray
                    
                    //删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("to", equalTo: user.username!)
                    newsQuery.whereKey("by", equalTo:AVUser.current()!.username!)
                    
                    newsQuery.whereKey("type", equalTo: "follow")
                    newsQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                        if error == nil{
                            for object in objects!{
                                (object as AnyObject).deleteEventually()
                            }
                        }
                    }

                    
                }else{
                    print(error!.localizedDescription)
                }
            })
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //对齐
        let width = UIScreen.main.bounds.width
        //布局
        avaImg.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        
        posts.frame = CGRect(x: width / 2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.6, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.2, y: avaImg.frame.origin.y, width: 50, height: 30)
        
        postsTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        
        button.frame = CGRect(x: postsTitle.frame.origin.x, y: postsTitle.center.y + 20, width: width - postsTitle.frame.origin.x
             - 10, height: 30)
        button.layer.cornerRadius = button.frame.width / 50
        
        fullnameLbl.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.height, width: width - 30, height: 30)
        webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLbl.frame.origin.y + 15, width: width - 30, height: 30)
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: webTxt.frame.origin.y + 30, width: width - 30, height: 30)
    }
}

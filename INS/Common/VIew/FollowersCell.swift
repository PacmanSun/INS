//
//  FollowersCell.swift
//  INS
//
//  Created by 孙岦 on 2017/12/5.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class FollowersCell: UITableViewCell {
    
    var user:AVUser!
    
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = followBtn.title(for: .normal)
        
        if title == "关 注" {
            guard user != nil else {
                return
            }
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.followBtn.setTitle("✓已关注", for:.normal)
                    self.followBtn.backgroundColor = .green
                    
                    //发送关注通知
                    let newsObj = AVObject(className: "News")
                    newsObj["by"] = AVUser.current()?.username
                    newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                    newsObj["to"] = self.user.username
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
            guard user != nil else {
                return
            }
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success{
                    self.followBtn.setTitle("关 注", for:.normal)
                    self.followBtn.backgroundColor = .lightGray
                    
                    //删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("to", equalTo: self.user.username!)
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

        
        //布局
        let width = UIScreen.main.bounds.width
        
        avaImg.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameLbl.frame = CGRect(x: avaImg.frame.width + 20, y: 30, width: width / 3.2, height:30)
        followBtn.frame = CGRect(x: width - width / 3.5 - 20, y: 30, width: width / 3.5, height: 30)
        //设置按钮圆角
        followBtn.layer.cornerRadius = followBtn.frame.width / 20
        // Initialization code
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

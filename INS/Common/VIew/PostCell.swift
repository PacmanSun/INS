//
//  PostCell.swift
//  INS
//
//  Created by 孙岦 on 2017/12/18.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

class PostCell: UITableViewCell {
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var comentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var puuidLbl: UILabel!
    
    @IBAction func likeBtn_clicked(_ sender: Any) {
        //获取likeBtn的Title
        let title = (sender as AnyObject).title(for:.normal)
        
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("标记为：like！")
                    self.likeBtn.setTitle("like", for: UIControl.State.normal)
                    self.likeBtn.setImage(UIImage(named: "like.png"), for: UIControl.State.normal)
                    
                    //通知表格视图刷新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"liked"), object: nil)
                    
                    //like的消息通知
                    if self.usernameBtn.titleLabel?.text != AVUser.current()?.username{
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                        newsObj["to"] = self.usernameBtn.titleLabel?.text
                        newsObj["owner"] = self.usernameBtn.titleLabel?.text
                        newsObj["puuid"] = self.puuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }

                }
            })
        }else{
            //搜索表中对应的数据
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: (AVUser.current()?.username!)!)
            query.whereKey("to", equalTo: puuidLbl.text!)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                for object in objects!{
                    (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                        print("删除like记录：unlike！")
                        self.likeBtn.setTitle("unlike", for: UIControl.State.normal)
                        self.likeBtn.setImage(UIImage(named: "unlike.png"), for: UIControl.State.normal)
                        
                        //通知表格视图刷新
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"liked"), object: nil)
                        
                        //删除like的消息通知
                        let newsQuery = AVQuery(className: "News")
                        newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                        newsQuery.whereKey("by", equalTo: AVUser.current()!.username!)
                        newsQuery.whereKey("puuid", equalTo: self.puuidLbl.text!)
                        
                        newsQuery.whereKey("type", equalTo: "like")
                        newsQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                            if error == nil{
                                for object in objects!{
                                    (object as AnyObject).deleteEventually()
                                }
                            }
                        }
                    })
                }
            })
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let width = UIScreen.main.bounds.width
        
        //启用约束
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        picImg.translatesAutoresizingMaskIntoConstraints = false
        
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        comentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false

        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        puuidLbl.translatesAutoresizingMaskIntoConstraints = false

        let picWidth = width - 20
        
        //约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[ava(30)]-10-[pic(\(picWidth))]-5-[like(30)]", options: [], metrics: nil, views: ["ava":avaImg!,"pic":picImg!,"like":likeBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[username]", options: [], metrics: nil, views: ["username":usernameBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-5-[coment(30)]", options: [], metrics: nil, views: ["pic":picImg!,"coment":comentBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[date]", options: [], metrics: nil, views: ["date":dateLbl!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[like]-5-[title]-5-|", options: [], metrics: nil, views: ["like":likeLbl!,"title":titleLbl!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-5-[more(30)]", options: [], metrics: nil, views: ["pic":picImg!,"more":moreBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pic]-10-[likes]", options: [], metrics: nil, views: ["pic":picImg!,"likes":likeLbl!]))
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(30)]-10-[username]", options: [], metrics: nil, views: ["ava":avaImg!,"username":usernameBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pic]-0-|", options: [], metrics: nil, views: ["pic":picImg!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[like(30)]-10-[likes]-20-[coment(30)]", options: [], metrics: nil, views: ["like":likeBtn!,"likes":likeLbl!,"coment":comentBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[more(30)]-15-|", options: [], metrics: nil, views: ["more":moreBtn!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[title]-15-|", options: [], metrics: nil, views: ["title":titleLbl!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[date]-10-|", options: [], metrics: nil, views: ["date":dateLbl!]))
        
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //设置likeBtn的title文字为无色
            likeBtn.setTitleColor(UIColor.clear, for: UIControl.State.normal)
        
        //双击666
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func likeTapped() -> Void {

        //创建一个大的灰色桃心
        /*let likePic1 = UIImageView(image: UIImage(named: "unlike.png"))
        likePic1.frame.size.width = picImg.frame.width / 1.5
        likePic1.frame.size.height = picImg.frame.width / 1.5
        likePic1.center = picImg.center
        likePic1.alpha = 0.8
        likePic1.tag = 10
        self.addSubview(likePic1)*/
        
        let likePic2 = UIImageView(image: UIImage(named: "like.png"))
        likePic2.frame.size.width = picImg.frame.width / 1.5
        likePic2.frame.size.height = picImg.frame.width / 1.5
        likePic2.center = picImg.center
        likePic2.alpha = 0.8
        likePic2.tag = 11
        self.addSubview(likePic2)

        
        //通过动画缩小并隐藏likePic
        /*UIView.animate(withDuration: 0.4,
                       animations: {
            likePic1.alpha = 0
        })
        { (finshed:Bool) in
            if finshed{
                
                UIView.animate(withDuration: 0.4, animations: {
                    likePic2.alpha = 0.8
                })
                { (finshed:Bool) in
                    if finshed{
                        
                        UIView.animate(withDuration: 0.4, animations: {
                            likePic2.alpha = 0
                            likePic2.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        })
                        { (finshed:Bool) in
                            if finshed{
                                
                                let subview1 = self.viewWithTag(10)
                                subview1?.removeFromSuperview()
                                let subview2 = self.viewWithTag(11)
                                subview2?.removeFromSuperview()
                                
                            }
                        }

                    }
                }
                
            }
        }*/
        

        UIView.animate(withDuration: 0.6, animations: {
            likePic2.alpha = 0
            likePic2.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        { (finshed:Bool) in
            if finshed{
                
                let subview2 = self.viewWithTag(11)
                subview2?.removeFromSuperview()
                
            }
        }

        
        let title = likeBtn.title(for: UIControl.State.normal)
        
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("标记为：like！")
                    self.likeBtn.setTitle("like", for: UIControl.State.normal)
                    self.likeBtn.setImage(UIImage(named: "like.png"), for: UIControl.State.normal)
                    
                    //通知表格视图刷新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"liked"), object: nil)
                    
                    //like的消息通知
                    if self.usernameBtn.titleLabel?.text != AVUser.current()?.username{
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                        newsObj["to"] = self.usernameBtn.titleLabel?.text
                        newsObj["owner"] = self.usernameBtn.titleLabel?.text
                        newsObj["puuid"] = self.puuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }

                }
            })
        }
        
    }


}

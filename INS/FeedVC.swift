//
//  FeedVC.swift
//  INS
//
//  Created by 孙岦 on 2018/1/31.
//  Copyright © 2018年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

class FeedVC: UITableViewController {
    //UI objects
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func usernameBtn_clicked(_ sender: Any) {
        let index = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: index) as!PostCell
        
        if cell.usernameBtn.title(for: UIControlState.normal) == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as!HomeVC
            navigationController?.pushViewController(home, animated: true)
        }else{
            let user = AVQuery(className: "_User")
            user.whereKey("username", equalTo: cell.usernameBtn.titleLabel!.text!/*cell.usernameBtn.title(for: UIControlState.normal)!*/ )
            user.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        guestArray.append(object as!AVUser)
                        
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as!GuestVC
                        self.navigationController?.pushViewController(guest, animated: true)
                    }
                }
                
            })
        }
        
        
    }
    @IBAction func comentBtn_clicked(_ sender: Any) {
        let index = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: index) as!PostCell
        //发送相关数据到全局变量
        comentuuid.append(cell.puuidLbl.text!)
        comentowner.append((cell.usernameBtn.titleLabel?.text!)!)
        //通过nav推出ComentVC
        let coment = storyboard?.instantiateViewController(withIdentifier: "ComentVC") as!ComentVC
        navigationController?.pushViewController(coment, animated: true)
        
    }
    @IBAction func moreBtn_clicked(_ sender: Any) {
        let index = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: index) as!PostCell
        
        //删除操作
        let delete = UIAlertAction(title: "删除", style: UIAlertActionStyle.default) { (UIAlterAction) in
            //step1 从数组中删除相应数据
            self.usernameArray.remove(at: index.row)
            self.avaArray.remove(at: index.row)
            self.picArray.remove(at: index.row)
            self.dateArray.remove(at: index.row)
            self.titleArray.remove(at: index.row)
            self.puuidArray.remove(at: index.row)
            
            //step2 删除云端记录
            let postQuery = AVQuery(className: "Posts")
            postQuery.whereKey("puuid", equalTo: cell.puuidLbl.text!)
            postQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                            if success{
                                //发送通知到rootVC更新帖子
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"uploaded"), object: nil)
                                //销毁当前控制器
                                //_ = self.navigationController?.popViewController(animated: true)
                            }else{
                                print(error!.localizedDescription)
                            }
                        })
                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
            
            //step3 删除帖子的like记录
            let likeQuery = AVQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: cell.puuidLbl.text!)
            likeQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }else{
                    print(error!.localizedDescription)
                }
                
            })
            
            //step4 删除帖子的评论
            let comentQuery = AVQuery(className: "Comment")
            comentQuery.whereKey("to", equalTo: cell.puuidLbl.text!)
            comentQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }else{
                    print(error!.localizedDescription)
                }
                
            })
            
            //step5 删除帖子相关的hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.puuidLbl.text!)
            hashtagQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }else{
                    print(error!.localizedDescription)
                }
                
            })
            
            self.refresh()
        }
        
        //投诉操作
        let complain = UIAlertAction(title: "投诉", style: UIAlertActionStyle.default) { (UIAlertAction) in
            //发送投诉到云端投诉列表
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["to"] = cell.puuidLbl.text
            complainObj["post"] = cell.titleLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("投诉已经处理了")
                    self.alert(error: "投诉信息已被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    print(error!.localizedDescription)
                }
            })
        }
        
        //取消操作
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        
        //创建菜单控制器
        let menu = UIAlertController(title: "菜单选项", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        }else{
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        //显示菜单
        self.present(menu, animated: true, completion: nil)
        
    }
    
    
    var refresher = UIRefreshControl()
    
    
    //存储云端数据的数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var titleArray = [String]()
    var puuidArray = [String]()

    //存储当前用户所关注的人
    var followArray = [String]()
    
    //page size
    var page:Int = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //导航栏中的Title设置
        self.navigationItem.title = "聚合"
        
        //动态单元格高度设置
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // 设置refresher控件到集合视图之中
        refresher.addTarget(self, action: #selector(loadPosts), for: UIControlEvents.valueChanged)
        self.view.addSubview(refresher)
        
        //从云端载入帖子
        loadPosts()
        
        //
        indicator.center.x = tableView.center.x
        
        //从UploadVC类接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(upload(notification:)), name: NSNotification.Name(rawValue:"upload"), object: nil)
        //likeLbl
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue:"liked"), object: nil)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadPosts() -> Void {
        AVUser.current()?.getFollowees({ (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空数组
                self.followArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.followArray.append((object as AnyObject).username!!)
                }
                
                //添加当前用户到followArray数组中
                self.followArray.append((AVUser.current()?.username)!)
                
                let query = AVQuery(className: "Posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil{
                        //清空数组
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.titleArray.removeAll(keepingCapacity: false)
                        self.puuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.usernameArray.append((object as AnyObject).value(forKey: "username")as! String)
                            self.avaArray.append((object as AnyObject).value(forKey: "ava")as! AVFile)
                            self.dateArray.append((object as AnyObject).createdAt!!)
                            self.picArray.append((object as AnyObject).value(forKey: "pic")as! AVFile)
                            self.titleArray.append((object as AnyObject).value(forKey: "title")as! String)
                            self.puuidArray.append((object as AnyObject).value(forKey: "puuid")as! String)
                        }

                        //reload tableview
                        self.tableView.reloadData()
                        //self.refresher.endRefreshing()
                    }else{
                        print(error!.localizedDescription)
                    }
                })
                
            }
        })
        self.refresher.endRefreshing()
    }
    
    func loadMore() -> Void {
        //如果云端获取到的帖子数大于page数
        if self.page <= puuidArray.count {
            //开始Indicator动画
            indicator.startAnimating()
            
            //page +10
            page += 10
            
            AVUser.current()?.getFollowees({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    //清空数组
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.followArray.append((object as AnyObject).username!!)
                    }
                    
                    //添加当前用户到followArray数组中
                    self.followArray.append((AVUser.current()?.username)!)
                    
                    let query = AVQuery(className: "Posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            //清空数组
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.puuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.usernameArray.append((object as AnyObject).value(forKey: "username")as! String)
                                self.avaArray.append((object as AnyObject).value(forKey: "ava")as! AVFile)
                                self.dateArray.append((object as AnyObject).createdAt!!)
                                self.picArray.append((object as AnyObject).value(forKey: "pic")as! AVFile)
                                self.titleArray.append((object as AnyObject).value(forKey: "title")as! String)
                                self.puuidArray.append((object as AnyObject).value(forKey: "puuid")as! String)
                            }
                            
                            //reload tableview
                            self.tableView.reloadData()
                            //
                            self.indicator.stopAnimating()
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                    
                }
            })
            
        }
    }
    
    func alert(error:String,message:String) -> Void {
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @objc func upload(notification:Notification) -> Void {
        loadPosts()
    }
    
    @objc func refresh() -> Void {
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return puuidArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        // Configure the cell...
        
        //通过数组信息关联单元格中UI控件
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        cell.puuidLbl.text = puuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        
        cell.usernameBtn.sizeToFit()
        cell.titleLbl.sizeToFit()
        //配置用户头像
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        //配置帖子照片
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.picImg.image = UIImage(data: data!)
        }
        //帖子发布时间与当前时间的间隔差
        //获取帖子的创建时间
        let from = dateArray[indexPath.row]
        //获取当前时间
        let now = Date()
        //创建Calendar。Component类型的Set集合
        let component:Set<Calendar.Component> = [.second,.minute,.hour,.day,.weekOfMonth]
        let difference = Calendar.current.dateComponents(component, from: from, to: now)
        
        if difference.second! <= 0 {
            cell.dateLbl.text = "现在"
        }
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLbl.text = "\(difference.second!)秒"
        }
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLbl.text = "\(difference.minute!)分"
        }
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLbl.text = "\(difference.hour!)时"
        }
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLbl.text = "\(difference.day!)天"
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)周"
            
        }
        
        //根据用户是否like维护likeBtn
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: (AVUser.current()?.username)!)
        didLike.whereKey("to", equalTo: cell.puuidLbl.text!)
        didLike.countObjectsInBackground { (count:Int, error:Error?) in
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState.normal)
                cell.likeBtn.setImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
            }else{
                cell.likeBtn.setTitle("like", for: UIControlState.normal)
                cell.likeBtn.setImage(UIImage(named: "like.png"), for: UIControlState.normal)
            }
        }
        //计算本帖子的喜爱总数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.puuidLbl.text!)
        countLikes.countObjectsInBackground { (count:Int, error:Error?) in
            cell.likeLbl.text = "\(count)"
        }
        
        //将indexpath赋值给usernameBtn的layer属性自定义变量
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        //将indexpath赋值给comentBtn的layer属性自定义变量
        cell.comentBtn.layer.setValue(indexPath, forKey: "index")
        //将indexpath赋值给moreBtn的layer属性自定义变量
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        
        //@mentions is tapped
        cell.titleLbl.userHandleLinkTapHandler = { lable,handle,range in
            
            var mention = handle
            mention = String(mention.dropFirst())
            
            if mention.lowercased() == AVUser.current()?.username {
                
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
                
            }else{
                
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention.lowercased())
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    
                    if let object = objects?.last{
                        
                        guestArray.append(object as! AVUser)
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                        self.navigationController?.pushViewController(guest, animated: true)
                        
                    }else{
                        let alert = UIAlertController(title: "\(mention.uppercased())", message: "该用户不存在", preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        //#hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = {lable,handle,range in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
            
        }
        
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height * 2 {
            loadMore()
        }
    }


}

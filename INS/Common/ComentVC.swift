//
//  ComentVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/19.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

var comentuuid = [String]()
var comentowner = [String]()

class ComentVC: UIViewController,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource {
    //刷新控件
    var refresher = UIRefreshControl()
    //重置UI的默认值
    var tableViewHeight:CGFloat = 0
    var comentY:CGFloat = 0
    var comentHeight:CGFloat = 0
    // 获取虚拟键盘的大小
    var keyboard:CGRect = CGRect()
    //将从云端获取到的数据写进数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var comentArray = [String]()
    var dateArray = [Date]()
    //page size
    var page = 15
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBAction func sendBtn_clicked(_ sender: Any) {
        //在表格视图添加一行
        usernameArray.append((AVUser.current()?.username)!)
        avaArray.append(AVUser.current()?.object(forKey: "ava") as! AVFile)
        dateArray.append(Date())
        comentArray.append(comentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //发送到云端
        let comentObj = AVObject(className: "Comment")
        comentObj["to"] = comentuuid.last
        comentObj["username"] = AVUser.current()?.username
        comentObj["ava"] = AVUser.current()?.object(forKey: "ava")
        comentObj["comment"] = comentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        comentObj.saveEventually()//后台线程上传
        
        //发送hashtag到云端
        let words:[String] = comentTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
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
                hashtagObj["to"] = comentuuid.last
                hashtagObj["by"] = AVUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = comentTxt.text
                hashtagObj.saveInBackground({ (success, error:Error?) in
                    if success{
                        print("hashtag已经创建")
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        //当遇到@mention发送通知
        var mentionCreated:Bool = false
        
        
        for var word in words {
            if word.hasPrefix("@"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let newsObj = AVObject(className: "News")
                newsObj["by"] = AVUser.current()?.username
                newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                newsObj["to"] = word
                newsObj["owner"] = comentowner.last
                newsObj["puuid"] = comentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                
                mentionCreated = true
            }
        }
        
        //发送评论时候的通知
        if comentowner.last != AVUser.current()?.username && mentionCreated == false{
            let newsObj = AVObject(className: "News")
            newsObj["by"] = AVUser.current()?.username
            newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
            newsObj["to"] = comentowner.last
            newsObj["owner"] = comentowner.last
            newsObj["puuid"] = comentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        //scroll to bottom
        tableView.scrollToRow(at: IndexPath.init(row: self.comentArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        
        //重置UI
        comentTxt.text = ""
        comentTxt.frame.size.height = comentHeight
        comentTxt.frame.origin.y = sendBtn.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height
    }
    
    @IBAction func usernameBtn_clicked(_ sender: Any) {
        let index = (sender as! UIView).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: index) as!ComentCell
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as!HomeVC
            navigationController?.pushViewController(home, animated: true)
        }else{
            let user = AVQuery(className: "_User")
            user.whereKey("username", equalTo: cell.usernameBtn.title(for: UIControl.State.normal)! )
            user.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        guestArray.append(object as!AVUser)
                    }
                }
                
            })
            
            
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as!GuestVC
            navigationController?.pushViewController(guest, animated: true)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alignment()
        
        loadComent()
        
        navigationItem.title = "评论"
        navigationItem.hidesBackButton = true
        //let backBtn = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(_:)))
        let backBtn = UIBarButtonItem(image: UIImage.init(named: "back.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = backBtn
        
        //初始状态禁用sendBtn
        sendBtn.isEnabled = false
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        tableView.backgroundColor = UIColor.red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true
        //调出键盘
        self.comentTxt.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //布局
    func alignment() -> Void {
        let width = view.frame.width
        let height = view.frame.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - (navigationController?.navigationBar.frame.height)! - 20)
        comentTxt.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        comentTxt.layer.cornerRadius = comentTxt.frame.width / 50
        sendBtn.frame = CGRect(x: comentTxt.frame.origin.x + comentTxt.frame.width + width / 32, y: comentTxt.frame.origin.y, width: width - (comentTxt.frame.origin.x + comentTxt.frame.width) - width / 32 * 2, height: comentTxt.frame.height)
        
        //记录初始值
        tableViewHeight = tableView.frame.height
        comentHeight = comentTxt.frame.height
        comentY = comentTxt.frame.origin.y
        
        //单元格高度动态调整
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableView.automaticDimension
        
        comentTxt.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func back(_:UIBarButtonItem) -> Void {
        //返回之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从数组移除当前帖子的uuid,owner
        if  !comentuuid.isEmpty {
            comentuuid.removeLast()
        }
        if  !comentowner.isEmpty {
            comentowner.removeLast()
        }

    }
    
    @objc func showKeyboard(notificaton:Notification)  {
        // 定义keyboard大小
        let rect = notificaton.userInfo![UIResponder.keyboardFrameEndUserInfoKey]as!NSValue
        keyboard =  rect.cgRectValue
        //
        UIView.animate(withDuration: 0.5, animations:
            {
                self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
                self.comentTxt.frame.origin.y = self.comentY - self.keyboard.height
                self.sendBtn.frame.origin.y = self.comentY - self.keyboard.height
        })
    }
    @objc func hideKeyboard(notification:Notification) {
        //
        UIView.animate(withDuration: 0.5, animations:
            {
                self.tableView.frame.size.height = self.tableViewHeight
                self.comentTxt.frame.origin.y = self.comentY
                self.sendBtn.frame.origin.y = self.comentY
        })
    }
    
    func loadComent() -> Void {
        //合计出所有评论数量
        let countQuery = AVQuery(className: "Comment")
        countQuery.whereKey("to", equalTo: comentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if self.page < count{
                self.refresher.addTarget(self, action: #selector(self.loadMore), for: UIControl.Event.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            //获取最新的self.page数量的评论
            let query = AVQuery(className: "Comment")
            query.whereKey("to", equalTo: comentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.comentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.usernameArray.append((object as AnyObject).object(forKey: "username")as!String)
                        self.comentArray.append((object as AnyObject).object(forKey: "comment")as!String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava")as!AVFile)
                        self.dateArray.append((object as AnyObject).createdAt!!)
                        
                        self.tableView.reloadData()
                        
                        self.tableView.scrollToRow(at: IndexPath.init(row: self.comentArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)

                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
            
        }

        
    }
    
    @objc func loadMore() -> Void {
        //合计出所有评论数量
        let countQuery = AVQuery(className: "Comment")
        countQuery.whereKey("to", equalTo: comentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            self.refresher.endRefreshing()
            
            if self.page >= count{
                self.refresher.removeFromSuperview()
            }
        
            if self.page < count{
                self.page += 15
                
            //获取最新的self.page数量的评论
            let query = AVQuery(className: "Comment")
            query.whereKey("to", equalTo: comentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.comentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.usernameArray.append((object as AnyObject).object(forKey: "username")as!String)
                        self.comentArray.append((object as AnyObject).object(forKey: "comment")as!String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava")as!AVFile)
                        self.dateArray.append((object as AnyObject).createdAt!!)
                        
                        self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }
        }
    }
    
    func alert(error:String,message:String) -> Void {
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
        
    }

    
    // MARK: - TextView Delegate
    //输入时调用该方法
    func textViewDidChange(_ textView: UITextView) {
        //没有输入信息则禁止按钮
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            sendBtn.isEnabled = true
        }else{
            sendBtn.isEnabled = false
        }
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130 {
            let difference = textView.contentSize.height - textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            tableView.frame.size.height = tableView.frame.size.height - difference
        }else if  textView.contentSize.height < textView.frame.height{
            let difference =  textView.frame.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            tableView.frame.size.height = tableView.frame.size.height + difference
        }
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!ComentCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControl.State.normal)
        cell.usernameBtn.sizeToFit()
        cell.comentLbl.text = comentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
                }
        
        //获取帖子的创建时间
        let from = dateArray[indexPath.row]
        //获取当前时间
        let now = Date()
        //创建Calendar.Component类型的Set集合
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
        
        //@mentions is tapped
        cell.comentLbl.userHandleLinkTapHandler = { lable,handle,range in

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
                        let alert = UIAlertController(title: "\(mention.uppercased())", message: "该用户不存在", preferredStyle: UIAlertController.Style.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        //#hashtag is tapped
        cell.comentLbl.hashtagLinkTapHandler = {lable,handle,range in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
            
        }
        
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //设置所有单元格可编辑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //获取用户所滑动单元格对象
        let cell = tableView.cellForRow(at: indexPath) as!ComentCell
        
        //Action1.delete
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "删除") { (_:UITableViewRowAction, _:IndexPath) in
            //从云端删除评论
            let comentQuery = AVQuery(className: "Comment")
            comentQuery.whereKey("to", equalTo: comentuuid.last!)
            comentQuery.whereKey("comment", equalTo: cell.comentLbl.text!)
            
            if indexPath.row < indexPath.count - 1  {
                comentQuery.whereKey("createdAt", equalTo: self.dateArray[indexPath.row])
            }
            
            
            comentQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil{
                    //找到相关记录
                    if let object = objects?.last{
                        (object as AnyObject).deleteEventually()
                    }
                }else{
                    print(error!.localizedDescription)
                }
            })
            //从tableview删除单元格
            self.comentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)

            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
            
            //从云端删除hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: comentuuid.last!)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.comentLbl.text!)
            hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }
            }
            
            //删除评论和@mention的消息通知
            let newsQuery = AVQuery(className: "News")
            newsQuery.whereKey("to", equalTo: comentowner.last!)
            newsQuery.whereKey("by", equalTo: cell.usernameBtn!.titleLabel!.text!)
            newsQuery.whereKey("puuid", equalTo: comentuuid.last!)
            
            newsQuery.whereKey("type", containedIn: ["mention","comment"])
            newsQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil{
                    for object in objects!{
                        (object as AnyObject).deleteEventually()
                    }
                }
            }
        }
        

        
        
        //ACtion2.@
        let address = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "@") { (_:UITableViewRowAction, _:IndexPath) in
            //在TextView中包含@
            self.comentTxt.text = "\(self.comentTxt.text + "@" + self.usernameArray[indexPath.row] + " ")"
            //发送按钮生效
            self.sendBtn.isEnabled = true
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //ACtion3.投诉评论
        let complain = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "投诉") { (_:UITableViewRowAction, _:IndexPath) in
            //发送到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["to"] = comentuuid.last
            complainObj["post"] = cell.comentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            
            complainObj.saveInBackground({ (success:Bool, error:Error?) in
                if success{
                    print("投诉已经处理了")
                    self.alert(error: "投诉信息已被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    print(error!.localizedDescription)
                }
            })

            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //按钮背景色
        delete.backgroundColor = UIColor.red//UIColor(patternImage: UIImage(named: "delete.png")!)//UIColor.red
        address.backgroundColor = UIColor.gray//UIColor(patternImage: UIImage(named: "address.png")!)///UIColor.gray
        complain.backgroundColor = UIColor.gray//UIColor(patternImage: UIImage(named: "complain.png")!)///UIColor.gray

        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            return [delete,address]
        }else if comentowner.last == AVUser.current()?.username{
            return [delete,address,complain]
        }else{
            return [address,complain]
        }
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

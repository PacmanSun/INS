//
//  NewsVC.swift
//  INS
//
//  Created by 孙岦 on 2018/2/5.
//  Copyright © 2018年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

class NewsVC: UITableViewController {

    //存储云端数据到数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var typeArray = [String]()
    var dateArray = [Date]()
    var puuidArray = [String]()
    var ownerArray = [String]()
    
    
    @IBAction func usernameBtn_clicked(_ sender: Any) {
        let index = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: index) as!NewsCell
        
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //动态单元格高度设置
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        //导航栏title
        //self.navigationController?.title = "通知"
        self.navigationItem.title = "通知"

        
        //
        let query = AVQuery(className: "News")
        query.whereKey("to", equalTo: AVUser.current()!.username!)
        query.limit = 30
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append((object as AnyObject).value(forKey: "by") as! String)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                    self.typeArray.append((object as AnyObject).value(forKey: "type") as! String)
                    self.dateArray.append((object as AnyObject).createdAt!!)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.ownerArray.append((object as AnyObject).value(forKey: "owner") as! String)
                    
                    (object as! AVObject).setObject("yes", forKey: "checked")
                    (object as! AVObject).saveEventually()
                }
                
                UIView.animate(withDuration: 1, animations: {
                    icons.alpha = 0
                    corner.alpha = 0
                    dot.alpha = 0
                })
                
                self.tableView.reloadData()

            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell

        // Configure the cell...

        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }else{
             print(error!.localizedDescription)
            }
        }
        
        //消息的发送时间与当前时间差
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
        
        //定义info文字
        switch typeArray[indexPath.row] {
        case "mention":cell.infoLbl.text = "@mention了你"
        case "comment":cell.infoLbl.text = "评论了你"
        case "like":cell.infoLbl.text = "给你的帖子点了赞"
        case "follow":cell.infoLbl.text = "关注了你"

        default: break
            
        }

        //indexPath赋值usernameBtn
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! NewsCell
        
        
        switch  typeArray[indexPath.row]{
        case "mention","comment":
            //发送相关数据到全局变量
            comentuuid.append(puuidArray[indexPath.row])
            comentowner.append(ownerArray[indexPath.row])
            
            //通过nav推出ComentVC
            let coment = storyboard?.instantiateViewController(withIdentifier: "ComentVC") as!ComentVC
            navigationController?.pushViewController(coment, animated: true)

        case "like":
            //发送post uuid 到 postuuid
            postuuid.append(puuidArray[indexPath.row])
            //导航至PostVC
            let postVC = storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
            navigationController?.pushViewController(postVC, animated: true)

        case "follow":
            
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
            
        default:
            break
        }
    }

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

}

//
//  FollowersVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/5.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersVC: UITableViewController {

    var show = String()
    var user = String()
    
    var followerArray = [AVUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = show
        if show == "关 注 者" {
            loadFollowers()
        }else{
            loadFollowings()
        }
        
        //定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        //let backBtn = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(_:)))
        let backBtn = UIBarButtonItem(image: UIImage.init(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        //实现右滑返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func back(_:UIBarButtonItem) -> Void {
        //返回之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从postuuid数组移除当前帖子的uuid
        if  !postuuid.isEmpty {
            postuuid.removeLast()
        }
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 0
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 0
        return followerArray.count
    }

    func loadFollowers() -> Void {
        AVUser.current()?.getFollowers({ (followers:[Any]?, error:Error?) in
            if error == nil && followers != nil{
                self.followerArray = followers! as! [AVUser]
                //刷新表格视图
                self.tableView.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
    func loadFollowings() -> Void {
        AVUser.current()?.getFollowees({ (followings:[Any]?, error:Error?) in
            if error == nil && followings != nil{
                self.followerArray = followings as! [AVUser]
                //刷新表格视图
                self.tableView.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        // Configure the cell...

        cell.usernameLbl.text = followerArray[indexPath.row].username
        let ava = followerArray[indexPath.row].object(forKey: "ava") as! AVFile

        ava.getDataInBackground { (data:Data?, error:Error?) in

            if error == nil{
            cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        //利用按钮外观区分关注状态
        let query = followerArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current() as Any)
        query.whereKey("followee", equalTo: followerArray[indexPath.row])
        query.countObjectsInBackground { (count:Int, error:Error?) in
            //根据计数设置按钮
            if error == nil{
                if count == 0{
                    cell.followBtn.setTitle("关 注", for:.normal)
                    cell.followBtn.backgroundColor = .lightGray
                }else{
                    cell.followBtn.setTitle("✓已关注", for:.normal)
                    cell.followBtn.backgroundColor = .green
                }
            }
        }
        //对自己隐藏关注按钮
        if cell.usernameLbl.text == AVUser.current()?.username {
            cell.followBtn.isHidden = true
        }
        //传递需要关注的对象
        cell.user = followerArray[indexPath.row]
        
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //通过indexpath获取用户所单击的单元格
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        //单击后进入homeVC或guestVC
        if cell.usernameLbl.text == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestArray.append(followerArray[indexPath.row])
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
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

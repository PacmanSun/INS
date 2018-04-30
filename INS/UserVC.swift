//
//  UserVC.swift
//  INS
//
//  Created by 孙岦 on 2018/2/3.
//  Copyright © 2018年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

class UserVC: UITableViewController ,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    //搜索栏
    var searchBar = UISearchBar()
    //从云端获取信息后保存数据的数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    

    //集合视图UI
    var collectionView:UICollectionView!
    //从云端获取信息后保存数据的数组
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var page:Int = 24
    //刷新控件
    var refresher:UIRefreshControl!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //实现Search Bar 功能
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width - 30
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        //load user
        loadUsers()
        
        searchBar.showsCancelButton = false
        
        //启动集合视图
        collectionViewLaunch()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUsers() -> Void {
        /*
        let userQuery = AVUser.query()
        userQuery.addDescendingOrder("createdAt")
        userQuery.limit = 20
        userQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append((object as AnyObject).username!!)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                }
                
                //刷新表格视图
                self.tableView.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }
       */
        //清空数组
        self.usernameArray.removeAll(keepingCapacity: false)
        self.avaArray.removeAll(keepingCapacity: false)
        //刷新表格视图
        self.tableView.reloadData()

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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        
        //隐藏followBtn按钮
        cell.followBtn.isHidden = true
        if usernameArray.count > 0 {
            cell.usernameLbl.text = usernameArray[indexPath.row]
            avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
                if error == nil{
                    cell.avaImg.image = UIImage(data: data!)
                }
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取当前用户选择的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameLbl.text == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLbl.text!)
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if let object = objects?.last{
                    guestArray.append(object as! AVUser)
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
            

        }
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
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        //开始搜索时隐藏collectionView
        collectionView.isHidden = true
        
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        userQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                if objects!.isEmpty{
                    let fullnameQuery = AVUser.query()
                    fullnameQuery.whereKey("fullname", matchesRegex: "(?i)" + searchBar.text!)
                    fullnameQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            //清空数组
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.usernameArray.append((object as AnyObject).username!!)
                                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                            }
                            
                            //刷新表格视图
                            self.tableView.reloadData()
                        }
                    })
                    
                }else{
                    //清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.usernameArray.append((object as AnyObject).username!!)
                        self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                    }
                    
                    //刷新表格视图
                    self.tableView.reloadData()
                }
            }
        }
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        loadUsers()
        
        //显示collectionView
        collectionView.isHidden = false
        //self.tableView.reloadData()

        
    }
    
        // MARK: - CollectionView
    func collectionViewLaunch() -> Void {
        //集合视图相关方法
        let layout = UICollectionViewFlowLayout()
        
        //定义item尺寸
        layout.itemSize = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        
        //设置滚动方向
        layout.scrollDirection = .vertical
        
        //定义滚动视图在视图中的位置
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height - 20)
        
        //实例化滚动视图
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        
        // 设置refresher控件到集合视图之中
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        collectionView.addSubview(refresher)
        
        self.view.addSubview(collectionView)
        
        //定义集合视图中的单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        //
        loadPosts()
    }
    
    //设置每个section中的行间隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //设置每个section中行内的cell间隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //确定集合视图中item数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell  内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    //单击cell时
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid 到 postuuid
        postuuid.append(puuidArray[indexPath.row])
        //导航至PostVC
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    
    
    ////
    @objc func refresh() -> Void {
        loadPosts()
        collectionView?.reloadData()
        
        //停止刷新动画
        refresher.endRefreshing()
    }

    
    ////
    func loadPosts() -> Void {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username as Any)
        query.limit = page
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                //将查寻到的数据添加到数组中
                for object in objects!{
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    //
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            loadMore()
        }
    }

    func loadMore() -> Void {
        if page <= picArray.count{
            page += 24
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: AVUser.current()?.username as Any)
            query.limit = page
            query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil{
                    //清空两个数组
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    //将查寻到的数据添加到数组中
                    for object in objects!{
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    }
                    //print("reload + \(self.page)")
                    
                    self.collectionView?.reloadData()
                }else{
                    print(error!.localizedDescription)
                }
            }
        }
    }


//
}

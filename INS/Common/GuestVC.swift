//
//  GuestVC.swift
//  INS
//
//  Created by 孙岦 on 2017/12/7.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit
//import AVOSCloud

//private let reuseIdentifier = "Cell"

var guestArray = [AVUser]()

class GuestVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    //刷新控件
    var refresher:UIRefreshControl!
    
    //每页载入帖子的数量
    var page:Int = 12
    
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        //反弹效果
        self.collectionView?.alwaysBounceVertical = true
        //导航栏中的Title设置
        self.navigationItem.title = guestArray.last?.username//?.uppercased()

        
        // 设置refresher控件到集合视图之中
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refresher)
        
        //定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        //let backBtn = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(_:)))
        let backBtn = UIBarButtonItem(image: UIImage.init(named: "back.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //实现右滑返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        //设置集合视图背景色
        self.collectionView?.backgroundColor = UIColor.white
        
        loadPosts()
    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refresh() -> Void {
        collectionView?.reloadData()
        
        //停止刷新动画
        refresher.endRefreshing()
    }
    
    func loadPosts() -> Void {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last?.username as Any)
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
    
    func loadMore() -> Void {
        if page <= picArray.count{
            page += 12
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username as Any)
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
                    print("reload + \(self.page)")
                    
                    self.collectionView?.reloadData()
                }else{
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    
    //
    @objc func postsTap(_ recognizer:UITapGestureRecognizer) -> Void {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap(_ recognizer:UITapGestureRecognizer) -> Void {
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = (guestArray.last?.username)!
        followers.show = "关 注 者"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingsTap(_ recognizer:UITapGestureRecognizer) -> Void {
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followings.user = (guestArray.last?.username)!
        followings.show = "关 注"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
    //
    @objc func back(_:UIBarButtonItem) -> Void {
        //返回之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从guestArray移除最后一个AVUSER
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //return picArray.count == 0 ? 0 : 30
        return picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
    
        // 从picArray数组中获取图片
        picArray[indexPath.row/*0*/] .getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }

        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //载入访客信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username as Any)
        infoQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
            guard let objects = objects , objects.count > 0 else{
            
                let alert = UIAlertController(title: "\(guestArray.last!.username!)", message: "该用户不存在", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
                return
                }
                //找到用户信息
                for object in objects{
                    header.fullnameLbl.text = ((object as AnyObject).object(forKey: "fullname") as? String)?.uppercased()
                    header.webTxt.text = (object as AnyObject).object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    header.bioLbl.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    
                    let avaQuery = (object as AnyObject).object(forKey: "ava") as! AVFile
                    avaQuery.getDataInBackground { (data:Data?, error:Error?) in
                        if data == nil{
                            print(error!.localizedDescription)
                        }else{
                            header.avaImg.image = UIImage(data: data!)
                        }
                        
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        

        
        
        
        let currentUser:AVUser = guestArray.last!
        //设置当前用户与访客关注状态
        let followingsQuery = AVUser.current()?.followeeQuery()
        followingsQuery?.whereKey("user", equalTo: AVUser.current() as Any)
        followingsQuery?.whereKey("followee", equalTo: guestArray.last as Any)
        followingsQuery?.countObjectsInBackground({ (count:Int, error:Error?) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
                if count == 0{
                    header.button.setTitle("关 注", for: UIControl.State.normal)
                    header.button.backgroundColor = UIColor.lightGray
                }else{
                    header.button.setTitle("✓已关注", for: UIControl.State.normal)
                    header.button.backgroundColor = UIColor.green
                }

        })
        
        //获取访客帖子数等信息
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username as Any)
        postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.posts.text = String(count)//"\(count)"
            }
        }
        
        let followersQuery = AVUser.followerQuery((guestArray.last?.objectId)!)//AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.followers.text = String(count)//"\(count)"
            }
        }
        
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil{
                header.followings.text = String(count)//"\(count)"
            }
        }
        
        //实现单击
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.view.frame.width-8) / 3.0, height: (self.view.frame.width-8) / 3.0)
        return size
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            loadMore()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid 到 postuuid
        postuuid.append(puuidArray[indexPath.row])
        //导航至PostVC
        let postVC = storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        navigationController?.pushViewController(postVC, animated: true)
    }

}

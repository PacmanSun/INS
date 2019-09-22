//
//  HashtagsVC.swift
//  INS
//
//  Created by 孙岦 on 2018/1/28.
//  Copyright © 2018年 孙岦. All rights reserved.
//

import UIKit
import AVOSCloud

//private let reuseIdentifier = "Cell"

var hashtag = [String]()


class HashtagsVC: UICollectionViewController ,UICollectionViewDelegateFlowLayout{
    //刷新控件
    var refresher:UIRefreshControl!
    //每页载入帖子的数量
    var page:Int = 24
    
    //从云端获取数据后，存储数据的数组
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var filterArray = [String]()
    

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
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
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
        
        loadHashtag()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    @objc func refresh() -> Void {
        loadHashtag()
        
        collectionView?.reloadData()
        
        //停止刷新动画
        refresher.endRefreshing()
    }
    
    @objc func back(_:UIBarButtonItem) -> Void {
        //返回之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从guestArray移除最后一个AVUSER
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    func loadHashtag() -> Void {
        //step1 获取与hashtag相关的帖子
        let hashtagQuery = AVQuery(className: "Hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                //清空filterArray 数组
                self.filterArray.removeAll(keepingCapacity: false)
                
                //存储相关帖子
                for object in objects!{
                    self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                }
                
                //step2 通过filterArray的uuid 找出相关的帖子
                let query = AVQuery(className: "Posts")
                query.whereKey("puuid", containedIn: self.filterArray)
                query.limit  = self.page
                query.addDescendingOrder("cteatedAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil{
                        //清空数组
                        self.picArray.removeAll(keepingCapacity: false)
                        self.puuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                            self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        }
                        
                        //reload
                        self.collectionView?.reloadData()
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    func loadMore() -> Void {
        if page <= picArray.count{
            page += 12
            
            //step1 获取与hashtag相关的帖子
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if error == nil{
                    //清空filterArray 数组
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    //存储相关帖子
                    for object in objects!{
                        self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                    }
                    
                    //step2 通过filterArray的uuid 找出相关的帖子
                    let query = AVQuery(className: "Posts")
                    query.whereKey("puuid", containedIn: self.filterArray)
                    query.limit  = self.page
                    query.addDescendingOrder("cteatedAt")
                    query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                        if error == nil{
                            //清空数组
                            self.picArray.removeAll(keepingCapacity: false)
                            self.puuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                            }
                            
                            //reload
                            self.collectionView?.reloadData()
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                }else{
                    print(error!.localizedDescription)
                }
            }

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
        return picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
    
        // Configure the cell
        // 从picArray数组中获取图片
        picArray[indexPath.row/*0*/] .getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }

        return cell
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

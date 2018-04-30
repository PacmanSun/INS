//
//  NewsCell.swift
//  INS
//
//  Created by 孙岦 on 2018/2/5.
//  Copyright © 2018年 孙岦. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    //UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //约束
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(30)]-10-[username]-7-[info]-10-[date]", options: [], metrics: nil, views: ["ava" : avaImg,"username" : usernameBtn,"info" : infoLbl,"date" : dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[ava(30)]-10-|", options: [], metrics: nil, views: ["ava" : avaImg]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[username(30)]-10-|", options: [], metrics: nil, views: ["username" : usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[info(30)]-10-|", options: [], metrics: nil, views: ["info" : infoLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[date(30)]-10-|", options: [], metrics: nil, views: ["date" : dateLbl]))
        
        self.avaImg.layer.cornerRadius = avaImg.frame.width / 2
        self.avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

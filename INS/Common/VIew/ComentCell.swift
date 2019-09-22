//
//  ComentCell.swift
//  INS
//
//  Created by 孙岦 on 2017/12/19.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit

class ComentCell: UITableViewCell {
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var comentLbl: KILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //alignment
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        comentLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[username]-(-2)-[coment]-5-|", options: [], metrics: nil, views:["username":usernameBtn,"coment":comentLbl]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[date]", options: [], metrics: nil, views:["date":dateLbl]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[ava(40)]", options: [], metrics: nil, views:["ava":avaImg]))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(40)]-13-[coment]-20-|", options: [], metrics: nil, views:["ava":avaImg,"coment":comentLbl]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[ava]-13-[username]", options: [], metrics: nil, views:["ava":avaImg,"username":usernameBtn]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[date]-10-|", options: [], metrics: nil, views:["date":dateLbl]))


        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

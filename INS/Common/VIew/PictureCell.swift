//
//  PictureCell.swift
//  INS
//
//  Created by 孙岦 on 2017/12/1.
//  Copyright © 2017年 孙岦. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: (width - 0) / 3.0 ,height: (width - 0) / 3.0)
        
    }
}

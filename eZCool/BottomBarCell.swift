//
//  BottomBarCell.swift
//  eZCool
//
//  Created by BinWu on 5/9/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class BottomBarCell: UITableViewCell {
    @IBOutlet weak var repostButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var attitudeButton: UIButton!
    
    var callbackDelegate: CellContentClickedCallback!
    var weiboID = 0
    var index = -1
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func fastRepost(sender: UIButton) {
        callbackDelegate.fastRepostClicked!(weiboID, index: index)
    }
    
    @IBAction func fastComment(sender: UIButton) {
        callbackDelegate.fastCommentClicked!(weiboID, index: index)
    }
}

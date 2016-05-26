//
//  RepostCommentTableViewCell.swift
//  eZCool
//
//  Created by BinWu on 5/15/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class RepostCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var weiboID: Int!
    var wbUserID: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layoutIfNeeded()

        self.mainText.preferredMaxLayoutWidth = self.mainText.frame.width
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

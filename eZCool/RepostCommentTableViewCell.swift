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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

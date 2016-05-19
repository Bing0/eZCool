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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

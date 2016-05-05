//
//  BaseTypeTableViewCell.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

enum OriginalViewStyle {
    case textOnly
    case textWithOneImage
    case textWithOneLineImages
    case textWithTwoLineImages
    case textWithThreeLineImages
    case textWithVideo
}

protocol  CellContentClickedCallback{
    func weiboImageClicked(weiboID: Int, imageIndex: Int)
}

class BaseTypeTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var repostText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var repostButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var attitudeButton: UIButton!
    
    @IBOutlet weak var originalText: UILabel!
    @IBOutlet weak var originalUIView: UIView!
    
    @IBOutlet var repostTextHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var imageTopSpaceConstraint: [NSLayoutConstraint]!
    @IBOutlet var imageFullSizeConstraint: [NSLayoutConstraint]!
    @IBOutlet var originalImageCollection: [UIImageView]!
    
    var wbUserID = 0
    //the weibo id that has photo, not the repost weibo id
    var weiboID = 0
    
    var callbackDelegate: CellContentClickedCallback!
    
    var hideRepostText :Bool = true {
        willSet{
            if newValue {
                repostTextHeightConstraint.active = true
                originalUIView.backgroundColor = UIColor.whiteColor()
            }else{
                repostTextHeightConstraint.active = false
                originalUIView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            }
        }
    }
    
    var hideFirstLine :Bool = true {
        willSet{
            if newValue {
                imageTopSpaceConstraint[0].constant = 0
                imageFullSizeConstraint[0].priority = 250
            }else{
                imageTopSpaceConstraint[0].constant = 8
                imageFullSizeConstraint[0].priority = 999
            }
        }
    }
    
    var hideSecondLine :Bool = true {
        willSet{
            if newValue {
                imageTopSpaceConstraint[1].constant = 0
                imageFullSizeConstraint[1].priority = 250
            }else{
                imageTopSpaceConstraint[1].constant = 8
                imageFullSizeConstraint[1].priority = 999
            }
        }
    }

    var hideThirdLine :Bool = true {
        willSet{
            if newValue {
                imageTopSpaceConstraint[2].constant = 0
                imageFullSizeConstraint[2].priority = 250
            }else{
                imageTopSpaceConstraint[2].constant = 8
                imageFullSizeConstraint[2].priority = 999
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        repostTextHeightConstraint.constant = 0
        originalImageCollection = originalImageCollection.sort(){
            if $0.frame.origin.y > $1.frame.origin.y {
                return false
            }else if $0.frame.origin.y < $1.frame.origin.y{
                return true
            }else if $0.frame.origin.x < $1.frame.origin.x{
                return true
            }else {
                return false
            }
        }
        imageFullSizeConstraint = imageFullSizeConstraint.sort(){
            if $0.firstItem.frame.origin.y < $1.firstItem.frame.origin.y {
                return true
            }else{
                return false
            }
        }
        imageTopSpaceConstraint = imageTopSpaceConstraint.sort(){
            if $0.firstItem.frame.origin.y < $1.firstItem.frame.origin.y {
                return true
            }else{
                return false
            }
        }
        
        
        for i in 0 ..< 9 {
            let tap = UITapGestureRecognizer(target: self, action: #selector(BaseTypeTableViewCell.weiboImageTapped(_:)))
            originalImageCollection[i].addGestureRecognizer(tap)
        }
        weiboID = 0
        wbUserID = 0
        setOriginalTextStyle(.textOnly, reposted: false)
    }

    
    func weiboImageTapped(sender: UITapGestureRecognizer) {
        let view = sender.view
        for i in 0 ..< 9 {
            if view == originalImageCollection[i] {
                callbackDelegate.weiboImageClicked(weiboID, imageIndex: i)
                return
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layoutIfNeeded()
        
        self.repostText.preferredMaxLayoutWidth = self.repostText.frame.width
        self.originalText.preferredMaxLayoutWidth = self.originalText.frame.width
    }
    
    
    func setOriginalTextStyle(type: OriginalViewStyle, reposted: Bool) {
        if reposted {
            hideRepostText = false
        }else{
            hideRepostText = true
        }
        
        switch type {
        case .textOnly:
            hideFirstLine = true
            hideSecondLine = true
            hideThirdLine = true
        case .textWithOneImage:
            break
        case .textWithOneLineImages:
            hideFirstLine = false
            hideSecondLine = true
            hideThirdLine = true
        case .textWithTwoLineImages:
            hideFirstLine = false
            hideSecondLine = false
            hideThirdLine = true
        case .textWithThreeLineImages:
            hideFirstLine = false
            hideSecondLine = false
            hideThirdLine = false
        case .textWithVideo:
            break
        }
    }    
}

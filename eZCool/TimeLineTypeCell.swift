//
//  WeiboContentTableViewCell.swift
//  eZCool
//
//  Created by POD on 5/9/16.
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
    func weiboImageClicked(weiboID: Int, imageIndex: Int, sourceImageView: UIImageView)
}

class TimeLineTypeCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var repostedText: UILabel!

    @IBOutlet var repostedTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var repostedTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet var imageTopSpaceConstraint: [NSLayoutConstraint]!
    @IBOutlet var imageFullSizeConstraint: [NSLayoutConstraint]!
    @IBOutlet var originalImageCollection: [UIImageView]!
    
    var wbUserID = 0
    //the weibo id that has photo, not the repost weibo id
    var weiboID = 0
    
    var callbackDelegate: CellContentClickedCallback!
    
    var hideRepostedText :Bool = true {
        willSet{
            if newValue {
                repostedTextHeightConstraint.active = true  //reposted height constraint is 0
                repostedTopSpaceConstraint.constant = 0
                self.backgroundColor = UIColor.whiteColor()
            }else{
                repostedTextHeightConstraint.active = false
                repostedTopSpaceConstraint.constant = 8
                self.backgroundColor = UIColor.groupTableViewBackgroundColor()
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
        // Initialization code
        repostedTextHeightConstraint.constant = 0
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
        
        weiboID = 0
        wbUserID = 0
        setOriginalTextStyle(.textOnly, reposted: false)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layoutIfNeeded()
        
        self.repostedText.preferredMaxLayoutWidth = self.repostedText.frame.width
        self.mainText.preferredMaxLayoutWidth = self.mainText.frame.width
    }
    
    func weiboImageTapped(sender: UITapGestureRecognizer) {
        let view = sender.view
        for i in 0 ..< 9 {
            if view == originalImageCollection[i] {
                callbackDelegate.weiboImageClicked(weiboID, imageIndex: i, sourceImageView: originalImageCollection[i])
                return
            }
        }
    }
    
    func setOriginalTextStyle(type: OriginalViewStyle, reposted: Bool) {
        if reposted {
            hideRepostedText = false
        }else{
            hideRepostedText = true
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
    
    func addTapGestureToImages(imageCounts: Int) {
        for i in 0 ..< imageCounts {
            let tap = UITapGestureRecognizer(target: self, action: #selector(weiboImageTapped(_:)))
            originalImageCollection[i].addGestureRecognizer(tap)
        }
    }
    
    func removeTapGestureFromAllImages() {
        for i in 0 ..< 9 {
            if let gestures = originalImageCollection[i].gestureRecognizers{
                if gestures.count > 0 {
                    originalImageCollection[i].removeGestureRecognizer(gestures[0])
                }else{
                    return
                }
            }else{
                return
            }
        }
    }

    
}

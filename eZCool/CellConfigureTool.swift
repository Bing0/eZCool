//
//  CellConfigureTool.swift
//  eZCool
//
//  Created by BinWu on 5/19/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class CellConfigureTool {
    
    func findRangeIn(string: String, withPattern pattern: String) -> [NSRange] {
        let textRange = NSRange(location: 0, length: string.characters.count)
        var ranges:[NSRange] = []
        let reg = try? NSRegularExpression(pattern: pattern, options: [])
        reg?.enumerateMatchesInString(string, options: [], range: textRange, usingBlock: {result, flags, ptr in
            if let result = result
            {
                ranges.append(result.range)
            }
        })
        
        return ranges
    }
    
    func makeAttributedString(string: String) -> NSAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string:string)
        let specialColorAttribute = [ NSForegroundColorAttributeName: UIColor.colorWithHex("EB7350", alpha: 1.0)]
        
        //at user
        let atUserPattern = "@[\\w]+"
        let atUserRanges = findRangeIn(string, withPattern: atUserPattern)
        for range in atUserRanges {
            attributedString.addAttributes(specialColorAttribute, range: range)
        }
        
        //topic
        let topicPattern = "#[\\w]+#"
        let topicRanges = findRangeIn(string, withPattern: topicPattern)
        for range in topicRanges {
            attributedString.addAttributes(specialColorAttribute, range: range)
        }
        
        //url
        let urlPattern = "(https?)://([a-zA-Z0-9\\-\\./]+)"
        let urlRanges = findRangeIn(string, withPattern: urlPattern)
        for range in urlRanges {
            attributedString.addAttributes(specialColorAttribute, range: range)
        }
        
        //motion
        let motionPattern = "\\[\\w+\\]"
        let motionRanges = findRangeIn(string, withPattern: motionPattern)
        for range in motionRanges {
            attributedString.addAttributes(specialColorAttribute, range: range)
        }
        
        return attributedString
    }
    
    func configureWeiboBottomBarCell(cell: BottomBarCell, wbContent: WBContentModel) {
        
        cell.repostButton.setTitle(wbContent.repostCount != 0 ? " \(wbContent.repostCount!)" : " Repost", forState: UIControlState.Normal)
        cell.commentButton.setTitle(wbContent.commentCount != 0 ? " \(wbContent.commentCount!)" : " Comments", forState: UIControlState.Normal)
        cell.attitudeButton.setTitle(wbContent.attitudeCount != 0 ? " \(wbContent.attitudeCount!)" : "", forState: UIControlState.Normal)
    }
    
    func configureWeiboContentCell(cell: TimeLineTypeCell, wbContent: WBContentModel) {
        let wbUser = wbContent.belongToWBUser!
        var wbPics = wbContent.pictures
        
        cell.wbUserID = 0
        cell.weiboIDMain = 0
        cell.weiboIDReposted = 0
        
        cell.name.text = wbUser.name
        if cell.isShownWeiboDetail {
            cell.time.text = wbContent.createdDate?.getAbsoluteTime()
        }else{
            cell.time.text = wbContent.createdDate?.getRelativeTime()
        }
        
        cell.profileImage.image = nil
        
        for imageView in cell.originalImageCollection {
            imageView.image = nil
        }
        
        var reposted = false
        
        if let repostedWBContent = wbContent.repostContent{
            //
            cell.mainText.attributedText = makeAttributedString(wbContent.text ?? "")
            let repostedWBUser = repostedWBContent.belongToWBUser
            
            let userName = (repostedWBUser?.name != nil) ? "@\(repostedWBUser!.name!):"  : ""
            //
            cell.repostedText.attributedText = makeAttributedString("\(userName)\(repostedWBContent.text!)")
            
            wbPics = repostedWBContent.pictures
            reposted = true
        }else{
            //
            cell.mainText.attributedText = makeAttributedString(wbContent.text ?? "")
            wbPics = wbContent.pictures
        }
        
        if let picModels =  wbPics?.allObjects as? [WBPictureModel]{
            
            switch picModels.count {
            case 0:
                cell.setOriginalTextStyle(OriginalViewStyle.textOnly, reposted: reposted)
            case 1 ... 3:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithOneLineImages, reposted: reposted)
            case 4 ... 6:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithTwoLineImages, reposted: reposted)
            case 7 ... 9:
                cell.setOriginalTextStyle(OriginalViewStyle.textWithThreeLineImages, reposted: reposted)
            default:
                break
            }
            cell.addTapGestureToImages(picModels.count)
        }
    }
    
    func configureWeiboContentCell(cell: RepostCommentTableViewCell, wbContent: WBContentModel) {
        let wbUser = wbContent.belongToWBUser!
       
        cell.wbUserID = 0
        
        cell.name.text = wbUser.name
        cell.time.text = wbContent.createdDate?.getAbsoluteTime()
        
        cell.profileImage.image = nil
        
        cell.mainText.attributedText = makeAttributedString(wbContent.text ?? "")
    }
    
    func configureWeiboContentCell(cell: RepostCommentTableViewCell, wbComentContent: WBCommentContent) {
        let wbUser = wbComentContent.user!
        
        cell.wbUserID = 0
        
        cell.name.text = wbUser.name
        
        let dateFormatterFromJSON = NSDateFormatter()
    
        dateFormatterFromJSON.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        dateFormatterFromJSON.locale = NSLocale(localeIdentifier: "en_US")

        cell.time.text = dateFormatterFromJSON.dateFromString(wbComentContent.created_at)!.getAbsoluteTime()
        
        cell.profileImage.image = nil
        
        cell.mainText.attributedText = makeAttributedString(wbComentContent.text ?? "")
    }
    
    
//    func configureWeiboContentCell(cell: TimeLineTypeCell, index: Int) {
//        let wbContent = weiboContent[index]
//        configureWeiboContentCell(cell, wbContent: wbContent)
//    }
    
//    func configureWeiboContentCell(cell: TimeLineTypeCell, index: Int, weiboID: Int) {
//        let wbContent = weiboContent[index]
//        if wbContent.wbID == weiboID {
//            configureWeiboContentCell(cell, wbContent: wbContent)
//        }else if wbContent.repostContent?.wbID == weiboID {
//            configureWeiboContentCell(cell, wbContent: wbContent.repostContent!)
//        }
//    }

    
    func estimateCellHeight(framWidth: CGFloat,cell: TimeLineTypeCell, wbContent: WBContentModel) -> CGFloat {
        
        if let cellHeight = wbContent.cellHeight {
            return CGFloat(cellHeight)
        }else{
            
            configureWeiboContentCell(cell, wbContent: wbContent)
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            cell.bounds = CGRectMake(0, 0,framWidth, cell.bounds.height)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            var fittingSize = UILayoutFittingCompressedSize
            fittingSize.width = cell.bounds.width
            
            let size = cell.contentView.systemLayoutSizeFittingSize(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
            
            wbContent.cellHeight = size.height
            
            //print("Row: \(index) width: \(size.width) height: \(size.height)")
            
            return size.height
        }
    }
    
    func estimateCellHeight(framWidth: CGFloat,cell: RepostCommentTableViewCell, wbContent: WBContentModel) -> CGFloat {
        
        configureWeiboContentCell(cell, wbContent: wbContent)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.bounds = CGRectMake(0, 0,framWidth, cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var fittingSize = UILayoutFittingCompressedSize
        fittingSize.width = cell.bounds.width
        
        let size = cell.contentView.systemLayoutSizeFittingSize(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
        
//        print("width: \(size.width) height: \(size.height)")
        
        return size.height
        
    }
    
    func estimateCellHeight(framWidth: CGFloat,cell: RepostCommentTableViewCell, wbComentContent: WBCommentContent) -> CGFloat {
        
        configureWeiboContentCell(cell, wbComentContent: wbComentContent)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.bounds = CGRectMake(0, 0,framWidth, cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var fittingSize = UILayoutFittingCompressedSize
        fittingSize.width = cell.bounds.width
        
        let size = cell.contentView.systemLayoutSizeFittingSize(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
        
//        print("width: \(size.width) height: \(size.height) content: \(wbComentContent.text)")
        
        return size.height
        
    }
    
}
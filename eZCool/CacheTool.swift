//
//  CacheTool.swift
//  eZCool
//
//  Created by BinWu on 5/19/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

enum CacheError: ErrorType {
    case WrongURL
    case DataError
    case OutOfRange
}

class CacheTool{
    private var weiboContents = [WBContentModel]()
    private let userDefault = UserDefaults()
    
    func getWeiboCount() -> Int {
        weiboContents = DatabaseProcessCenter().getTimelineWeiboContentInDisk()
        if weiboContents.count > 0 {
            userDefault.sinceID = Int(weiboContents.first!.wbID!)
            userDefault.maxID = Int(weiboContents.last!.wbID!)
        }
        return weiboContents.count
    }
    
    func getWeiboContent(withIndex index: Int) throws -> WBContentModel {
        guard (index < weiboContents.count) && (index >= 0) else{
            throw CacheError.OutOfRange
        }
        return weiboContents[index]
    }
    
    func getWeiboContent(withIndex index: Int, andWeiboID weiboID: Int) throws -> WBContentModel? {
        guard (index < weiboContents.count) && (index >= 0) else{
            throw CacheError.OutOfRange
        }
        
        let weiboContent = weiboContents[index]
        if weiboContent.wbID == weiboID {
            return weiboContent
        }else if weiboContent.repostContent?.wbID == weiboID {
            return weiboContent.repostContent!
        }
        return nil
    }
    
}
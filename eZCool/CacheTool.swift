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
    private var weiboContent = [WBContentModel]()
    
    func getWeiboCount() -> Int {
        weiboContent = DatabaseProcessCenter().getTimelineWeiboContentInDisk()
        return weiboContent.count
    }
    
    func getWeiboContent(withIndex index: Int) throws -> WBContentModel {
        guard (index < weiboContent.count) && (index >= 0) else{
            throw CacheError.OutOfRange
        }
        return weiboContent[index]
    }
    
}
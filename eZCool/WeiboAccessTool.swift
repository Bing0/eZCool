//
//  WeiboAccessTool.swift
//  eZCool
//
//  Created by BinWu on 5/18/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class WeiboAccessTool {
    
    let userDefault = UserDefaults()
    
    
    func getTimeline(page: Int, callback: (getJSONResult: () throws -> NSDictionary) -> Void ) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/statuses/home_timeline.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "page" : "\(page)"])
        
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    let jsonResult = try $0()
//                    print(jsonResult)
                    callback(getJSONResult: { return jsonResult })
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
}
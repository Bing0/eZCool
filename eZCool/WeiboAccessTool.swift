//
//  WeiboAccessTool.swift
//  eZCool
//
//  Created by BinWu on 5/18/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

enum WeiboAccessError: ErrorType {
    case NotNSDictionaryFormat
    case NotNSArraryFormat
}

class WeiboAccessTool {
    
    private let userDefault = UserDefaults()
    
    func getNewestTimeline(callback: (getJSONResult: () throws -> NSDictionary) -> Void ) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/statuses/home_timeline.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "since_id" : "\(userDefault.sinceID)"])
        
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Dictionary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSDictionaryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
    func getLaterTimeline(callback: (getJSONResult: () throws -> NSDictionary) -> Void ) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/statuses/home_timeline.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "max_id" : "\(userDefault.maxID)"])
        
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Dictionary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSDictionaryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
    func getRepostsCommentsCountsOf(weiboID: Int, callback: (getJSONResult: () throws -> [[String: AnyObject]]) -> Void ) throws {
       let urlPath = URLMake().makeURL("https://api.weibo.com/2/statuses/count.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "ids" : "\(weiboID)"])
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Arrary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSArraryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
    
    func getRepostsTimelineWith(weiboID: Int, callback: (getJSONResult: () throws -> NSDictionary) -> Void) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/statuses/repost_timeline.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "id" : "\(weiboID)"])
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Dictionary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSDictionaryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
   
    func getCommentsTimelineOf(weiboID: Int, callback: (getJSONResult: () throws -> NSDictionary) -> Void) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/comments/show.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "id" : "\(weiboID)"])
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Dictionary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSDictionaryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
    func getCommentsTimelineOf(weiboID: Int, maxWeiboID: Int, callback: (getJSONResult: () throws -> NSDictionary) -> Void) throws {
        let urlPath = URLMake().makeURL("https://api.weibo.com/2/comments/show.json", suffix: ["access_token" : "\(userDefault.wbtoken!)", "id" : "\(weiboID)", "max_id" : "\(maxWeiboID)"])
        do {
            try HttpTool().httpRequestWith(urlPath) {
                do{
                    switch try $0() {
                    case .Dictionary(let jsonResult):
                        callback(getJSONResult: { return jsonResult })
                    default:
                        callback(getJSONResult: { throw WeiboAccessError.NotNSDictionaryFormat } )
                    }
                }catch{
                    callback(getJSONResult: { throw error } )
                }
            }
        }catch{
            throw error
        }
    }
    
    
    //    func getWeiboByID(weiboID: String){
    //        let urlPath: String = "https://api.weibo.com/2/statuses/show.json?access_token=\(userDefault.wbtoken!)&id=\(weiboID)"
    //        let url: NSURL = (NSURL(string: urlPath))!
    //        let request1: NSURLRequest = NSURLRequest(URL: url)
    //        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
    //
    //        do{
    //            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
    //            // print(response)
    //            do {
    //                if let statuse = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? [String: AnyObject] {
    //                    if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
    //                        dataProcessCenter.parseOneWeiboRecord(wbContent, isInTimeline: false)
    //                    }
    //                }
    //            } catch let error as NSError {
    //                print(error.localizedDescription)
    //            }
    //        }catch let error as NSError
    //        {
    //            print(error.localizedDescription)
    //        }
    //    }
    
    
}
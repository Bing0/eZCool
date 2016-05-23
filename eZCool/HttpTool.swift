//
//  HttpTool.swift
//  eZCool
//
//  Created by BinWu on 5/18/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

enum HttpTooLError: ErrorType {
    case WrongURL
    case DataError
}

enum RetunType {
    case Dictionary(NSDictionary)
    case Arrary([[String: AnyObject]])
}

class HttpTool {
    
    func httpRequestWith(urlPath: String, callback: (getResult: () throws -> RetunType) -> Void) throws {
        
        guard let url = (NSURL(string: urlPath)) else{
            throw HttpTooLError.WrongURL
        }
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) in
            guard let data = data else {
                callback() { throw HttpTooLError.DataError }
                return
            }
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                    callback(getResult: {return RetunType.Dictionary(jsonResult)})
                }else if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] {
                    callback(getResult: {return RetunType.Arrary(jsonResult)})
                }
                
            } catch {
                callback(getResult: {throw error})
            }
            
        }
    }
    
}
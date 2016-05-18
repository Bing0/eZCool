//
//  HttpTool.swift
//  eZCool
//
//  Created by BinWu on 5/18/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

enum httpTooLError: ErrorType {
    case WrongURL
    case DataError
    case OutOfRange
}

class HttpTool {
    
    func httpRequestWith(urlPath: String, callback: (getJSONResult: () throws -> NSDictionary) -> Void) throws {
        
        guard let url = (NSURL(string: urlPath)) else{
            throw httpTooLError.WrongURL
        }
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) in
            guard let data = data else {
                callback() { throw httpTooLError.DataError }
                return
            }
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
                callback(getJSONResult: {return jsonResult})
            } catch {
                callback(getJSONResult: {throw error})
            }
            
        }
    }
    
}
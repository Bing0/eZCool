//
//  URLMake.swift
//  eZCool
//
//  Created by BinWu on 5/18/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class URLMake {
    func makeURL(mainURL: String, suffix: [(String, String)]) -> String {
        
        var wholeSuffix = ""
        for (key, value) in suffix {
            wholeSuffix += "&\(key)=\(value)"
        }
        wholeSuffix.removeAtIndex(wholeSuffix.startIndex)
        wholeSuffix.insert("?", atIndex: wholeSuffix.startIndex)
        
        return mainURL + wholeSuffix
    }
    
    func makeHttpbody(parameters: [(String, String)]) -> String {
        var wholeSuffix = ""
        for (key, value) in parameters {
            wholeSuffix += "&\(key)=\(value)"
        }
        return wholeSuffix
    }
    
}
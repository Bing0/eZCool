//
//  userDefaults.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class UserDefaults {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private var _wbtoken: String?
    private var _wbRefreshToken: String?
    private var _wbCurrentUserID: String?
    private var _sinceID: Int = 0
    private var _maxID: Int = 0
    
    var wbtoken: String? {
        set {
            _wbtoken = newValue
            defaults.setValue(newValue, forKey: StoreAuthorizeKeys.wbtoken)
            defaults.synchronize()
        }
        get {
            if _wbtoken == nil {
                if let storedDefault = defaults.valueForKey(StoreAuthorizeKeys.wbtoken) {
                    _wbtoken = (storedDefault as! String)
                }
            }
            return _wbtoken
        }
    }
    var wbRefreshToken: String?{
        set {
            _wbRefreshToken = newValue
            defaults.setValue(newValue, forKey: StoreAuthorizeKeys.wbRefreshToken)
            defaults.synchronize()
        }
        get {
            if _wbRefreshToken == nil {
                if let storedDefault = defaults.valueForKey(StoreAuthorizeKeys.wbRefreshToken) {
                    _wbRefreshToken = (storedDefault as! String)
                }
            }
            return _wbRefreshToken
        }
    }
    var wbCurrentUserID: String?{
        set {
            _wbCurrentUserID = newValue
            defaults.setValue(newValue, forKey: StoreAuthorizeKeys.wbCurrentUserID)
            defaults.synchronize()
        }
        get {
            if _wbCurrentUserID == nil {
                if let storedDefault = defaults.valueForKey(StoreAuthorizeKeys.wbCurrentUserID) {
                    _wbCurrentUserID = (storedDefault as! String)
                }
            }
            return _wbCurrentUserID
        }
    }
    
    var sinceID: Int{
        set {
            _sinceID = newValue
            defaults.setValue(newValue, forKey: StoreAuthorizeKeys.sinceID)
            defaults.synchronize()
        }
        get {
            if let storedDefault = defaults.valueForKey(StoreAuthorizeKeys.sinceID) {
                _sinceID = (storedDefault as! Int)
            }
            return _sinceID
        }
    }
    
    var maxID: Int{
        set {
            _maxID = newValue
            defaults.setValue(newValue, forKey: StoreAuthorizeKeys.maxID)
            defaults.synchronize()
        }
        get {
            if let storedDefault = defaults.valueForKey(StoreAuthorizeKeys.maxID) {
                _maxID = (storedDefault as! Int)
            }
            return _maxID
        }
    }
}
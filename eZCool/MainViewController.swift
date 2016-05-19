//
//  MainViewController.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

struct StoreAuthorizeKeys {
    static let wbtoken = "WB Token"
    static let wbRefreshToken = "WB Refresh Token"
    static let wbCurrentUserID = "WB Current User ID Token"
    static let sinceID = "since ID"
    static let maxID = "max ID"
}

class MainViewController: UIViewController {
    
    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !loadPreference() {
            dispatch_async(dispatch_get_main_queue()) {
                self.getAuthorize()
            }
        }else{
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toMainPage", sender: nil)
            }
        }
    }

    func loadPreference() -> Bool{
        if userDefaults.wbtoken == nil || userDefaults.wbRefreshToken == nil || userDefaults.wbCurrentUserID == nil {
            return false
        }else{
            return true
        }
    }
    
    func getAuthorize(){
        NSNotificationCenter.defaultCenter().addObserverForName(WBNotification.AuthorizeNotification, object: UIApplication.sharedApplication().delegate , queue: NSOperationQueue.mainQueue()) { (notification) in
            if let response = notification.userInfo![WBNotification.AuthorizeKey] as? WBAuthorizeResponse {
                
                self.userDefaults.wbtoken =  response.accessToken
                self.userDefaults.wbRefreshToken = response.userInfo["refresh_token"] as? String
                self.userDefaults.wbCurrentUserID = response.userID
                
                print("wbtoken \(self.userDefaults.wbtoken!)")
                print("wbRefreshToken \(self.userDefaults.wbRefreshToken!)")
                print("wbCurrentUserID \(self.userDefaults.wbCurrentUserID!)")
                self.performSegueWithIdentifier("toMainPage", sender: nil)
            }
        }
        
        let request = WBAuthorizeRequest()
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "all"
        request.userInfo = [
            "SSO_From": "ViewController"
        ]
        
        WeiboSDK.sendRequest(request)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

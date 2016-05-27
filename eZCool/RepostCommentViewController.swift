//
//  RepostCommentViewController.swift
//  eZCool
//
//  Created by Bin on 5/27/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import UIKit

class RepostCommentViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {

    @IBOutlet weak var originalContent: UILabel!
    
    @IBOutlet weak var bottomGap: NSLayoutConstraint!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholder: UILabel!
    
    
    var originalContentAttributedString: NSAttributedString!
    var weiboID: Int!
    
    var isComment: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.]
        textHeightConstraint.active = false
        if (originalContentAttributedString != nil) {
            originalContent.attributedText = originalContentAttributedString
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        scrollView.delegate = self
        
        textView.becomeFirstResponder()
        textView.delegate = self
        
        self.navigationItem.title = "Write comment"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(self.sendRepostComment(_:)))

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomGap.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomGap.constant = 0
        })
    }
    
    
    func sendRepostComment(sender: UIBarButtonItem) {
        print("send")
        if isComment == true {
            do{
                try WeiboAccessTool().sendWeiboComment(toWeiboID: weiboID, comment: textView.text) {
                    do {
                        let jsonResult = try $0()
                        
                        if jsonResult["error_code"] != nil {
                            print("sent failed")
                        }else{
                            print("sent succeed")
                        }
                    }catch{
                        
                    }
                }
            }catch{
                print(error)
            }
        }else{
            do{
                try WeiboAccessTool().repostWeibo(weiboID, status: textView.text) {
                    do {
                        let jsonResult = try $0()

                        if jsonResult["error_code"] != nil {
                            print("repost failed")
                        }else{
                            print("repost succeed")
                        }
                        
                    }catch{
                        
                    }
                }
            }catch{
                print(error)
            }
        }
        
    }
    
    
    func textViewDidChange(textView: UITextView) {
        if !textView.text.isEmpty {
            placeholder.hidden = true
        }else{
            placeholder.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
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

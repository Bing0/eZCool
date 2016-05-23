//
//  ParseWBContent.swift
//  eZCool
//
//  Created by BinWu on 4/30/16.
//  Copyright © 2016 BinWu. All rights reserved.
//

import Foundation

class WBContent {
    var created_at: String!             //微博创建时间
    var id: Int!                        //微博ID
    var mid: Int!                       //微博MID
    var idstr: String!                  //字符串型的微博ID
    var text: String!                   //微博信息内容
    var source:	String!                 //微博来源
    var favorited: Bool!                //是否已收藏，true：是，false：否
    var truncated: Bool!                //是否被截断，true：是，false：否
    var in_reply_to_status_id :String!  //（暂未支持）回复ID
    var in_reply_to_user_id: String!    //（暂未支持）回复人UID
    var in_reply_to_screen_name: String!//（暂未支持）回复人昵称
    var thumbnail_pic: String?          //缩略图片地址，没有时不返回此字段
    var bmiddle_pic: String?            //中等尺寸图片地址，没有时不返回此字段
    var original_pic: String?           //原始图片地址，没有时不返回此字段
    var geo: WBGeo?                     //地理信息字段
    var user: WBUser?                   //微博作者的用户信息字段
    var retweeted_status: WBContent?      //被转发的原微博信息字段，当该微博为转发微博时返回
    var reposts_count: Int!             //转发数
    var comments_count: Int!            //评论数
    var attitudes_count: Int!           //表态数
    var mlevel: Int!                    //暂未支持
    var visible: AnyObject!             //微博的可见性及指定可见分组信息。该object中type取值，0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
//    var pic_ids: AnyObject?             //微博配图ID。多图时返回多图ID，用来拼接图片url。用返回字段thumbnail_pic的地址配上该返回字段的图片ID，即可得到多个图片url。
    var pic_urls = [String]()
    
    var ad: [AnyObject]?              //微博流内的推广微博ID
}

class WBCommentContent {
    var created_at: String!             //微博创建时间
    var id: Int!                        //微博ID
    var mid: Int!                       //微博MID
    var idstr: String!                  //字符串型的微博ID
    var text: String!                   //微博信息内容
    var source:	String!                 //微博来源
    var reply_comment: WBCommentContent?      //被转发的原微博信息字段，当该微博为转发微博时返回
    var user: WBUser?                   //微博作者的用户信息字段
}

class WBGeo {
    var longitude: String!      //经度坐标
    var latitude: String!       //维度坐标
    var city:String!            //所在城市的城市代码
    var province: String!       //所在省份的省份代码
    var city_name: String!      //所在城市的城市名称
    var province_name: String!  //所在省份的省份名称
    var address: String!        //所在的实际地址，可以为空
    var pinyin: String?         //地址的汉语拼音，不是所有情况都会返回该字段
    var more: String?           //更多信息，不是所有情况都会返回该字段
}

class WBUser {
    var id: Int!                    //用户UID
    var idstr: String!              //字符串型的用户UID
    var screen_name: String!        //用户昵称
    var name: String!               //友好显示名称
    var province: Int!              //用户所在省级ID
    var city: Int!                  //用户所在城市ID
    var location: String!           //用户所在地
    var description: String!        //用户个人描述
    var url: String!                //用户博客地址
    var profile_image_url: String!  //用户头像地址（中图），50×50像素
    var profile_url: String!        //用户的微博统一URL地址
    var domain: String!             //用户的个性化域名
    var weihao:	String!             //用户的微号
    var gender:	String!             //性别，m：男、f：女、n：未知
    var followers_count: Int!       //粉丝数
    var friends_count: Int!         //关注数
    var statuses_count: Int!        //微博数
    var favourites_count: Int!      //收藏数
    var created_at: String!         //用户创建（注册）时间
    var following: Bool!            //暂未支持
    var allow_all_act_msg: Bool!	//是否允许所有人给我发私信，true：是，false：否
    var geo_enabled: Bool!          //是否允许标识用户的地理位置，true：是，false：否
    var verified: Bool!             //是否是微博认证用户，即加V用户，true：是，false：否
    var verified_type: Int!         //暂未支持
    var remark: String!             //用户备注信息，只有在查询用户关系时才返回此字段
    var status:	WBContent!          //用户的最近一条微博信息字段
    var allow_all_comment: Bool!	//是否允许所有人对我的微博进行评论，true：是，false：否
    var avatar_large: String!       //用户头像地址（大图），180×180像素
    var avatar_hd: String!          //用户头像地址（高清），高清头像原图
    var verified_reason: String!	//认证原因
    var follow_me: Bool!            //该用户是否关注当前登录用户，true：是，false：否
    var online_status: Int!         //用户的在线状态，0：不在线、1：在线
    var bi_followers_count: Int!	//用户的互粉数
    var lang: String!               //用户当前的语言版本，zh-cn：简体中文，zh-tw：繁体中文，en：英语
}


class ParseWBContent {
    
    func parseOneWBContent(json :Dictionary<String, AnyObject>) -> WBContent? {
        let wbContent = WBContent()
//        print(json)
        wbContent.created_at = json["created_at"] as! String
        wbContent.id = json["id"]  as! Int                 //微博ID
        wbContent.mid = Int(json["mid"] as! String)                       //微博MID
        wbContent.idstr = json["idstr"] as! String                 //字符串型的微博ID
        wbContent.text = json["text"] as! String                   //微博信息内容
        wbContent.source = json["source"] as? 	String                 //微博来源
        wbContent.favorited = json["favorited"] as?  Bool   //是否已收藏，true：是，false：否
        wbContent.truncated = json["truncated"] as?  Bool                //是否被截断，true：是，false：否
        wbContent.in_reply_to_status_id  = json["in_reply_to_status_id"] as? String  //（暂未支持）回复ID
        wbContent.in_reply_to_user_id = json["in_reply_to_user_id"] as?  String    //（暂未支持）回复人UID
        wbContent.in_reply_to_screen_name = json["in_reply_to_screen_name"] as? String//（暂未支持）回复人昵称
        wbContent.thumbnail_pic = json["thumbnail_pic"] as?  String          //缩略图片地址，没有时不返回此字段
        wbContent.bmiddle_pic = json["bmiddle_pic"] as?  String            //中等尺寸图片地址，没有时不返回此字段
        wbContent.original_pic = json["original_pic"] as?  String           //原始图片地址，没有时不返回此字段
        
//        if let geo = json["geo"] as? [String: AnyObject]{
//            wbContent.geo = parseGeo(geo)                //地理信息字段
//            geo =     {
//                coordinates =         (
//                    "31.10969",
//                    "121.520699"
//                );
//                type = Point;
//            };
//        }
        if let user = json["user"] as? [String: AnyObject]{
            wbContent.user = parseUser(user)                //微博作者的用户信息字段
        }
        if let retweeted_status = json["retweeted_status"] as? [String: AnyObject]{
             wbContent.retweeted_status = parseOneWBContent(retweeted_status)      //被转发的原微博信息字段，当该微博为转发微博时返回
        }
        wbContent.reposts_count = json["reposts_count"] as? Int            //转发数
        wbContent.comments_count = json["comments_count"] as?  Int            //评论数
        wbContent.attitudes_count = json["attitudes_count"] as?  Int           //表态数
        wbContent.mlevel = json["mlevel"] as? Int                   //暂未支持
        //        wbContent.visible = json["visible"] as!  AnyObject             //微博的可见性及指定可见分组信息。该object中type取值，0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
        //        wbContent.pic_ids = json["pic_ids"] as!  AnyObject?             //微博配图ID。多图时返回多图ID，用来拼接图片url。用返回字段thumbnail_pic的地址配上该返回字段的图片ID，即可得到多个图片url。
        //        wbContent.ad = json["ad"] as!  [AnyObject]?              //微博流内的推广微博ID
        if let picURLs = json["pic_urls"] as? [[String: AnyObject]] {
            for picURL in picURLs {
                if let picurl = picURL["thumbnail_pic"] as? String{
                    wbContent.pic_urls.append(picurl)
                }
            }
        }        
        return wbContent
    }
    
    func parseOneWeiboCommentContent(json :Dictionary<String, AnyObject>) -> WBCommentContent? {
        let wbCommentContent = WBCommentContent()
        //        print(json)
        wbCommentContent.created_at = json["created_at"] as! String
        wbCommentContent.id = json["id"]  as! Int                 //微博ID
        wbCommentContent.mid = Int(json["mid"] as! String)                       //微博MID
        wbCommentContent.idstr = json["idstr"] as! String                 //字符串型的微博ID
        wbCommentContent.text = json["text"] as! String                   //微博信息内容
        wbCommentContent.source = json["source"] as? 	String                 //微博来源
        if let user = json["user"] as? [String: AnyObject]{
            wbCommentContent.user = parseUser(user)                //微博作者的用户信息字段
        }
        if let retweeted_status = json["reply_comment"] as? [String: AnyObject]{
            wbCommentContent.reply_comment = parseOneWeiboCommentContent(retweeted_status)      //被转发的原微博信息字段，当该微博为转发微博时返回
        }
        return wbCommentContent
    }
    
    func parseGeo(json :Dictionary<String, AnyObject>) -> WBGeo {
        let wbGeo = WBGeo()
        
        wbGeo.longitude = json["longitude"] as! String      //经度坐标
        wbGeo.latitude = json["latitude"] as! String       //维度坐标
        wbGeo.city = json["city"] as! String            //所在城市的城市代码
        wbGeo.province = json["province"] as! String       //所在省份的省份代码
        wbGeo.city_name = json["city_name"] as! String      //所在城市的城市名称
        wbGeo.province_name = json["province_name"] as! String  //所在省份的省份名称
        wbGeo.address = json["address"] as! String        //所在的实际地址，可以为空
        wbGeo.pinyin = json["pinyin"] as! String?         //地址的汉语拼音，不是所有情况都会返回该字段
        wbGeo.more = json["more"] as! String?           //更多信息，不是所有情况都会返回该字段
        return wbGeo
    }
    
    func parseUser(json :Dictionary<String, AnyObject>) -> WBUser {
        let wbUser = WBUser()
        
        wbUser.name = json["name"] as! String
        
        wbUser.id = json["id"] as! Int                    //用户UID
        wbUser.idstr = json["idstr"] as! String              //字符串型的用户UID
        wbUser.screen_name = json["screen_name"] as! String        //用户昵称
        wbUser.name = json["name"] as! String               //友好显示名称
        wbUser.province = Int(json["province"] as! String)              //用户所在省级ID
        wbUser.city = Int(json["city"] as! String)                  //用户所在城市ID
        wbUser.location = json["location"] as! String           //用户所在地
        wbUser.description = json["description"] as! String        //用户个人描述
        wbUser.url = json["url"] as! String                //用户博客地址
        wbUser.profile_image_url = json["profile_image_url"] as! String  //用户头像地址（中图），50×50像素
        wbUser.profile_url = json["profile_url"] as! String        //用户的微博统一URL地址
        wbUser.domain = json["domain"] as! String             //用户的个性化域名
        wbUser.weihao = json["weihao"] as! String             //用户的微号
        wbUser.gender = json["gender"] as! String             //性别，m：男、f：女、n：未知
        wbUser.followers_count = json["followers_count"] as! Int       //粉丝数
        wbUser.friends_count = json["friends_count"] as! Int         //关注数
        wbUser.statuses_count = json["statuses_count"] as! Int        //微博数
        wbUser.favourites_count = json["favourites_count"] as! Int      //收藏数
        wbUser.created_at = json["created_at"] as! String         //用户创建（注册）时间
        wbUser.following = json["following"] as! Bool            //暂未支持
        wbUser.allow_all_act_msg = json["allow_all_act_msg"] as! Bool	//是否允许所有人给我发私信，true：是，false：否
        wbUser.geo_enabled = json["geo_enabled"] as! Bool          //是否允许标识用户的地理位置，true：是，false：否
        wbUser.verified = json["verified"] as! Bool             //是否是微博认证用户，即加V用户，true：是，false：否
        wbUser.verified_type = json["verified_type"] as! Int         //暂未支持
        wbUser.remark = json["remark"] as! String             //用户备注信息，只有在查询用户关系时才返回此字段
        if let status = json["status"] as? [String: AnyObject]{
            wbUser.status = parseOneWBContent(status)          //用户的最近一条微博信息字段
        }
        wbUser.allow_all_comment = json["allow_all_comment"] as! Bool	//是否允许所有人对我的微博进行评论，true：是，false：否
        wbUser.avatar_large = json["avatar_large"] as! String       //用户头像地址（大图），180×180像素
        wbUser.avatar_hd = json["avatar_hd"] as! String          //用户头像地址（高清），高清头像原图
        wbUser.verified_reason = json["verified_reason"] as! String	//认证原因
        wbUser.follow_me = json["follow_me"] as! Bool            //该用户是否关注当前登录用户，true：是，false：否
        wbUser.online_status = json["online_status"] as! Int         //用户的在线状态，0：不在线、1：在线
        wbUser.bi_followers_count = json["bi_followers_count"] as! Int	//用户的互粉数
        wbUser.lang = json["lang"] as! String               //用户当前的语言版本，zh-cn：简体中文，zh-tw：繁体中文，en：英语
        return wbUser
    }
    
}



class parseJSON {
    
    
    func parseHomeTimelineJSON(jsonResult: NSDictionary) -> Int{
        var newWeiboNumbers = 0
        
        if let statuses = jsonResult["statuses"] as? [[String: AnyObject]]{
            newWeiboNumbers = statuses.count
            if newWeiboNumbers > 10 {
                //delete old data
                DatabaseProcessCenter().clearWeiboHistory()
            }else{
                DatabaseProcessCenter().clearWeiboOlderThan1Day()
            }
            print("Going to Parse")
            for statuse in statuses {
                if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
                    DatabaseProcessCenter().analyseOneWeiboRecord(wbContent, isInTimeline: true)
                }
            }
            print("Parse finished")
        }
        if let errorResult = jsonResult["error"] {
            print(errorResult)
        }
        return newWeiboNumbers
    }
    
    func parseHomeLaterTimelineJSON(jsonResult: NSDictionary) -> Int{
        var newWeiboNumbers = 0
        
        if let statuses = jsonResult["statuses"] as? [[String: AnyObject]]{
            newWeiboNumbers = statuses.count
            
            print("Going to Parse")
            for statuse in statuses {
                if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
                    DatabaseProcessCenter().analyseOneWeiboRecord(wbContent, isInTimeline: true)
                }
            }
            print("Parse finished")
        }
        
        if let errorResult = jsonResult["error"] {
            print(errorResult)
        }
        return newWeiboNumbers
    }
    
    
    func parseRepostTimelineJSON(jsonResult: NSDictionary){
        //        print(jsonResult)
        
        //        print("has_unread: \(jsonResult["has_unread"])")
        //        print("hasvisible: \(jsonResult["hasvisible"])")
        //        print("interval: \(jsonResult["interval"])")
        //        print("max_id: \(jsonResult["max_id"])")
        //        print("next_cursor: \(jsonResult["next_cursor"])")
        //        print("previous_cursor: \(jsonResult["previous_cursor"])")
        //        print("since_id: \(jsonResult["since_id"])")
        
        if let statuses = jsonResult["reposts"] as? [[String: AnyObject]]{
            print("Going to Parse")
            for statuse in statuses {
                if let wbContent = ParseWBContent().parseOneWBContent(statuse) {
                    DatabaseProcessCenter().analyseOneWeiboRecord(wbContent, isInTimeline: false)
                }
            }
            print("Parse finished")
        }
        if let errorResult = jsonResult["error"] {
            print(errorResult)
        }
    }
    
    func parseCommentsTimelineJSON(jsonResult: NSDictionary) -> [WBCommentContent] {
        //        print(jsonResult)
        if let comments = jsonResult["comments"] as? [[String: AnyObject]]{
            print("Going to Parse")
            var wbCommentContents = [WBCommentContent]()
            
            for comment in comments {
                if let wbCommentContent = ParseWBContent().parseOneWeiboCommentContent(comment) {
                    wbCommentContents.append(wbCommentContent)
                }
            }
            print("Parse finished")
            return wbCommentContents
        }
        if let errorResult = jsonResult["error"] {
            print(errorResult)
        }
        return [WBCommentContent]()
    }
}








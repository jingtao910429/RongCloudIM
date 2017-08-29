//
//  RongCloudIMManager.swift
//  rabbitDoctor
//
//  Created by Mac on 2017/8/29.
//  Copyright © 2017年 rabbitDoctor. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class RongCloudIMManager: NSObject {
    
    static let shared = RongCloudIMManager()
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    override init() {
        super.init()
        
    }
    
    //RongCloud配置
    func config(
        appKey: String,
        avatarStyle: RCUserAvatarStyle,
        enablePersistentUserInfoCache: Bool,
        messageType: RCMessageContent.Type,
        messageTypeEstate: RCMessageContent.Type) {
        
        RCIM.shared().initWithAppKey(appKey)
        RCIM.shared().globalMessageAvatarStyle = avatarStyle
        RCIM.shared().enablePersistentUserInfoCache = enablePersistentUserInfoCache
        RCIM.shared().registerMessageType(messageType)
        RCIM.shared().registerMessageType(messageTypeEstate)
        
    }
    
    public func setRongCloudUserInfo() {
        
        var name = ""
        var portraitUri = ""
        var userId = ""
        if RCIM.shared().currentUserInfo != nil {
            userId = "cus\(Utils.getValueFromUserDefault(key: "customId"))"
        }
        if Utils.getValueFromUserDefault(key: "userId") != "" {
            if RCIM.shared().currentUserInfo != nil {
                name = Utils.getValueFromUserDefault(key: "nickname")
                portraitUri = Utils.getValueFromUserDefault(key: "avatarUrl")
            }
        }
        
        RCIM.shared().currentUserInfo.name = name
        RCIM.shared().currentUserInfo.portraitUri = portraitUri
        RCIM.shared().currentUserInfo.userId = userId
        RCIM.shared().enableTypingStatus = true
        RCIM.shared().refreshUserInfoCache(RCIM.shared().currentUserInfo, withUserId: RCIM.shared().currentUserInfo.userId)
    }
    
    
    public func sendMessageTypeMessage<T: RCMessageContent>(_ house: T, targetId: String) -> Observable<Bool>{
        
        let sendUserInfo = RCUserInfo()
        sendUserInfo.name = Utils.getValueFromUserDefault(key: "nickname")
        sendUserInfo.portraitUri = Utils.getValueFromUserDefault(key: "avatarUrl")
        sendUserInfo.userId = Utils.getValueFromUserDefault(key: "customId")
        
        house.senderUserInfo = sendUserInfo
        return sendMessages(targetId: targetId, content: house, pushContent: nil, pushData: nil)
    }
    
    public func sendTextMessage(targetId: String, content: String, extra: String) -> Observable<Bool> {
        let textMsg: RCTextMessage = RCTextMessage()
        textMsg.content = content
        textMsg.extra = extra
        
        let sendUserInfo = RCUserInfo()
        sendUserInfo.name = Utils.getValueFromUserDefault(key: "nickname")
        sendUserInfo.portraitUri = Utils.getValueFromUserDefault(key: "avatarUrl")
        sendUserInfo.userId = Utils.getValueFromUserDefault(key: "customId")
        
        textMsg.senderUserInfo = sendUserInfo
        return sendMessages(targetId: targetId, content: textMsg, pushContent: nil, pushData: nil)
    }
    
    public func sendMessages(targetId: String, content: RCMessageContent, pushContent: String? = nil, pushData: String? = nil) -> Observable<Bool> {
        return Observable.create { [weak self] observer -> Disposable in
            
            RCIMClient.shared().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: targetId, content: content, pushContent: pushContent, pushData: pushData, success: { (messageId) in
                println("send success")
                
                self?.sendMsgToServer(toUserId: targetId, content: content).subscribe(onNext: { (response) in
                    observer.onNext(true)
                }, onError: { (error) in
                    observer.onError(error)
                }, onCompleted: { 
                    observer.onCompleted()
                }).addDisposableTo((self?.disposeBag)!)
            }, error: { (error, errorCode) in
                observer.onError(NSError(domain: "", code: error.rawValue, userInfo: nil))
            })
            
            return Disposables.create()
        }
    }
    
    fileprivate func sendMsgToServer(toUserId: String, content: RCMessageContent, houseId: Int? = 0, houseName: String? = "") -> Observable<Response> {
        
        switch content {
        case is MessageTypeEstate:
            let msg = content as! MessageTypeEstate
            return addChat(toUserId: toUserId, content: content, houseId: msg.house_id, houseName: msg.house_name)
        case is MessageType:
            let msg = content as! MessageType
            return addChat(toUserId: toUserId, content: content, houseId: msg.house_id, houseName: msg.house_name)
        case is RCTextMessage:
            let msg = content as! RCTextMessage
            let extra = msg.extra
            let houseTuple: (String, Int) = sepExtraString(source: (extra! as NSString).substring(from: 5))
            return addChat(toUserId: toUserId, content: content, houseId: houseTuple.1, houseName: houseTuple.0)
        default:
            println("----- can not know message type")
            return Observable<Response>.create{observer in
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }
    
    fileprivate func addChat(toUserId: String, content: RCMessageContent, houseId: Int, houseName: String) -> Observable<Response> {
        let strEncode = String.init(data: content.encode(), encoding: String.Encoding.utf8)
        return rongCloudIMAPIProvider
               .request(RongCloudIMAPIService.addChat(userId: Utils.getValueFromUserDefault(key: "customId"), toUserID: toUserId, content: strEncode ?? "", houseId: houseId, houseName: houseName))
    }
    
    fileprivate func sepExtraString(source: String) -> (String, Int) {
        let array = source.components(separatedBy: "&")
        guard array.count == 2 else {
            return (array[0], 0)
        }
        let houseId = array[1].components(separatedBy: "!")[1].toInt()
        return (array[0], houseId!)
    }
}

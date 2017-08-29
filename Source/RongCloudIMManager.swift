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
import ObjectMapper

enum RongCloudIMType {
    case customer
    case agent
}

class RongCloudIMManager: NSObject {
    
    static let shared = RongCloudIMManager()
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate var iMType: RongCloudIMType = RongCloudIMType.customer
    fileprivate var connectState = PublishSubject<RCConnectionStatus>()
    fileprivate var updateMessageCount = PublishSubject<Int>()
    fileprivate var offLine = PublishSubject<Bool>()
    
    override init() {
        super.init()
    }
    
    //RongCloud配置
    func config(
        iMType: RongCloudIMType,
        appKey: String,
        avatarStyle: RCUserAvatarStyle,
        enablePersistentUserInfoCache: Bool,
        messageType: RCMessageContent.Type,
        messageTypeEstate: RCMessageContent.Type) {
        
        self.iMType = iMType
        
        RCIM.shared().initWithAppKey(appKey)
        RCIM.shared().globalMessageAvatarStyle = avatarStyle
        RCIM.shared().enablePersistentUserInfoCache = enablePersistentUserInfoCache
        RCIM.shared().registerMessageType(messageType)
        RCIM.shared().registerMessageType(messageTypeEstate)
        RCIM.shared().userInfoDataSource = self
        RCIM.shared().connectionStatusDelegate = self
        RCIM.shared().receiveMessageDelegate = self
        
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
        
        RCIM.shared().enableTypingStatus = true
        self.refreshUserInfoCache(name: name, portraitUri: portraitUri, userId: userId)
    }
    
    public func refreshUserInfoCache(name: String, portraitUri: String, userId: String) {
        let userInfo = RCUserInfo()
        userInfo.name = name
        userInfo.portraitUri = portraitUri
        userInfo.userId = userId
        RCIM.shared().refreshUserInfoCache(userInfo, withUserId: userId)
    }
    
    //RongCloudServer连接
    public func connectServer(token: String?) -> Observable<String> {
        
        if let token = token {

            return Observable.create { observer -> Disposable in
                
                RCIM.shared().connect(withToken: token, success: { (userId) in
                    if let _ = userId {
                        observer.onNext(userId!)
                    } else {
                        print("userId无法获取")
                        observer.onCompleted()
                    }
                }, error: { (status) in
                    print("登陆的错误码为\(status)")
                    observer.onCompleted()
                }, tokenIncorrect: {
                    print("token错误")
                    observer.onCompleted()
                })
            
                return Disposables.create()
            }
        }
        
        return Observable<String>.create{observer in
            observer.onCompleted()
            return Disposables.create()
        }
        
    }
    
    //RongCloudServer登出
    public func logout() {
        RCIM.shared().logout()
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
    
    public func sendMessages(
        targetId: String,
        content: RCMessageContent,
        pushContent: String? = nil,
        pushData: String? = nil) -> Observable<Bool> {
        
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
    
    fileprivate func sendMsgToServer(
        toUserId: String,
        content: RCMessageContent,
        houseId: Int? = 0,
        houseName: String? = "") -> Observable<Response> {
        
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
    
    fileprivate func addChat(
        toUserId: String,
        content: RCMessageContent,
        houseId: Int,
        houseName: String) -> Observable<Response> {
        
        let strEncode = String.init(data: content.encode(), encoding: String.Encoding.utf8)
        
        switch self.iMType {
        case .customer:
            return rongCloudIMAPIProvider
                .request(RongCloudIMAPIService.customerAddChat(userId: Utils.getValueFromUserDefault(key: "customId"), toUserID: toUserId, content: strEncode ?? "", houseId: houseId, houseName: houseName))
        default:
            return rongCloudIMAPIProvider
                .request(RongCloudIMAPIService.agentAddChat(userId: Utils.getValueFromUserDefault(key: "customId"), toUserID: toUserId, content: strEncode ?? "", houseId: houseId, houseName: houseName))
        }
        
    }
    
    //获取指定客户信息
    fileprivate func fetchRongCloudUserInfo<T: BaseMappable>(userId: String?, type: T.Type) -> Observable<T> {
        guard userId != nil && userId != "" else {
            return Observable<T>.create{observer in
                observer.onCompleted()
                return Disposables.create()
            }
        }
        
        switch self.iMType {
        case .customer:
            RCIMClient.shared().clearMessagesUnreadStatus(RCConversationType.ConversationType_PRIVATE, targetId: userId)
            return rongCloudIMAPIProvider
                .request(RongCloudIMAPIService.getCustomerUserInfo(userId: userId!))
                .mapObject(type)
        default:
            return rongCloudIMAPIProvider
                .request(RongCloudIMAPIService.getAgentUserInfo(userId: userId!))
                .mapObject(type)
        }
        
    }
    
    fileprivate func fetchUserInfoFromDataSource(userId: String) -> Observable<RCUserInfo> {
        
        return Observable<RCUserInfo>.create { observer -> Disposable in
            
            RCIM.shared().userInfoDataSource.getUserInfo(withUserId: userId) { (userInfo) in
                if let userInfo = userInfo {
                    observer.onNext(userInfo)
                } else {
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
        
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

// MARK: - 用户信息获取
extension RongCloudIMManager: RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        
        let user = RCUserInfo()
        if userId == nil || userId.length == 0 {
            return completion(nil)
        } else {
//            switch self.iMType {
//            case .customer:
//                self.fetchRongCloudUserInfo(userId: userId, type: RongCloudUserModel.self).subscribe(onNext: { (result) in
//                    if let userInfo = result.body {
//                        user.name = userInfo.nickname
//                        user.portraitUri = userInfo.avatarurl
//                        self.refreshUserInfoCache(name: userInfo.nickname, portraitUri: userInfo.avatarurl, userId: userId)
//                    }
//                    return completion(user)
//                }, onError: { (error) in
//                    print(error)
//                }).addDisposableTo(disposeBag)
//            default:
//                break
//            }
        }
    }
}

// MARK: - 连接状态监听
extension RongCloudIMManager: RCIMConnectionStatusDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        self.connectState.onNext(status)
        if status == RCConnectionStatus.ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT {
            self.offLine.onNext(true)
        }
    }
}

// MARK: - 新消息接收监听
extension RongCloudIMManager: RCIMReceiveMessageDelegate {
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        if left == 0 {
            DispatchQueue.main.async {
                let unreadCount = RCIMClient.shared().getTotalUnreadCount()
                self.updateMessageCount.onNext(Int(unreadCount))
            }
        }
    }
    
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        return true
    }
    
    func onRCIMCustomLocalNotification(_ message: RCMessage!, withSenderName senderName: String!) -> Bool {
        return true
    }
}

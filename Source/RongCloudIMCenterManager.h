//
//  RongCloudIMCenterManager.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongCloudIMManager.h"

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>
#else
#if __has_include("ReactiveCocoa.h")
#import "ReactiveCocoa.h"
#endif
#endif

//#if __has_include(<RongIMKit/RongIMKit.h>)
//#import <RongIMKit/RongIMKit.h>
//#else
//#if __has_include("RongIMKit.h")
//#import "RongIMKit.h"
//#endif
//#endif
//
//#if __has_include(<RongIMLib/RongIMLib.h>)
//#import <RongIMLib/RongIMLib.h>
//#else
//#if __has_include("RongIMLib.h")
//#import "RongIMLib.h"
//#endif
//#endif

@interface RongCloudIMCenterManager : NSObject

#ifdef RAC
typedef RACStream *(^RongCloudIMFlattenMapBlock)(RACTuple *tuple);
#endif

/**
 单例对象
 */
+ (instancetype)manager;

#ifdef RAC
/** RAC链式发送请求 */

//消息连接
//- (RACSignal *)connectExecuteSignal;
////消息logout
//- (RACSignal *)logoutExecuteSignal;
//消息发送
- (RACSignal *)executeSignal;
- (RACSignal *)sendMessagesExecuteSignal;
- (RACSignal *)sendMsgToServerExecuteSignal;
#endif

#pragma mark 链式调用

/*
 targetId: String,
 sendUserInfo: RCUserInfo,
 content: RCMessageContent,
 pushContent: String? = nil,
 pushData: String? = nil
 */

/** 链式调用 */
- (RongCloudIMCenterManager *(^)(NSString *targetId,
                                 RCUserInfo *sendUserInfo,
                                 RCMessageContent *content,
                                 NSString *pushContent,
                                 NSString *pushData))sendMessages;
/*
 targetId: String, sendUserInfo: RCUserInfo, content: String, extra: String
 */
- (RongCloudIMCenterManager *(^)(NSString *targetId,
                                   RCUserInfo *sendUserInfo,
                                   RCMessageContent *content,
                                   NSString *extra))sendTextMessage;

/*
 toUserId: String,
 sendUserInfo: RCUserInfo,
 content: RCMessageContent,
 houseId: Int? = 0,
 houseName: String? = ""
 */

- (RongCloudIMCenterManager *(^)(NSString *toUserId,
                                 RCUserInfo *sendUserInfo,
                                 RCMessageContent *content,
                                 NSInteger houseId,
                                 NSString *houseName))sendMsgToServer;


@end

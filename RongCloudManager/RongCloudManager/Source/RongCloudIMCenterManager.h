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
- (RACSignal *)connectExecuteSignal;
//消息logout
- (RACSignal *)logoutExecuteSignal;
//消息发送
- (RACSignal *)executeSignal;
- (RACSignal *)sendMessagesExecuteSignal;
- (RACSignal *)sendMsgToServerExecuteSignal;
#endif

#pragma mark 链式调用
/** 链式调用 */
- (RongCloudIMCenterManager *(^)(NSString *token))connect;
- (RongCloudIMCenterManager *(^)(NSString *targetId,
                                 RCUserInfo *sendUserInfo,
                                 RCMessageContent *content,
                                 NSString *pushContent,
                                 NSString *pushData))sendMessages;
- (RongCloudIMCenterManager *(^)(NSString *targetId,
                                   RCUserInfo *sendUserInfo,
                                   RCMessageContent *content,
                                   NSString *extra))sendTextMessage;
- (RongCloudIMCenterManager *(^)(NSString *toUserId,
                                 RCUserInfo *sendUserInfo,
                                 RCMessageContent *content,
                                 NSInteger houseId,
                                 NSString *houseName))sendMsgToServer;


@end

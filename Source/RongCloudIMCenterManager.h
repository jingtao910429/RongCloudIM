//
//  RongCloudIMCenterManager.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongCloudIMManager.h"

@interface RongCloudIMCenterManager : NSObject

/**
 单例对象
 */
+ (instancetype)manager;

//消息连接
- (void)connect:(void (^)(NSString *userId))successBlock;
//logOut
- (void)logOut;

//更新SDK中的用户信息缓存
- (void)refreshUserInfoCache;


#pragma mark 链式调用
/** 链式调用 */

- (RongCloudIMCenterManager *(^)(NSString *token))token;
- (RongCloudIMCenterManager *(^)(RCUserInfo *userInfo, NSString *userId))refreshCache;

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

- (RongCloudIMCenterManager *(^)(NSString *toUserId,
                                 RCMessageContent *content,
                                 NSInteger houseId,
                                 NSString *houseName))chat;


@end

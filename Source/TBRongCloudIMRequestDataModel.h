//
//  TBRongCloudIMRequestData.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCUserInfo;
@class RCMessageContent;

/*
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 */

@interface TBRongCloudIMRequestDataModel : NSObject

@property (nonatomic, copy)   NSString *token;
@property (nonatomic, copy)   NSString *targetId;
@property (nonatomic, strong) RCMessageContent *content;
@property (nonatomic, copy)   NSString *pushContent;
@property (nonatomic, copy)   NSString *pushData;
@property (nonatomic, strong)   RCUserInfo *userInfo;

@end

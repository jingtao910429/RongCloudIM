//
//  RongCloudIMCenterManager.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBRongCloudIMProtocol.h"
#import "TBRongCloudIMRequestDataModel.h"
#import "TBMessageUserInfo.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>

/*
 消息中心管理类，对外提供基础接口
 */
@interface RongCloudIMCenterManager : NSObject

+ (instancetype)manager;

@property (nonatomic, copy) UserInfoDataSourceResult userInfoDataSourceResult;
@property (nonatomic, copy) ConnectionStatusBlock connectionStatusBlock;
@property (nonatomic, copy) ConnectionOffLineBlock connectionOffLineBlock;
@property (nonatomic, copy) ReceiveMessageBlock receiveMessageBlock;
@property (nonatomic, copy) SendMessageToServer sendMessageToServer;

//消息配置
- (void)configWithAppKey:(NSString *)key;
- (void)disconnect:(BOOL)isReceivePush;
- (void)disconnect;
- (void)logOut;

//消息连接
- (void)connectWithRequestData:(TBRongCloudIMRequestDataModel *)requestData successBlock:(void (^)(NSString *userId))successBlock;

//更新SDK中的用户信息缓存
- (void)refreshUserInfoCache:(TBMessageUserInfo *)userInfo withUserId:(NSString *)userId;
//获取SDK中缓存的用户信息
- (RCUserInfo *)getUserInfoCache:(NSString *)userId;
//清空SDK中所有的用户信息缓存
- (void)clearUserInfoCache;

- (void)refreshRongCloudUserInfo:(TBMessageUserInfo *)userInfo;
- (NSInteger)getUnReadMessageCount;

@end

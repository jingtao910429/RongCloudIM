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
@interface TBRongCloudIMCenterManager : NSObject

+ (instancetype)manager;

@property (nonatomic, copy) UserInfoDataSourceResult userInfoDataSourceResult;
@property (nonatomic, copy) ConnectionStatusBlock connectionStatusBlock;
@property (nonatomic, copy) ConnectionOffLineBlock connectionOffLineBlock;
@property (nonatomic, copy) ReceiveMessageBlock receiveMessageBlock;
@property (nonatomic, copy) SendMessageToServer sendMessageToServer;

//消息配置
- (void)configWithAppKey:(NSString *)key;
//断开与融云服务器的连接，但仍然接收远程推送
- (void)disconnect;
//断开与融云服务器的连接，并不再接收远程推送
- (void)logOut;

//消息连接
- (void)connectWithRequestData:(TBRongCloudIMRequestDataModel *)requestData successBlock:(void (^)(NSString *userId))successBlock;

//更新SDK中的用户信息缓存
- (void)refreshUserInfoCache:(TBMessageUserInfo *)userInfo;
//获取SDK中缓存的用户信息
- (RCUserInfo *)getUserInfoCache:(NSString *)userId;
//清空SDK中所有的用户信息缓存
- (void)clearUserInfoCache;

- (void)refreshRongCloudUserInfo:(TBMessageUserInfo *)userInfo;
- (NSInteger)getUnReadMessageCount;

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion;
@end

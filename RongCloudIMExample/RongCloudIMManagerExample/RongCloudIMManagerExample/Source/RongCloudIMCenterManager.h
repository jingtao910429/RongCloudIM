//
//  RongCloudIMCenterManager.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongCloudIMManager.h"

typedef void*(^ConnectionStatusBlock)(RCConnectionStatus status);
typedef void*(^OffLine)(BOOL offLine);
typedef void*(^UpdateMessageCount)(NSInteger messageCount);

@protocol IMCUserInfoDataSource <NSObject>

@required
- (void)getUserInfoWithUserId:(NSString *)userId
                           completion:(void (^)(RCUserInfo *userInfo))completion;
@required
- (void)addToChat:(NSString *)userId content:(NSString *)content houseId:(NSInteger)houseId houseName:(NSString *)houseName;

@end

@interface RongCloudIMCenterManager : NSObject <RCIMUserInfoDataSource>

/**
 单例对象
 */
+ (instancetype)manager;

@property (nonatomic, weak) id <IMCUserInfoDataSource> delegate;
@property (nonatomic, copy) ConnectionStatusBlock connectionStatusBlock;
@property (nonatomic, copy) OffLine offLine;
@property (nonatomic, copy) UpdateMessageCount updateMessageCount;

#pragma mark 参数设置

- (RongCloudIMCenterManager *)token:(NSString *)token;

- (RongCloudIMCenterManager *)refreshCache:(RCUserInfo *)userInfo userId:(NSString *)userId;

- (RongCloudIMCenterManager *)sendMessageAssociateType:(RCMessageContent *)content
                                              userInfo:(RCUserInfo *)userInfo
                                              targetId:(NSString *)targetId;

- (RongCloudIMCenterManager *)sendTextMessage:(NSString *)targetId
                                     userInfo:(RCUserInfo *)userInfo
                                      content:(NSString *)content
                                        extra:(NSString *)extra;

- (RongCloudIMCenterManager *)sendMessageToServer:(NSString *)userId
                                     userInfo:(RCUserInfo *)userInfo
                                      content:(RCMessageContent *)content
                                      houseId:(NSInteger)houseId
                                    houseName:(NSString *)houseName;

//消息配置
- (void)config:(NSString *)key classes:(NSArray *)messageClasses dataSource:(id <IMCUserInfoDataSource>)delegate;

//消息连接
- (void)connect:(void (^)(NSString *userId))successBlock;
//logOut
- (void)logOut;

//获取所有的未读消息数
- (NSInteger)getTotalUnreadCount;

//更新SDK中的用户信息缓存
- (void)refreshUserInfoCache;
//获取SDK中缓存的用户信息
- (RCUserInfo *)getUserInfoCache:(NSString *)userId;
//清空SDK中所有的用户信息缓存
- (void)clearUserInfoCache;

//获取用户信息
- (void)getUserInfoFromDataSourceWithUserId:(NSString *)userId
                                   targetId:(NSString *)targetId
                                 completion:(void (^)(RCUserInfo *userInfo))completion;

//消息发送
- (void)sendMessageAssociateType:(void (^)(long messageId))successBlock
                           error:(void (^)(RCErrorCode nErrorCode,
                                           long messageId))errorBlock;
- (void)sendTextMessage:(void (^)(long messageId))successBlock
                  error:(void (^)(RCErrorCode nErrorCode,
                                  long messageId))errorBlock;
- (void)sendMessageToServer:(void (^)())successBlock
                      error:(void (^)(NSError *error))errorBlock;

@end

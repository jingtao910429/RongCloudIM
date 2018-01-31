//
//  RongCloudIMCenterManager.h
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCUserInfo;
@class RCMessageContent;

@interface RongCloudIMCenterManager : NSObject

/**
 单例对象
 */
+ (instancetype)manager;

#pragma mark 链式调用
/** 链式调用 */

- (RongCloudIMCenterManager *)token:(NSString *)token;

- (RongCloudIMCenterManager *)refreshCache:(RCUserInfo *)userInfo userId:(NSString *)userId;

- (RongCloudIMCenterManager *)sendMessageAssociateType:(RCMessageContent *)content
                                              userInfo:(RCUserInfo *)userInfo
                                              targetId:(NSString *)targetId;

- (RongCloudIMCenterManager *)sendTextMessage:(NSString *)targetId
                                     userInfo:(RCUserInfo *)userInfo
                                      content:(NSString *)content
                                        extra:(NSString *)extra;

- (RongCloudIMCenterManager *)sendMsgToServer:(NSString *)userId
                                     userInfo:(RCUserInfo *)userInfo
                                      content:(RCMessageContent *)content
                                      houseId:(NSInteger)houseId
                                    houseName:(NSString *)houseName;


//消息配置
- (void)configWithAppKey:(NSString *)key;
- (void)disconnect:(BOOL)isReceivePush;
- (void)disconnect;
- (void)logOut;

//消息连接
- (void)connect:(void (^)(NSString *userId))successBlock;

//更新SDK中的用户信息缓存
- (void)refreshUserInfoCache;
//获取SDK中缓存的用户信息
- (RCUserInfo *)getUserInfoCache:(NSString *)userId;
//清空SDK中所有的用户信息缓存
- (void)clearUserInfoCache;

//消息发送
//- (void)sendMessageAssociateType:(void (^)(long messageId))successBlock
//                           error:(void (^)(RCErrorCode nErrorCode,
//                                           long messageId))errorBlock;
//- (void)sendTextMessage:(void (^)(long messageId))successBlock
//                  error:(void (^)(RCErrorCode nErrorCode,
//                                  long messageId))errorBlock;
- (void)sendMessageToServer:(void (^)())successBlock
                      error:(void (^)(NSError *error))errorBlock;

@end

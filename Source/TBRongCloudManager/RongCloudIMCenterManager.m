//
//  RongCloudIMCenterManager.m
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "RongCloudIMCenterManager.h"
#import "RongCloudIMDataRequest.h"
#import "RCTextMessage+Additions.h"
#import "MessageType.h"
#import "MessageTypeEstate.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
#import <RongIMKit/RCThemeDefine.h>

@interface RongCloudIMCenterManager ()

@property (nonatomic, strong) RongCloudIMDataRequest *dataRequest;

- (void)sendMessages:(void (^)(long messageId))successBlock
                  error:(void (^)(RCErrorCode nErrorCode,
                                  long messageId))errorBlock;

- (void)chat:(void (^)())successBlock
               error:(void (^)(NSError *error))errorBlock;

@end

@implementation RongCloudIMCenterManager

+ (instancetype)manager {
    static id _shared;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _shared = [[RongCloudIMCenterManager alloc] init];
    });
    return _shared;
}

+ (RongCloudIMDataRequest *)dataRequestFactory {
    return [[RongCloudIMDataRequest alloc] init];
}

- (RongCloudIMCenterManager *)token:(NSString *)token {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.token = token;
    return self;
}

- (RongCloudIMCenterManager *)refreshCache:(RCUserInfo *)userInfo userId:(NSString *)userId {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.userInfo = userInfo;
    _dataRequest.userId = userId;
    return self;
}

- (RongCloudIMCenterManager *)sendMessageAssociateType:(RCMessageContent *)content userInfo:(RCUserInfo *)userInfo targetId:(NSString *)targetId {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.content = content;
    _dataRequest.userInfo = userInfo;
    _dataRequest.content.senderUserInfo = userInfo;
    _dataRequest.targetId = targetId;
    return self;
}

- (RongCloudIMCenterManager *)sendTextMessage:(NSString *)targetId userInfo:(RCUserInfo *)userInfo content:(NSString *)content extra:(NSString *)extra {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.targetId = targetId;
    _dataRequest.userInfo = userInfo;
    _dataRequest.pushContent = content;
    _dataRequest.extra = extra;
    return self;
}

- (RongCloudIMCenterManager *)sendMsgToServer:(NSString *)userId userInfo:(RCUserInfo *)userInfo content:(RCMessageContent *)content houseId:(NSInteger)houseId houseName:(NSString *)houseName {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.userId = userId;
    _dataRequest.userInfo = userInfo;
    _dataRequest.content = content;
    _dataRequest.houseId = houseId;
    _dataRequest.houseName = houseName;
    return self;
}

- (RongCloudIMCenterManager *)chat:(NSString *)userId content:(RCMessageContent *)content houseId:(NSInteger)houseId houseName:(NSString *)houseName {
    _dataRequest = [RongCloudIMCenterManager dataRequestFactory];
    _dataRequest.userId = userId;
    _dataRequest.content = content;
    _dataRequest.houseId = houseId;
    _dataRequest.houseName = houseName;
    return self;
}

#pragma mark - Result Config

//消息配置
- (void)configWithAppKey:(NSString *)key {
    RCIM *shared = [RCIM sharedRCIM];
    [shared initWithAppKey:key];
    [shared registerMessageType:[MessageType class]];
    [shared registerMessageType:[MessageTypeEstate class]];
    [shared setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
//    RCIM.shared().globalMessageAvatarStyle = RCUserAvatarStyle.USER_AVATAR_CYCLE
//    RCIM.shared().enablePersistentUserInfoCache = true
//    RCIM.shared().enableTypingStatus = true
//    RCIM.shared().userInfoDataSource = self
//    RCIM.shared().connectionStatusDelegate = self
//    RCIM.shared().receiveMessageDelegate = self
    
}

- (void)disconnect:(BOOL)isReceivePush {
    [[RCIM sharedRCIM] disconnect:isReceivePush];
}

- (void)disconnect {
    [[RCIM sharedRCIM] disconnect];
}

- (void)logOut {
    [[RCIM sharedRCIM] logout];
}

- (void)connect:(void (^)(NSString *))successBlock {
    [[RCIM sharedRCIM] connectWithToken:self.dataRequest.token success:^(NSString *userId) {
        if (userId != nil) {
            successBlock(userId);
        } else {
            NSLog(@"userId无法获取");
        }
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为%ld",(long)status);
    } tokenIncorrect:^{
        NSLog(@"token 错误");
    }];
}

#pragma mark - Cache

- (void)refreshUserInfoCache {
    [[RCIM sharedRCIM] refreshUserInfoCache:self.dataRequest.userInfo withUserId:self.dataRequest.userId];
}

- (RCUserInfo *)getUserInfoCache:(NSString *)userId {
    return [[RCIM sharedRCIM] getUserInfoCache:userId];
}

- (void)clearUserInfoCache {
    [[RCIM sharedRCIM] clearUserInfoCache];
}

#pragma mark - Message About

- (void)sendMessageAssociateType:(void (^)(long))successBlock error:(void (^)(RCErrorCode, long))errorBlock {
    
    [self sendMessages:^(long messageId) {
        successBlock(messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(nErrorCode, messageId);
    }];
    
}

- (void)sendTextMessage:(void (^)(long))successBlock error:(void (^)(RCErrorCode, long))errorBlock {
    
    self.dataRequest.content = [[RCTextMessage alloc] initWithUserInfo:self.dataRequest.userInfo content:self.dataRequest.pushContent extra:self.dataRequest.extra];
    
    [self sendMessages:^(long messageId) {
        successBlock(messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(nErrorCode, messageId);
    }];
    
}

- (void)sendMessageToServer:(void (^)())successBlock error:(void (^)(NSError *))errorBlock {
    [self chat:^{
        successBlock();
    } error:^(NSError *error) {
        errorBlock(error);
    }];
}


#pragma mark - private methods

- (void)sendMessages:(void (^)(long))successBlock error:(void (^)(RCErrorCode, long))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.dataRequest.targetId content:self.dataRequest.content pushContent:self.dataRequest.pushContent pushData:self.dataRequest.pushData success:^(long messageId) {
        NSLog(@"send success");
        successBlock(messageId);
        
        [weakSelf sendMessageToServer:^{
            NSLog(@"chat success!");
        } error:^(NSError *error) {
            NSLog(@"chat error = %@",error);
        }];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(nErrorCode, messageId);
    }];
}

- (void)chat:(void (^)())successBlock error:(void (^)(NSError *))errorBlock {
    
}

#pragma mark - Getters & Setters


@end

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

@interface RongCloudIMCenterManager () <RCIMConnectionStatusDelegate ,RCIMReceiveMessageDelegate>

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

- (void)dataRequestFactory {
    _dataRequest = [[RongCloudIMDataRequest alloc] init];
}

- (RongCloudIMCenterManager *)token:(NSString *)token {
    [self dataRequestFactory];
    _dataRequest.token = token;
    return self;
}

- (RongCloudIMCenterManager *)refreshCache:(RCUserInfo *)userInfo userId:(NSString *)userId {
    [self dataRequestFactory];
    _dataRequest.userInfo = userInfo;
    _dataRequest.userId = userId;
    return self;
}

- (RongCloudIMCenterManager *)sendMessageAssociateType:(RCMessageContent *)content userInfo:(RCUserInfo *)userInfo targetId:(NSString *)targetId {
    [self dataRequestFactory];
    _dataRequest.content = content;
    _dataRequest.userInfo = userInfo;
    _dataRequest.content.senderUserInfo = userInfo;
    _dataRequest.targetId = targetId;
    return self;
}

- (RongCloudIMCenterManager *)sendTextMessage:(NSString *)targetId userInfo:(RCUserInfo *)userInfo content:(NSString *)content extra:(NSString *)extra {
    [self dataRequestFactory];
    _dataRequest.targetId = targetId;
    _dataRequest.userInfo = userInfo;
    _dataRequest.pushContent = content;
    _dataRequest.extra = extra;
    return self;
}

- (RongCloudIMCenterManager *)sendMsgToServer:(NSString *)userId userInfo:(RCUserInfo *)userInfo content:(RCMessageContent *)content houseId:(NSInteger)houseId houseName:(NSString *)houseName {
    [self dataRequestFactory];
    _dataRequest.userId = userId;
    _dataRequest.userInfo = userInfo;
    _dataRequest.content = content;
    _dataRequest.houseId = houseId;
    _dataRequest.houseName = houseName;
    return self;
}

- (RongCloudIMCenterManager *)chat:(NSString *)userId content:(RCMessageContent *)content houseId:(NSInteger)houseId houseName:(NSString *)houseName {
    [self dataRequestFactory];
    _dataRequest.userId = userId;
    _dataRequest.content = content;
    _dataRequest.houseId = houseId;
    _dataRequest.houseName = houseName;
    return self;
}

#pragma mark - Result Config

//消息配置
- (void)config:(NSString *)key classes:(NSArray *)messageClasses dataSource:(id <IMCUserInfoDataSource>)dataSource {
    self.dataSource = dataSource;
    [[RCIM sharedRCIM] initWithAppKey:key];
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [[RCIM sharedRCIM] setEnablePersistentUserInfoCache:YES];
    [[RCIM sharedRCIM] setEnableTypingStatus:YES];
    for (id class in messageClasses) {
        [[RCIM sharedRCIM] registerMessageType:class];
    }
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    
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

- (void)logOut {
    [[RCIM sharedRCIM] logout];
}


#pragma mark - Cache

- (void)refreshUserInfoCache {
    [[RCIM sharedRCIM] refreshUserInfoCache:self.dataRequest.userInfo withUserId:self.dataRequest.userId];
}

- (RCUserInfo *)getUserInfoCache:(NSString *)userId {
    return [[RCIM sharedRCIM] getUserInfoCache:userId];
}

- (void)getUserInfoFromDataSourceWithUserId:(NSString *)userId targetId:(NSString *)targetId completion:(void (^)(RCUserInfo *))completion {
    
    if (targetId) {
        [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:targetId];
    }
    
    [self getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
        completion(userInfo);
    }];
    
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
    
    if ([_dataRequest.content isKindOfClass:[MessageType class]]) {
        MessageType *messageType = (MessageType *)_dataRequest.content;
        _dataRequest.houseId = messageType.house_id;
        _dataRequest.houseName = messageType.house_name;
    } else if ([_dataRequest.content isKindOfClass:[MessageTypeEstate class]]) {
        MessageTypeEstate *messageTypeEstate = (MessageTypeEstate *)_dataRequest.content;
        _dataRequest.houseId = messageTypeEstate.house_id;
        _dataRequest.houseName = messageTypeEstate.house_name;
    } else if ([_dataRequest.content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)_dataRequest.content;
        _dataRequest.extra = textMessage.extra;
        
        NSArray *extraArray = [self sepExtraString:_dataRequest.extra];
        _dataRequest.houseId = [extraArray[1] integerValue];
        _dataRequest.houseName = extraArray[0];
    }
    
    [[self chat:_dataRequest.userId content:_dataRequest.content houseId:_dataRequest.houseId houseName:_dataRequest.houseName] chat:^{
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

- (NSArray *)sepExtraString:(NSString *)extra {
    
    NSArray *array = [extra componentsSeparatedByString:@"&"];
    if (array.count < 2) {
        return @[array[0], @(0)];
    } else {
        
        NSArray *subs = [[NSString stringWithFormat:@"%@",array[1]] componentsSeparatedByString:@"!"];
        if ([subs count] < 2) {
            return @[array[0], @(0)];
        } else {
            return @[array[0], @([subs[1] integerValue])];
        }
    }
}

#pragma mark - Getters & Setters

#pragma mark - RCIMUserInfoDataSource

// 获取用户信息
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    if (!userId || userId.length == 0) {
        return completion(nil);
    } else {
        if ([self.dataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
            [self.dataSource getUserInfoWithUserId:userId completion:completion];
        } else {
            return completion(nil);
        }
    }
}

#pragma mark - RCIMConnectionStatusDelegate

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (self.connectionStatusBlock != nil) {
        self.connectionStatusBlock(status);
    }
    
    if (self.offLine != nil) {
        if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            self.offLine(YES);
        } else {
            self.offLine(NO);
        }
    }
}

#pragma mark - RCIMReceiveMessageDelegate

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    
}

- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    return YES;
}

- (BOOL)onRCIMCustomLocalNotification:(RCMessage *)message withSenderName:(NSString *)senderName {
    return YES;
}

#pragma mark -
@end


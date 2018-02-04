//
//  TBRongCloudIMCenterManager.m
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "TBRongCloudIMCenterManager.h"
#import "TBMessageType.h"
#import "TBMessageTypeEstate.h"
#import "TBRongCloudIMMacro.h"
#import "TBRongCloudIMService.h"
#import "TBConversationViewController+ConversationAdditions.h"

@interface TBRongCloudIMCenterManager () <RCIMUserInfoDataSource, RCIMConnectionStatusDelegate, RCIMReceiveMessageDelegate>
@property (nonatomic, strong) TBRongCloudIMService *service;
@end

@implementation TBRongCloudIMCenterManager

+ (instancetype)manager {
    static id _shared;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _shared = [[TBRongCloudIMCenterManager alloc] init];
    });
    return _shared;
}


#pragma mark - RCIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    if (userId == nil || userId.length == 0) {
        completion(nil);
    } else {
        if (self.userInfoDataSourceResult != nil) {
            self.userInfoDataSourceResult(userId, completion);
        }
    }
}

#pragma mark - RCIMConnectionStatusDelegate

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (self.connectionStatusBlock != nil) {
        self.connectionStatusBlock(status);
    }
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT
        && self.connectionOffLineBlock != nil) {
        self.connectionOffLineBlock();
    }
}

#pragma mark - RCIMReceiveMessageDelegate

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if (left == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.receiveMessageBlock) {
                NSInteger count = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
                self.receiveMessageBlock(count, message);
            }
        });
    }
}

#pragma mark - Result Config

- (void)setDeviceToken:(NSString *)deviceToken {
    [[RCIMClient sharedRCIMClient] setDeviceToken:deviceToken];
}

//消息配置
- (void)configWithAppKey:(NSString *)key {
    RCIM *shared = [RCIM sharedRCIM];
    [shared initWithAppKey:key];
    [shared registerMessageType:[TBMessageType class]];
    [shared registerMessageType:[TBMessageTypeEstate class]];
    [shared setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [shared setEnablePersistentUserInfoCache:YES];
    [shared setEnableTypingStatus:YES];
    [shared setUserInfoDataSource:self];
    [shared setConnectionStatusDelegate:self];
    [shared setReceiveMessageDelegate:self];
}

- (void)disconnect:(BOOL)isReceivePush {
    [[RCIM sharedRCIM] disconnect:isReceivePush];
}

- (void)disconnect {
    [[RCIM sharedRCIM] disconnect];
}

- (void)logOut {
    [self clearUserInfoCache];
    [[RCIM sharedRCIM] logout];
}

- (void)connectWithRequestData:(TBRongCloudIMRequestDataModel *)requestData successBlock:(void (^)(NSString *))successBlock {
    [[RCIM sharedRCIM] connectWithToken:requestData.token success:^(NSString *userId) {
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

#pragma mark - Cache About

- (void)refreshUserInfoCache:(TBMessageUserInfo *)userInfo {
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.targetId];
}

- (RCUserInfo *)getUserInfoCache:(NSString *)userId {
    return [[RCIM sharedRCIM] getUserInfoCache:userId];
}

- (void)clearUserInfoCache {
    [[RCIM sharedRCIM] clearUserInfoCache];
}

#pragma mark - Message About

- (NSInteger)getUnReadMessageCount {
    return [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
}

- (RCConnectionStatus)getConnectionStatus {
    return [[RCIM sharedRCIM] getConnectionStatus];
}

- (void)sendContentMessage:(RCMessageContent *)contentMessage userInfo:(TBMessageUserInfo *)userInfo targetId:(NSString *)targetId successBlock:(SendMessageSuccessBlock)successBlock error:(SendMessageErrorBlock)errorBlock {
    
    TBRongCloudIMRequestDataModel *requestData = [[TBRongCloudIMRequestDataModel alloc] init];
    contentMessage.senderUserInfo = userInfo;
    
    [self sendMessageWithRequestData:requestData successBlock:successBlock error:errorBlock];
}

- (void)sendTextMessage:(RCTextMessage *)textMessage userInfo:(TBMessageUserInfo *)userInfo targetId:(NSString *)targetId successBlock:(SendMessageSuccessBlock)successBlock error:(SendMessageErrorBlock)errorBlock {
    
    TBRongCloudIMRequestDataModel *requestData = [[TBRongCloudIMRequestDataModel alloc] init];
    requestData.targetId = targetId;
    requestData.content = textMessage;
    if (userInfo) {
        requestData.userInfo = userInfo;
    }
    
    [self sendMessageWithRequestData:requestData successBlock:successBlock error:errorBlock];
    
}

- (void)chatProtocolAnalysis:(NSString *)targetId conversationModel:(RCConversationModel *)conversationModel {
    
    //清除某个会话中的未读消息数
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:conversationModel.targetId];
    
    __weak typeof(self) weakSelf = self;
    
    _service = [[TBRongCloudIMService alloc] init];
    _service.chatProtocolAnalysisResult = ^(TBExtraContentModel *model) {
        if (weakSelf.chatProtocolAnalysisResult) {
            weakSelf.chatProtocolAnalysisResult(model);
        }
    };
    [_service chatProtocolAnalysis:targetId conversationModel:conversationModel];
}

- (void)refreshRongCloudUserInfo:(TBMessageUserInfo *)userInfo {
    if ([[RCIM sharedRCIM] currentUserInfo] != nil) {
        RCUserInfo *currentUserInfo = [[RCIM sharedRCIM] currentUserInfo];
        if (userInfo.targetId != nil) {
            currentUserInfo.name = userInfo.name;
            currentUserInfo.portraitUri = userInfo.portraitUri;
        } else {
            currentUserInfo.name = @"";
            currentUserInfo.portraitUri = @"";
        }
        currentUserInfo.userId = userInfo.userId;
        [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
    } else {
        NSLog(@"当前UserInfo为空!");
    }
}

- (void)pushChat:(NSString *)userId chat:(TBConversationViewController *)chat {
    
    //清除某个会话中的未读消息数
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:userId];
    
    __weak typeof(self) weakSelf = self;
    [self getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
        if (userInfo != nil) {
            chat.title = userInfo.name;
            if (userInfo.portraitUri != nil) {
                chat.avatarUrl = userInfo.portraitUri;
            }
            [[[weakSelf currentViewController:chat] navigationController] pushViewController:chat animated:YES];
        }
    }];
}

#pragma mark - private methods

- (void)sendMessageWithRequestData:(TBRongCloudIMRequestDataModel *)dataRequest successBlock:(SendMessageSuccessBlock)successBlock error:(SendMessageErrorBlock)errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:dataRequest.targetId content:dataRequest.content pushContent:dataRequest.pushContent pushData:dataRequest.pushData success:^(long messageId) {
        NSLog(@"send success");
        successBlock(messageId);
        
        [weakSelf protocolAnalysis:dataRequest.targetId content:dataRequest.content successBlock:^{
            NSLog(@"chat success!");
        } error:^(NSError *error) {
            NSLog(@"chat error = %@",error);
        }];
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(nErrorCode, messageId);
    }];
}

//协议解析
- (void)protocolAnalysis:(NSString *)targetId content:(RCMessageContent *)content successBlock:(void (^)(void))successBlock error:(void (^)(NSError *))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    _service = [[TBRongCloudIMService alloc] init];
    _service.baseProtocolAnalysisResult = ^(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName) {
        if (weakSelf.sendMessageToServer) {
            weakSelf.sendMessageToServer(targetId, content, houseId, houseName);
        }
    };
    [_service baseProtocolAnalysis:targetId content:content];
    
}

- (UIViewController *)currentViewController:(UIViewController *)base {
    if ([base isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)base;
        return [self currentViewController:nav.visibleViewController];
    }
    if ([base isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)base;
        return [self currentViewController:tab.selectedViewController];
    }
    if (base.presentedViewController != nil) {
        return [self currentViewController:base.presentedViewController];
    }
    return base;
}


@end

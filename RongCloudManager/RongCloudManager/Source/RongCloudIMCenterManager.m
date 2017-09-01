//
//  RongCloudIMCenterManager.m
//  RongCloudIMManager
//
//  Created by Mac on 2017/8/31.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "RongCloudIMCenterManager.h"
#import "RongCloudIMDataRequest.h"

@interface RongCloudIMCenterManager ()
@property (nonatomic, strong) RongCloudIMDataRequest *dataRequest;
@end

@implementation RongCloudIMCenterManager

#ifdef RAC
static RongCloudIMFlattenMapBlock _flattenMapBlock;
#endif

+ (instancetype)manager {
    static id _shared;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _shared = [[RongCloudIMCenterManager alloc] init];
    });
    return _shared;
}

- (RongCloudIMCenterManager *(^)(NSString *, RCUserInfo *, RCMessageContent *, NSString *, NSString *))sendMessages {
    return ^RongCloudIMCenterManager *(NSString *targetId, RCUserInfo *sendUserInfo, RCMessageContent *content, NSString *pushContent, NSString *pushData) {
        self.dataRequest.targetId = targetId;
        self.dataRequest.sendUserInfo = sendUserInfo;
        self.dataRequest.content = content;
        self.dataRequest.pushContent = pushContent;
        self.dataRequest.pushData = pushData;
        return self;
    };
}

- (RongCloudIMCenterManager *(^)(NSString *, RCUserInfo *, RCMessageContent *, NSString *))sendTextMessage {
    return ^RongCloudIMCenterManager *(NSString *targetId, RCUserInfo *sendUserInfo, RCMessageContent *content, NSString *extra) {
        self.dataRequest.targetId = targetId;
        self.dataRequest.sendUserInfo = sendUserInfo;
        self.dataRequest.content = content;
        self.dataRequest.extra = extra;
        return self;
    };
}

- (RongCloudIMCenterManager *(^)(NSString *, RCUserInfo *, RCMessageContent *, NSInteger, NSString *))sendMsgToServer {
    
    return ^RongCloudIMCenterManager *(NSString *toUserId, RCUserInfo *sendUserInfo, RCMessageContent *content, NSInteger houseId, NSString *houseName) {
        self.dataRequest.toUserId = toUserId;
        self.dataRequest.sendUserInfo = sendUserInfo;
        self.dataRequest.content = content;
        self.dataRequest.houseId = houseId;
        self.dataRequest.houseName = houseName;
        return self;
    };
    
}

#pragma mark - Result Config
#ifdef RAC
+ (void)setupResponseSignalWithFlattenMapBlock:(RongCloudIMFlattenMapBlock)flattenMapBlock {
    _flattenMapBlock = flattenMapBlock;
}
#endif

#ifdef RAC
- (RACSignal *)executeSignal {
    
    RACSignal *resultSignal = [self rac_sendMessages:self.dataRequest];
    if (_flattenMapBlock) return [resultSignal flattenMap:_flattenMapBlock];
    
    return resultSignal;
}

- (RACSignal *)sendMessagesExecuteSignal {
    RACSignal *resultSignal = [self rac_sendMessages:self.dataRequest];
    if (_flattenMapBlock) return [resultSignal flattenMap:_flattenMapBlock];
    return resultSignal;
}

- (RACSignal *)sendMsgToServerExecuteSignal {
    RACSignal *resultSignal = [self rac_sendMsgToServer:self.dataRequest];
    if (_flattenMapBlock) return [resultSignal flattenMap:_flattenMapBlock];
    return resultSignal;
}

- (RACSignal *)rac_sendMessages:(RongCloudIMDataRequest *)dataRequest {
    
    @weakify(self);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.dataRequest.targetId content:self.dataRequest.content pushContent:self.dataRequest.pushContent pushData:self.dataRequest.pushData success:^(long messageId) {
            NSLog(@"send success");
            
            @strongify(self);
            [[self rac_sendMsgToServer:self.dataRequest] subscribeNext:^(id result) {
                [subscriber sendNext:result];
            } error:^(NSError *error) {
                [subscriber sendError:error];
            } completed:^{
                [subscriber sendCompleted];
            }];
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [subscriber sendError:[NSError errorWithDomain:@"" code:nErrorCode userInfo:nil]];
        }];
        return nil;
    }];
    
    return signal;
}

- (RACSignal *)rac_sendMsgToServer:(RongCloudIMDataRequest *)dataRequest {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        return nil;
    }];
    
    return signal;
}

- (RACSignal *)rac_addChat:(RongCloudIMDataRequest *)dataRequest {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        return nil;
    }];
    
    return signal;
}

#endif

#pragma mark - Getters & Setters

- (RongCloudIMDataRequest *)dataRequest {
    if (!_dataRequest) {
        _dataRequest = [[RongCloudIMDataRequest alloc] init];
    }
    return _dataRequest;
}

@end

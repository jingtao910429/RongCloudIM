//
//  TBRongCloudIMService.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/1.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBRongCloudIMProtocol.h"
#import <RongIMKit/RongIMKit.h>

@class RCMessageContent;

/*
 消息中心对外提供服务类，处理协议实现弱业务需求类
 */
@interface TBRongCloudIMService : NSObject

@property (nonatomic, copy) BaseProtocolAnalysisResult baseProtocolAnalysisResult;
@property (nonatomic, copy) ChatProtocolAnalysisResult chatProtocolAnalysisResult;

- (void)baseProtocolAnalysis:(NSString *)targetId content:(RCMessageContent *)content;

- (void)chatProtocolAnalysis:(NSString *)targetId conversationModel:(RCConversationModel *)conversationModel;

@end

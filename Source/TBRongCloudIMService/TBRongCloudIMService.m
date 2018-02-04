//
//  TBRongCloudIMService.m
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/1.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "TBRongCloudIMService.h"
#import "TBMessageType.h"
#import "TBMessageTypeEstate.h"
#import "TBExtraContentModel.h"

@implementation TBRongCloudIMService

- (void)baseProtocolAnalysis:(NSString *)targetId content:(RCMessageContent *)content {
    
    if ([content isKindOfClass:[TBMessageTypeEstate class]]) {
        //自定义TBMessageTypeEstate消息类型
        TBMessageTypeEstate *messageTypeEstate = (TBMessageTypeEstate *)content;
        if (self.baseProtocolAnalysisResult) {
            NSString *encode = [[NSString alloc] initWithData:content.encode encoding:NSUTF8StringEncoding];
            self.baseProtocolAnalysisResult(targetId, encode, messageTypeEstate.house_id, messageTypeEstate.house_name);
        }
    } else if ([content isKindOfClass:[TBMessageType class]]) {
        //自定义TBMessageType消息类型
        TBMessageType *messageType = (TBMessageType *)content;
        if (self.baseProtocolAnalysisResult) {
            NSString *encode = [[NSString alloc] initWithData:content.encode encoding:NSUTF8StringEncoding];
            self.baseProtocolAnalysisResult(targetId, encode, messageType.house_id, messageType.house_name);
        }
    } else if ([content isKindOfClass:[RCTextMessage class]]) {
        //系统RCTextMessage文本消息类型
        RCTextMessage *textMessage = (RCTextMessage *)content;
        TBExtraContentModel *model = [self analysisExtraContent:textMessage.extra];
        if (model == nil) {
            NSLog(@"解析TextMessage extra内容解析失败，请查看具体原因!");
            return;
        }
        if (self.baseProtocolAnalysisResult) {
            NSString *encode = [[NSString alloc] initWithData:content.encode encoding:NSUTF8StringEncoding];
            self.baseProtocolAnalysisResult(targetId, encode, model.houseId, model.houseName);
        }
    } else {
        NSLog(@"其他类型协议！");
    }
}

- (void)chatProtocolAnalysis:(NSString *)targetId conversationModel:(RCConversationModel *)conversationModel {
    
    TBExtraContentModel *model = [[TBExtraContentModel alloc] init];
    model.houseId = 0;
    model.houseName = @"";
    
    if ([conversationModel.lastestMessage isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)conversationModel.lastestMessage;
        model = [self chatAnalysisExtraContent:textMessage.extra];
    } else if ([conversationModel.lastestMessage isKindOfClass:[TBMessageTypeEstate class]]) {
        TBMessageTypeEstate *messageTypeEstate = (TBMessageTypeEstate *)conversationModel.lastestMessage;
        model = [self chatAnalysisExtraContent:messageTypeEstate.extra];
    } else if ([conversationModel.lastestMessage isKindOfClass:[TBMessageType class]]) {
        TBMessageType *messageType = (TBMessageType *)conversationModel.lastestMessage;
        model = [self chatAnalysisExtraContent:messageType.extra];
    } else if ([conversationModel.lastestMessage isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)conversationModel.lastestMessage;
        model = [self chatAnalysisExtraContent:imageMessage.extra];
    }
    
    if (self.chatProtocolAnalysisResult) {
        self.chatProtocolAnalysisResult(model);
    }
}

#pragma mark - private methods

- (TBExtraContentModel *)analysisExtraContent:(NSString *)source {
    TBExtraContentModel *model = [[TBExtraContentModel alloc] init];
    NSArray *separateArray = [source componentsSeparatedByString:@"&"];
    if (separateArray.count == 2) {
        NSArray *separateHouseArray = [separateArray[1] componentsSeparatedByString:@"!"];
        if (separateHouseArray.count < 2) {
            return nil;
        }
        model.houseId = [separateHouseArray[1] integerValue];
        model.houseName = separateArray[0];
        return model;
    } else if (separateArray.count == 1) {
        model.houseName = separateArray[0];
        model.houseId = 0;
        return model;
    }
    return nil;
}


- (TBExtraContentModel *)chatAnalysisExtraContent:(NSString *)source {
    
    TBExtraContentModel *model = [[TBExtraContentModel alloc] init];
    model.houseId = 0;
    model.houseName = @"";
    
    if (source != nil) {
        if ([source hasPrefix:@"from=("]) {
            
        } else if ([source hasPrefix:@"from="]) {
            return [self analysisExtraContent:[source substringFromIndex:5]];
        } else {
            return [self analysisExtraContent:source];
        }
    }
    return model;
}





@end

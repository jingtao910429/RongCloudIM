//
//  TBRongCloudIMProtocol.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/1.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBRongCloudIMMacro.h"

@class RongCloudIMCenterManager;
@class TBMessageUserInfo;
@class TBExtraContentModel;

//发送消息成功失败回调
typedef void (^SendMessageSuccessBlock)(long messageId);
typedef void (^SendMessageErrorBlock)(RCErrorCode errorCode, long messageId);

//消息管理相关回调
typedef void (^UserInfoDataSourceResult)(RongCloudIMCenterManager *, TBMessageUserInfo *);
typedef void (^ConnectionStatusBlock)(RCConnectionStatus status);
typedef void (^ConnectionOffLineBlock)(void);
typedef void (^ReceiveMessageBlock)(NSInteger totalUnreadCount);
typedef void (^SendMessageToServer)(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName);

//协议解析回调
//ProtocolAnalysis
typedef void (^BaseProtocolAnalysisResult)(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName);
typedef void (^ChatProtocolAnalysisResult)(TBExtraContentModel *model);


@interface TBRongCloudIMProtocol : NSObject

@end

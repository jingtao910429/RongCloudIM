//
//  TBRongCloudIMProtocol.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/1.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TBRongCloudIMMacro.h"

@class TBRongCloudIMCenterManager;
@class TBMessageUserInfo;
@class TBExtraContentModel;
@class RCMessageCell;
@class RCConversationBaseCell;
@class RCConversationModel;
@class RCUserInfo;

typedef NS_ENUM(NSInteger, TBChatMessageCellType) {
    MessageType = 0,
    MessageTypeEstate = 1
};

typedef NS_ENUM(NSInteger, TBListMessageCellType) {
    ConversationBase = 0
};

//发送消息成功失败回调
typedef void (^SendMessageSuccessBlock)(long messageId);
typedef void (^SendMessageErrorBlock)(RCErrorCode errorCode, long messageId);

//消息管理相关回调
//#pragma mark - RCIMUserInfoDataSource 相关回调
typedef void (^UserInfoDataSourceResultCompletion)(RCUserInfo *);
typedef void (^UserInfoDataSourceResult)(TBRongCloudIMCenterManager *, UserInfoDataSourceResultCompletion);
//#pragma mark - RCIMConnectionStatusDelegate 相关回调
typedef void (^ConnectionStatusBlock)(RCConnectionStatus status);
typedef void (^ConnectionOffLineBlock)(void);
//#pragma mark - RCIMReceiveMessageDelegate 相关回调
typedef void (^ReceiveMessageBlock)(NSInteger totalUnreadCount);
typedef void (^SendMessageToServer)(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName);

//协议解析回调
//ProtocolAnalysis
typedef void (^BaseProtocolAnalysisResult)(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName);
typedef void (^ChatProtocolAnalysisResult)(TBExtraContentModel *model);

//UI相关协议, 获取数据及交互使用
@protocol TBConversationViewControllerDelagate <NSObject>

@optional

@required
//willSendMessage获取所需数据
- (TBMessageUserInfo *)willSendMessageFetchUserInfo;

//消息页面发送接收展示
- (UIImage *)willDisplayMessageCellTextSend;
- (UIImage *)willDisplayMessageCellTextRecived;

//Cell定制
- (RCMessageCell *)chatCustomerMessageCell:(TBChatMessageCellType)type;
- (RCConversationBaseCell *)listCustomerMessageCell:(TBListMessageCellType)type model:(RCConversationModel *)model;

- (NSMutableArray *)listWillReloadTableData:(NSMutableArray *)dataSource targetIdArray:(NSArray *)targetIdArray;
@end

@interface TBRongCloudIMProtocol : NSObject

@end

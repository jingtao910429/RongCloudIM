//
//  TBConversationListViewController.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/2.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "TBRongCloudIMProtocol.h"

@interface TBConversationListViewController : RCConversationListViewController

//是否需要侧滑删除操作
@property (nonatomic, assign) BOOL isNeedSlideDelete;
//是否需要更新操作willReloadTableData
@property (nonatomic, assign) BOOL isNeedDataUpdate;

@property (nonatomic, copy) UserInfoDataSourceResultCompletion userInfoDataSourceResultCompletion;
@property (nonatomic, copy) BaseProtocolAnalysisResult baseProtocolAnalysisResult;

//供子类调用完善界面，可覆盖或者直接调用
- (void)baseConfigiration:(CGRect)frame;

@end

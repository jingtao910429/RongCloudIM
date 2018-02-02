//
//  TBConversationListViewController.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/2.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface TBConversationListViewController : RCConversationListViewController

//供子类调用完善界面，可覆盖或者直接调用
- (void)baseConfigiration:(CGRect)frame;

@end

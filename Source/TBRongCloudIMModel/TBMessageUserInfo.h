//
//  TBMessageUserInfo.h
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/1.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface TBMessageUserInfo : RCUserInfo

@property (nonatomic, copy) NSString *targetId;

@property (nonatomic, copy) NSString *houseName;
@property (nonatomic, assign) NSInteger houseId;

@end

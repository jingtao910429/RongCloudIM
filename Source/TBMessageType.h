//
//  MessageType.h
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "TBMessageCommonContent.h"

@interface TBMessageType : TBMessageCommonContent

@property (nonatomic, copy)   NSString *house_name;
@property (nonatomic, assign) NSInteger house_id;
@property (nonatomic, assign) NSInteger city_id;
@property (nonatomic, assign) NSInteger sprice;
@property (nonatomic, assign) NSInteger sale_count;
@property (nonatomic, copy)   NSString *isfirst;
@property (nonatomic, copy)   NSString *extra;

- (NSData *)encode;
- (void)decodeWithData:(NSData *)data;
- (NSString *)conversationDigest;
+ (NSString *)getObjectName;
@end

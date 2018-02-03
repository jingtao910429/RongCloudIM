//
//  MessageTypeEstate.h
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "TBMessageCommonContent.h"

@interface TBMessageTypeEstate : TBMessageCommonContent

@property (nonatomic, assign) NSInteger estate_id;
@property (nonatomic, assign) NSInteger rooms;
@property (nonatomic, assign) NSInteger living_rooms;
@property (nonatomic, assign) NSInteger area;
@property (nonatomic, assign) NSInteger unit_price;
@property (nonatomic, assign) NSInteger total_price;
@property (nonatomic, assign) NSInteger city_id;
@property (nonatomic, assign) NSInteger house_id;
@property (nonatomic, assign) NSInteger pubType;
@property (nonatomic, assign) NSInteger houseType;
@property (nonatomic, copy)   NSString *house_name;
@property (nonatomic, copy)   NSString *is_first;
@property (nonatomic, copy)   NSString *extra;
@property (nonatomic, copy)   NSString *estateDetailUrl;
@property (nonatomic, copy)   NSDictionary *user;


- (NSData *)encode;
- (void)decodeWithData:(NSData *)data;
- (NSString *)conversationDigest;
+ (NSString *)getObjectName;
@end

//
//  RongTest.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2018/1/31.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "RongTest.h"
#import <RongIMKit/RongIMKit.h>

@implementation RongTest
- (instancetype)init{
    if (self = [super init]) {
        [RCIM sharedRCIM];
    }
    return self;
}
@end

//
//  RCUserInfo+Additions.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "RCUserInfo+Additions.h"

@implementation RCUserInfo (Additions)

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portraitUri:(NSString *)portraitUri {
    if (self = [super init]) {
        self.userId        =   userId;
        self.name          =   username;
        self.portraitUri   =   portraitUri;
    }
    return self;
}

@end

//
//  RCTextMessage+Additions.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "RCTextMessage+Additions.h"

@implementation RCTextMessage (Additions)
- (instancetype)initWithUserInfo:(RCUserInfo *)userInfo content:(NSString *)content extra:(NSString *)extra {
    if (self = [super init]) {
        self.senderUserInfo =   userInfo;
        self.content        =   content;
        self.extra          =   extra;
    }
    return self;
}
@end

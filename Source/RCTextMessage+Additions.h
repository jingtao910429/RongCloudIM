//
//  RCTextMessage+Additions.h
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface RCTextMessage (Additions)
- (instancetype)initWithUserInfo:(RCUserInfo *)userInfo content:(NSString *)content extra:(NSString *)extra;
@end

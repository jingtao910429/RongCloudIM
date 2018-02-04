//
//  TBConversationViewController+ConversationAdditions.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2018/2/4.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "TBConversationViewController+ConversationAdditions.h"
#import <objc/runtime.h>

static void *TBConversationViewAvatarUrl;

@implementation TBConversationViewController (ConversationAdditions)

- (NSString *)avatarUrl {
    return objc_getAssociatedObject(self, &TBConversationViewAvatarUrl);
}

- (void)setAvatarUrl:(NSString *)avatarUrl {
    objc_setAssociatedObject(self, &TBConversationViewAvatarUrl, avatarUrl, OBJC_ASSOCIATION_COPY);
}

@end

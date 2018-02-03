//
//  NSString+TBAdditions.m
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/3.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "NSString+TBAdditions.h"
#import <UIKit/UIKit.h>

@implementation NSString (TBAdditions)
- (NSMutableAttributedString *)attibuteStringSubIndex:(NSInteger)subIndex {
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 375.0;
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:self];
    UIFont *font = [UIFont systemFontOfSize:21 * width];
    UIFont *smallFont = [UIFont systemFontOfSize:14 * width];
    [attribute addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attribute.length - subIndex)];
    [attribute addAttribute:NSFontAttributeName value:smallFont range:NSMakeRange(attribute.length - subIndex, subIndex)];
    return attribute;
}
@end

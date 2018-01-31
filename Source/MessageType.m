//
//  MessageType.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "MessageType.h"

@implementation MessageType

- (NSData *)encode {
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithCapacity:20];
    
    [dataDict setValue:self.house_name forKey:@"house_name"];
    [dataDict setValue:@(self.house_id) forKey:@"house_id"];
    [dataDict setValue:@(self.city_id) forKey:@"city_id"];
    [dataDict setValue:@(self.sprice) forKey:@"sprice"];
    [dataDict setValue:@(self.sale_count) forKey:@"sale_count"];
    [dataDict setValue:self.isfirst forKey:@"isfirst"];
    [dataDict setValue:self.extra forKey:@"extra"];
    
    return [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)decodeWithData:(NSData *)data {
    
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    self.house_name = dataDict[@"house_name"];
    self.house_id   = [dataDict[@"house_id"] integerValue];
    self.city_id    = [dataDict[@"city_id"] integerValue];
    self.sprice     = [dataDict[@"sprice"] integerValue];
    self.sale_count = [dataDict[@"sale_count"] integerValue];
    self.isfirst    = dataDict[@"isfirst"];
    self.extra      = dataDict[@"extra"];
    
}

- (NSString *)conversationDigest {
    return self.house_name;
}

@end

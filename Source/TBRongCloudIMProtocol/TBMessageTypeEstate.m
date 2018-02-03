//
//  MessageTypeEstate.m
//  RongCloudIMManagerExample
//
//  Created by Mac on 2017/9/4.
//  Copyright © 2017年 LiYou. All rights reserved.
//

#import "TBMessageTypeEstate.h"

@implementation TBMessageTypeEstate

- (NSData *)encode {
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithCapacity:20];
    
    [dataDict setValue:self.house_name forKey:@"house_name"];
    [dataDict setValue:@(self.estate_id) forKey:@"estate_id"];
    [dataDict setValue:@(self.living_rooms) forKey:@"living_rooms"];
    [dataDict setValue:@(self.rooms) forKey:@"rooms"];
    [dataDict setValue:@(self.area) forKey:@"area"];
    [dataDict setValue:@(self.unit_price) forKey:@"unit_price"];
    [dataDict setValue:@(self.total_price) forKey:@"total_price"];
    [dataDict setValue:@(self.city_id) forKey:@"city_id"];
    [dataDict setValue:@(self.house_id) forKey:@"house_id"];
    [dataDict setValue:@(self.pubType) forKey:@"pubType"];
    [dataDict setValue:@(self.houseType) forKey:@"houseType"];
    [dataDict setValue:self.is_first forKey:@"is_first"];
    [dataDict setValue:self.is_first forKey:@"is_first"];
    [dataDict setValue:self.extra forKey:@"extra"];
    [dataDict setValue:self.estateDetailUrl forKey:@"estateDetailUrl"];
    [dataDict setValue:self.user forKey:@"user"];
    
    
    return [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)decodeWithData:(NSData *)data {
    
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    self.house_name      = dataDict[@"house_name"];
    self.estate_id       = [dataDict[@"estate_id"] integerValue];
    self.living_rooms    = [dataDict[@"living_rooms"] integerValue];
    self.house_id        = [dataDict[@"house_id"] integerValue];
    self.city_id         = [dataDict[@"city_id"] integerValue];
    self.rooms           = [dataDict[@"rooms"] integerValue];
    self.area            = [dataDict[@"area"] integerValue];
    self.total_price     = [dataDict[@"total_price"] integerValue];
    self.unit_price      = [dataDict[@"unit_price"] integerValue];
    self.is_first        = dataDict[@"is_first"];
    self.extra           = dataDict[@"extra"];
    self.estateDetailUrl    = dataDict[@"estateDetailUrl"];
    self.user            = [NSDictionary dictionaryWithDictionary:dataDict[@"user"]];
    
}

- (NSString *)conversationDigest {
    return self.house_name;
}

+ (NSString *)getObjectName {
    return @"2boss:estate";
}

@end

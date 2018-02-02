//
//  TBConversationListViewController.m
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/2.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "TBConversationListViewController.h"

@interface TBConversationListViewController ()

@end

@implementation TBConversationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.conversationListTableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.showConnectingStatusOnNavigatorBar = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

- (void)baseConfigiration:(CGRect)frame {
    self.conversationListTableView.frame = frame;
}

@end

//
//  TBConversationListViewController.m
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/2.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "TBConversationListViewController.h"
#import "TBRongCloudIMMacro.h"
#import "TBRongCloudIMCenterManager.h"
#import "TBRongCloudIMService.h"

@interface TBConversationListViewController ()

@end

@implementation TBConversationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNeedSlideDelete = YES;
    self.isNeedDataUpdate = YES;
    
    self.conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.conversationListTableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.showConnectingStatusOnNavigatorBar = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationListDataSource.count;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isNeedSlideDelete) {
        __weak typeof(self) weakSelf = self;
        UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            RCConversationModel *model = self.conversationListDataSource[indexPath.row];
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:model.targetId];
            [weakSelf refreshConversationTableViewIfNeeded];
        }];
        return @[rowAction];
    }
    return nil;
}

- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {

    NSMutableArray *targetIdArray = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:20];
    for (int i = 0; i < dataSource.count; i ++) {
        RCConversationModel *conversationModel = dataSource[i];
        if (conversationModel.targetId != nil) {
            [targetIdArray addObject:conversationModel.targetId];
        }
        if (conversationModel.conversationType == ConversationType_PRIVATE) {
            conversationModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        }
        [models addObject:conversationModel];
    }

    if (self.isNeedDataUpdate) {
        return [NSMutableArray arrayWithArray:models];
    } else {
        if ([self respondsToSelector:@selector(listWillReloadTableData:targetIdArray:)]) {
            [self performSelector:@selector(listWillReloadTableData:targetIdArray:) withObject:dataSource withObject:targetIdArray];
        }
    }
    return dataSource;
}

- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    RCConversationModel *conversationModel = self.conversationListDataSource[indexPath.row];
    if ([self respondsToSelector:@selector(listCustomerMessageCell:model:)]) {
        RCConversationBaseCell *baseCell = [self performSelector:@selector(listCustomerMessageCell:model:) withObject:@(ConversationBase) withObject:conversationModel];
        if (self.userInfoDataSourceResultCompletion != nil) {
            [[TBRongCloudIMCenterManager manager] getUserInfoWithUserId:conversationModel.targetId completion:self.userInfoDataSourceResultCompletion];
        }
        return baseCell;
    }
    NSLog(@"子类协议未实现！");
    return nil;
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    
    RCConversationModel *conversationModel = self.conversationListDataSource[indexPath.row];
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:conversationModel.targetId];
    
    __weak typeof(self) weakSelf = self;
    
    TBRongCloudIMService *service = [[TBRongCloudIMService alloc] init];
    service.baseProtocolAnalysisResult = ^(NSString *targetId, NSString *content, NSInteger houseId, NSString *houseName) {
        if (weakSelf.baseProtocolAnalysisResult) {
            weakSelf.baseProtocolAnalysisResult(targetId, content, houseId, houseName);
        }
        if (weakSelf.userInfoDataSourceResultCompletion != nil) {
            [[TBRongCloudIMCenterManager manager] getUserInfoWithUserId:conversationModel.targetId completion:weakSelf.userInfoDataSourceResultCompletion];
        }
    };
    [service baseProtocolAnalysis:conversationModel.targetId content:conversationModel.lastestMessage];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSLog(@"super %@", NSStringFromSelector(_cmd));
}


#pragma mark - private methods

- (void)baseConfigiration:(CGRect)frame {
    self.conversationListTableView.frame = frame;
}

- (void)configUserInfo:(RCUserInfo *)userInfo {
    if (userInfo.userId != nil || ![userInfo.userId isEqualToString:@""]) {
        RCUserInfo *currentUserInfo = [[RCIM sharedRCIM] currentUserInfo];
        currentUserInfo.userId = userInfo.userId;
        currentUserInfo.name = userInfo.name;
        currentUserInfo.portraitUri = userInfo.portraitUri;
        [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
    }
}

@end

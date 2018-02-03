//
//  TBConversationViewController.m
//  RongCloudIMFrameWork
//
//  Created by Mac on 2018/2/3.
//  Copyright © 2018年 LiYou. All rights reserved.
//

#import "TBConversationViewController.h"
#import "TBTextMessage.h"
#import "TBMessageType.h"
#import "TBMessageTypeEstate.h"
#import "TBImageMessage.h"
#import "TBMessageUserInfo.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kIPhoneX (kScreenWidth == 375 && kScreenHeight == 812)
#define KHeight (kIPhoneX ? 1 : kScreenHeight / 667.0)

@interface TBConversationViewController () <RCMessageCellDelegate>

@end

@implementation TBConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.enableUnreadMessageIcon = YES;
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    //注册系统类型CELL
    [self registerClass:[RCTextMessageCell class] forMessageClass:[RCTextMessage class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)baseConfigiration:(CGRect)frame {
    self.conversationMessageCollectionView.frame = frame;
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    NSLog(@"_cmd: %@",NSStringFromSelector(_cmd));
    TBMessageUserInfo * userInfo = nil;
    if ([self respondsToSelector:@selector(willSendMessageFetchUserInfo)]) {
        userInfo = [self performSelector:@selector(willSendMessageFetchUserInfo) withObject:nil];
    }
    if (userInfo) {
        
        RCUserInfo *originalUserInfo = [[RCUserInfo alloc] initWithUserId:userInfo.userId name:userInfo.name portrait:userInfo.portraitUri];
        NSString *extra = [NSString stringWithFormat:@"from=%@&fromHouseId!%@", userInfo.houseName, @(userInfo.houseId)];
        if ([messageContent isMemberOfClass:[TBTextMessage class]]) {
            
            TBTextMessage *textMessage = (TBTextMessage *)messageContent;
            textMessage.extra = extra;
            textMessage.senderUserInfo = originalUserInfo;
            return textMessage;
            
        } else if ([messageContent isMemberOfClass:[TBMessageType class]]) {
            
            TBMessageType *messageType = (TBMessageType *)messageContent;
            messageType.extra = extra;
            messageType.senderUserInfo = originalUserInfo;
            return messageType;
            
        } else if ([messageContent isMemberOfClass:[TBMessageTypeEstate class]]) {
            
            TBMessageTypeEstate * messageTypeEstate = (TBMessageTypeEstate *)messageContent;
            messageTypeEstate.extra = extra;
            messageTypeEstate.senderUserInfo = originalUserInfo;
            return messageTypeEstate;
            
        }
    }
    NSLog(@"默认融云willSendMessage方法!");
    return [super willSendMessage:messageContent];
}

- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    NSLog(@"_cmd: %@",NSStringFromSelector(_cmd));
    if ([messageContent isKindOfClass:[TBImageMessage class]]) {
        TBMessageUserInfo * userInfo = nil;
        if ([self respondsToSelector:@selector(willSendMessageFetchUserInfo)]) {
            userInfo = [self performSelector:@selector(willSendMessageFetchUserInfo) withObject:nil];
        }
        if (userInfo) {
            //发送图片
            
            RCUserInfo *originalUserInfo = [[RCUserInfo alloc] initWithUserId:userInfo.userId name:userInfo.name portrait:userInfo.portraitUri];
            NSString *extra = [NSString stringWithFormat:@"from=%@&fromHouseId!%@", userInfo.houseName, @(userInfo.houseId)];
            
            TBImageMessage *imageMessage = (TBImageMessage *)messageContent;
            RCImageMessage *content = [RCImageMessage messageWithImage:imageMessage.originalImage];
            content.extra = extra;
            content.senderUserInfo = originalUserInfo;
            
            [[RCIM sharedRCIM] sendMediaMessage:ConversationType_PRIVATE targetId:userInfo.targetId content:content pushContent:nil pushData:nil progress:^(int progress, long messageId) {
                NSLog(@"progress: %@, messageId: %@",@(progress), @(messageId));
            } success:^(long messageId) {
                NSLog(@"messageId: %@", @(messageId));
            } error:^(RCErrorCode errorCode, long messageId) {
                NSLog(@"errorCode: %@, messageId: %@",@(errorCode), @(messageId));
            } cancel:^(long messageId) {
                NSLog(@"messageId: %@",@(messageId));
            }];
        }
        
    }
}

- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    
    if (self.displayUserNameInCell) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            model.isDisplayNickname = NO;
        }
    }
    
    RCMessageContent *content = (RCMessageContent *)model.content;
    model.isDisplayNickname = NO;
    model.isDisplayMessageTime = YES;
    
    if ([content isMemberOfClass:[TBMessageType class]]) {
        if ([self respondsToSelector:@selector(chatCustomerMessageCell:)]) {
            RCMessageCell *messageCell = [self performSelector:@selector(chatCustomerMessageCell:) withObject:@(MessageType)];
            [self actionWithMessageCell:messageCell model:model];
            return messageCell;
        }
    } else if ([content isMemberOfClass:[TBMessageTypeEstate class]]) {
        if ([self respondsToSelector:@selector(chatCustomerMessageCell:)]) {
            RCMessageCell *messageCell = [self performSelector:@selector(chatCustomerMessageCell:) withObject:@(MessageTypeEstate)];
            [self actionWithMessageCell:messageCell model:model];
            return messageCell;
        }
    }
    return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[RCTextMessageCell class]]) {
        RCTextMessageCell *textMessageCell = (RCTextMessageCell *)cell;
        if (textMessageCell.messageDirection == MessageDirection_SEND) {
            if ([self respondsToSelector:@selector(willDisplayMessageCellTextSend)]) {
                UIImage *send = [self performSelector:@selector(willDisplayMessageCellTextSend) withObject:nil];
                textMessageCell.bubbleBackgroundView.image = send;
            }
        } else if (textMessageCell.messageDirection == MessageDirection_RECEIVE) {
            if ([self respondsToSelector:@selector(willDisplayMessageCellTextRecived)]) {
                UIImage *recived = [self performSelector:@selector(willDisplayMessageCellTextRecived) withObject:nil];
                textMessageCell.bubbleBackgroundView.image = recived;
            }
        }
    } else {
        [super willDisplayMessageCell:cell atIndexPath:indexPath];
    }
}


- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *content = model.content;
    if ([content isMemberOfClass:[RCRealTimeLocationStartMessage class]]) {
        return CGSizeMake(collectionView.frame.size.width, 66 * KHeight);
    } else if ([content isMemberOfClass:[TBMessageType class]]
               || [content isMemberOfClass:[TBMessageTypeEstate class]]) {
        return CGSizeMake(collectionView.frame.size.width, 200 * KHeight);
    } else {
        return [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
}

#pragma mark - private methods

- (void)actionWithMessageCell:(RCMessageCell *)messageCell model:(RCMessageModel *)model {
    [messageCell setDataModel:model];
    messageCell.delegate = self;
    messageCell.backgroundColor = [UIColor clearColor];
}

@end






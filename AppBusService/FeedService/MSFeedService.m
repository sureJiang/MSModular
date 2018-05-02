//
//  MSFeedService.m
//  DEMO
//
//  Created by JZJ on 16/8/12.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import "MSFeedService.h"
#import "MSAppBusHeader.h"

#if !__has_feature(objc_arc)
#error MSFeedService must be built with ARC.
#endif

static NSString *kFriendsFeedViewController             = @"FriendFeedViewController";
static NSString *kFriendsFeedViewGotoAction             = @"pushToFriendFeedViewControllerWithParam:";
static NSString *kUserFeedViewController                = @"MSUserFeedListViewController";
static NSString *kUserFeedViewGotoAction                = @"pushToUserFeedListViewControllerWithParam:";
static NSString *kGroupFeedViewController               = @"GroupFeedViewController";
static NSString *kGroupFeedViewGotoAction               = @"pushToGroupFeedViewControllerWithParam:";
static NSString *kSiteFeedViewController                = @"MSFeedSiteListViewController";
static NSString *kSiteFeedViewGotoAction                = @"pushToFeedSiteListViewControllerWithParam:";
static NSString *kTopicFeedViewGotoAction               = @"pushToTopicListViewControllerWithParam:";
static NSString *kShopFeedContainerViewController       = @"MSStoreFeedContainerController";
static NSString *kShopFeedContainerViewGotoAction       = @"pushToStoreFeedContainerControllerWithParams:";
static NSString *kShopFeedViewController                = @"MSLBAShopFeedViewController";
static NSString *kShopFeedViewGotoAction                = @"pushToShopFeedViewControllerWithParams:";

static NSString *kFeedDetailViewController              = @"FeedDetailsViewController";
static NSString *kFeedDetailViewGotoAction              = @"pushToFeedDetailsViewControllerWithParams:";

static NSString *kShopFeedDetailsViewController         = @"MSLBAShopFeedDetailsViewController";
static NSString *kShopFeedDetailsViewGotoAction         = @"pushToLBAShopFeedDetailsViewControllerWithParams:";

static NSString *kReleaseFeedController                 = @"MSReleaseFeedController";
static NSString *kReleaseFeedGotoAction                 = @"ReleaseFeedActivityWithQuickEntranceParams:";

static NSString *kMSWhoCanSeeViewController             = @"MSWhoCanSeeViewController";
static NSString *kMSWhoCanSeeViewGotoAction             = @"pushToWhoCanSeeViewControllerWithParam:";

static NSString *kMSFeedManagerUtility                  = @"FeedManagerUtility";
static NSString *kMSFeedManagerGetFeedAction            = @"doFeedManagerGetFeedActionWithParams:";
static NSString *kMSFeedManagerModelingFeedAction       = @"doFeedManagerModelingFeedActionWithParams:";
static NSString *kMSFeedManagerResetFeedAction          = @"doFeedManagerResetFeed:";
static NSString *kMSFeedManagerUpdateFeedQueryFilter    = @"doUpdateFeedQueryFilterWithMomoID:";
static NSString *kMSFeedManagerClearAllFromDBAction     = @"doClearInfoFromDB:";
static NSString *kMSFeedManagerGetReleaseDraft          = @"doGetReleaseDraft:";


@interface MSFeedService ()<MSFeedServiceProtocol>
@property (nonatomic ,strong) NSMutableDictionary *cacheTargetDic;
@end


@implementation MSFeedService
MSRegistService(MSFeedServiceProtocol)//注册服务

- (void)serviceDidInit
{
}

#pragma mark - service相关接口
//动态相关页面的goto
- (void)gotoFeedViewControllerWithType:(MSFeedControllerType)type andParams:(NSDictionary *)params {
    
    NSArray *actionArray = [self actionStringFromFeedEntrance:type];
    if(actionArray.count == 2){
        
        [self performTarget:[actionArray objectAtIndex:0 ]
                     action:[actionArray objectAtIndex:1 ]
                     params:params];
    }
}

//地点选择
- (void)getSiteFromFeedSitelistWithParams:(NSDictionary *)params byCallBackBlock:(SelectedFeedSiteBlock)callBackBlock
{
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if(callBackBlock){
        [currentParams setObject:callBackBlock forKey:@"callBackBlock"];
    }
    [self performTarget:kSiteFeedViewController action:kSiteFeedViewGotoAction params:currentParams];
}

//谁可以看
- (void)getItemsFromWhoCanSeeMeWithParams:(NSDictionary *)params byCallBackBlock:(SelectedWhoCanSeeMeBlock)callBackBlock
{
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if(callBackBlock){
        [currentParams setObject:callBackBlock forKey:@"callBackBlock"];
    }
    [self performTarget:kMSWhoCanSeeViewController action:kMSWhoCanSeeViewGotoAction params:currentParams];
}

//发布动态
- (void)releaseFeedActivityQuickEntranceWithParams:(NSDictionary *)params {
    
    [self performTarget:kReleaseFeedController action:kReleaseFeedGotoAction params:params];
}

//根据id获取对应的feed
- (void)getFeedWithType:(MSFeedManagerType)feedType feedId:(NSString *)feedId syncCallBackBlock:(SyncCallBackFeedBlock)block {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:@(feedType) forKey:@"feedType"];
    [params setObject:feedId forKey:@"feedId"];
    if(block) {
        [params setObject:block forKey:@"callBackBlock"];
    }
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerGetFeedAction params:params];
}

//解析单条feedJson，存储并回调该feed
- (void)modelingSingleFeed:(NSDictionary *)aFeedDic syncCallBackBlock:(SyncCallBackFeedBlock)block {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:aFeedDic];
    
    if(block) {
        [params setObject:block forKey:@"callBackBlock"];
    }
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerModelingFeedAction params:params];
}

//setFeed
- (void)resetFeed:(id)aFeed {
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerResetFeedAction params:nil];
}

//用户退出重新登录时用来刷新fastQueryFielter
- (void)updateFeedFastQueryFilterWithMomoID:(NSString *)momoid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:momoid forKey:@"momoid"];
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerUpdateFeedQueryFilter params:params];
}

//清除db
- (void)clearAllInfoFromDbWithType:(MSFeedManagerType)type {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:@(type) forKey:@"providerType"];
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerClearAllFromDBAction params:params];
}

- (void)getFeedReleaseDraftWithTargetId:(NSString *)targetId publishType:(MSPublishType)type syncCallBackBlock:(GetFeedReleaseDraftBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:targetId forKey:@"targetId"];
    [params setObject:@(type) forKey:@"publishType"];
    if(block) {
        [params setObject:block forKey:@"callBackBlock"];
    }
    [self performTarget:kMSFeedManagerUtility action:kMSFeedManagerGetReleaseDraft params:params];
}

#pragma mark - service事件分发
- (void)performTarget:(NSString *)targetStr
               action:(NSString *)actionStr
               params:(NSDictionary *)paramDic
{
    
    NSDictionary *tempParaDic = paramDic;
    
    id target = [self increaseTargetLife:actionStr targetStr:targetStr];
    
    SEL action = NSSelectorFromString(actionStr);
    if(target == nil)
    {
        return ;
    }
    if([target respondsToSelector:action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (![[NSThread currentThread] isMainThread]) {
            [target performSelectorOnMainThread:action withObject:tempParaDic waitUntilDone:YES];
        } else {
        [target performSelector:action withObject:tempParaDic];
        }
        
#pragma clang diagnostic pop
    }else
    {
        SEL action = NSSelectorFromString(@"notFound:");
        if([target respondsToSelector:action])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:action withObject:tempParaDic];
#pragma clang diagnostic pop
        }else
        {
            return ;
        }
    }
    return ;
}


- (NSArray *)actionStringFromFeedEntrance:(MSFeedControllerType)feedEntrance {
    
    NSArray *actionArray = nil;
    
    NSString *actionString = @"";
    NSString *target = @"";
    
    switch (feedEntrance) {

        case MSFeedControllerTypeFriends:
        {
            target = kFriendsFeedViewController;
            actionString = kFriendsFeedViewGotoAction;
            break;
        }
        case MSFeedControllerTypeUser:
        {
            target = kUserFeedViewController;
            actionString = kUserFeedViewGotoAction;
            break;
        }
        case MSFeedControllerTypeGroup:
        {
            target = kGroupFeedViewController;
            actionString = kGroupFeedViewGotoAction;
            break;
        }

        case MSFeedControllerTypeShopContainer:
        {
            target = kShopFeedContainerViewController;
            actionString = kShopFeedContainerViewGotoAction;
            break;
        }
        case MSFeedControllerTypeShop:
        {
            target = kShopFeedViewController;
            actionString = kShopFeedViewGotoAction;
            break;
        }

        case MSFeedControllerTypeDetailNormal:
        {
            target = kFeedDetailViewController;
            actionString = kFeedDetailViewGotoAction;
            break;
        }

        case MSFeedControllerTypeDetailShop:
        {
            target = kShopFeedDetailsViewController;
            actionString = kShopFeedDetailsViewGotoAction;
            break;
        }
        default:
            break;
    }
        actionArray = @[target ,actionString];
    
    return actionArray;
}

/**
 *  需要延长生命周期（FeedManagerUtility生命周期需要跟随MSUser）
 */

- (id)increaseTargetLife:(NSString *)actionStr targetStr:(NSString *)aTargetStr
{
    id tempTarget = nil;
    Class TargetClass = NSClassFromString(aTargetStr);
    
    if([aTargetStr isEqualToString:kMSFeedManagerUtility]) {
        //  tempTarget = [self.cacheTargetDic objectForKey:aTargetStr defaultValue:nil];
        if(!tempTarget)
        {
//            tempTarget = [FeedManagerUtility feedUtility];

            //  [self.cacheTargetDic setObject:tempTarget forKey:actionStr];
            tempTarget = [NSObject new];

        }
    }else {
        tempTarget = [[TargetClass alloc] init];
    }
    
    return tempTarget;
}

#pragma mark -
- (NSMutableDictionary *)cacheTargetDic
{
    if(!_cacheTargetDic)
    {
        _cacheTargetDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cacheTargetDic;
}

- (void)dealloc {
   // NSLog(@"MSFeedService-dealloc");
}

@end

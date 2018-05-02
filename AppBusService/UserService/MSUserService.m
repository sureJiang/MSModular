//
//  UserService.m
//  DEMO
//
//  Created by JZJ on 16/9/20.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import "MSUserService.h"
#import "MSAppBusHeader.h"
//#import "MSUserUtility.h"
#if !__has_feature(objc_arc)
#error UserService must be built with ARC.
#endif

@interface MSUserService ()<MSUserServiceProtocol>

@end

@implementation MSUserService
MSRegistService(MSUserServiceProtocol)//注册服务

static NSString *kProfileUserViewController              = @"MSProfileUserViewController";
static NSString *kProfileUserViewGotoAction              = @"pushToProfileUserViewControllerWithParam:";
static NSString *kProfileUserEditViewController          = @"MSProfileUserEditViewController";
static NSString *kProfileUserEditViewGotoAction          = @"pushToProfileUserEditViewControllerWithParam:";
static NSString *kCommonUserListViewController           = @"MSCommonUserListViewController";
static NSString *kCommonUserListViewGotoAction           = @"pushToCommonUserListViewControllerWithParam:";

static NSString *kUserUtility                            = @"MSUserUtility";
static NSString *kUserUtilityGetUserProfile              = @"doUserUtilityGetUserProfile:";
static NSString *kUserUtilitySetUserProfile              = @"doUserUtilitySetUserProfile:";
static NSString *kUserUtilityAction                      = @"doUserUtilityActionWithParams:";
static NSString *kUserUtilityHelper                      = @"doUserUtilityActionHelperWithParams:";
static NSString *kUserProfileApiAction                   = @"doUserProfileApiActionWithParams:";

- (void)serviceDidInit
{
}

- (void)gotoViewControllerWithUserViewType:(MSUserViewType)userViewType andInfoParams:(NSDictionary *)params
{
    [self gotoViewControllerWithUserViewType:userViewType andInfoParams:params andCallBackBlock:nil];
}

- (void)gotoViewControllerWithUserViewType:(MSUserViewType)userViewType andInfoParams:(NSDictionary *)params andCallBackBlock:(UserUtilityBlock)block
{
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if(block){
        [currentParams setObject:block forKey:@"callBackBlock"];
    }
    switch (userViewType) {
            
        case MSUserViewTypeProfile:
        {
            [self performTarget:kProfileUserViewController action:kProfileUserViewGotoAction params:currentParams];
            break;
        }
        case MSUserViewTypeCommonUserList:
        {
            [self performTarget:kCommonUserListViewController action:kCommonUserListViewGotoAction params:currentParams];
        }
        default:
            break;
    }
}

- (void)doServiceGetUserProfile:(NSString *)momoid fromLocalOnly:(BOOL)local syncCallBackBlock:(UserProfileBlock)callBackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    [params setBool:local forKey:@"fromLocalOnly"];
//    [params setString:momoid forKey:@"momoid"];
//    [params setObject:callBackBlock forKey:@"callBackBlock"];
//    [self performTarget:kUserUtility action:kUserUtilityGetUserProfile params:params];
}

- (void)doServiceSetUserProfile:(id)upi
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:upi forKey:@"userProfile"];
        [self performTarget:kUserUtility action:kUserUtilitySetUserProfile params:params];
}

- (void)doUserActionWithType:(MSUserActionType)actionType withParams:(NSDictionary *)params
{
    [self doUserActionWithType:actionType withParams:params andCallBack:nil];
}

- (void)doUserActionWithType:(MSUserActionType)actionType withParams:(NSDictionary *)params andCallBack:(UserUtilityBlock)block
{
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [currentParams setObject:@(actionType) forKey:@"actionType"];
    if(block){
        [currentParams setObject:block forKey:@"callBackBlock"];
    }
    [self performTarget:kUserUtility action:kUserUtilityAction params:currentParams];
}

- (void)requestInfomationsFromRemotebyParams:(NSDictionary *)params andApiType:(MSUserApiType)apiType target:(id)aTarget okSelector:(SEL)okSelector errSelector:(SEL)errSelector failSelector:(SEL)failSelector
{
    NSMutableDictionary *currentParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [currentParams setObject:@(apiType) forKey:@"apiType"];
    [currentParams setObject:aTarget forKey:@"aTarget"];
    [currentParams setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [currentParams setObject:NSStringFromSelector(errSelector) forKey:@"errSelector"];
    [currentParams setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kUserUtility action:kUserProfileApiAction params:currentParams];
}

- (void)doServiceFollow:(BOOL)follow momoid:(NSString *)momoid message:(NSString *)message asyncCallBack:(UserHelperBlock)helpBlock // follow为YES关注，NO取关
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:@(MSUserHelperTypeFollow) forKey:@"helperType"];
    [params setObject:@(follow) forKey:@"follow"];
    [params setObject:momoid forKey:@"momoid"];
    [params setObject:message forKey:@"message"];
    [params setObject:helpBlock forKey:@"callBackBlock"];
    [self performTarget:kUserUtility action:kUserUtilityHelper params:params];
}
- (void)doServiceBlock:(BOOL)block momoid:(NSString *)momoid source:(NSInteger)source asyncCallBack:(UserHelperBlock)helpBlock      // block为YES拉黑，NO解除
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:@(MSUserHelperTypeBlock) forKey:@"helperType"];
    [params setObject:@(block) forKey:@"block"];
    [params setObject:momoid forKey:@"momoid"];
    [params setObject:@(source) forKey:@"source"];
    [params setObject:helpBlock forKey:@"callBackBlock"];
    [self performTarget:kUserUtility action:kUserUtilityHelper params:params];
}
- (void)doServiceRemoveFans:(NSString *)momoid asyncCallBack:(UserHelperBlock)helpBlock                                          // 移除粉丝
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:@(MSUserHelperTypeRemoveFans) forKey:@"helperType"];
    [params setObject:momoid forKey:@"momoid"];
    [params setObject:helpBlock forKey:@"callBackBlock"];
    [self performTarget:kUserUtility action:kUserUtilityHelper params:params];
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
        //        if (![[NSThread currentThread] isMainThread]) {
        //            [target performSelectorOnMainThread:action withObject:tempParaDic waitUntilDone:YES];
        //        } else {
        [target performSelector:action withObject:tempParaDic];
        //        }
        
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

/**
 *  需要延长生命周期（FeedManagerUtility生命周期需要跟随MSUser）
 */

- (id)increaseTargetLife:(NSString *)actionStr targetStr:(NSString *)aTargetStr
{
    id tempTarget = nil;
    Class TargetClass = NSClassFromString(aTargetStr);
    
    if([aTargetStr isEqualToString:kUserUtility]) {
        if(!tempTarget)
        {
//            tempTarget = [MSUserUtility userUtility];
        }
    }else {
        tempTarget = [[TargetClass alloc] init];
    }
    
    return tempTarget;
}


@end

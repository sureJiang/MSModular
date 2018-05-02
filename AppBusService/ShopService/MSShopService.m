//
//  MSShopService.m
//  DEMO
//
//  Created by JZJ on 16/8/10.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import "MSShopService.h"
#import "MSAppBusHeader.h"

//跳转商家
static NSString *kShopSearchResultViewController = @"MSSearchShopResultViewController";
static NSString *kShopSearchResultActionStr = @"pushToSearchResultController:";

//检查商家
static NSString *kShopCenterViewController = @"MSLBAShopCenterViewController";
static NSString *kShopCenterActionStr = @"checkShopStatusWithSource:";

//跳转商家中心
static NSString *kGotoShopCenterViewController = @"gotoLBAShopCenterViewControllerWithParams:";

//获取商家资料页
static NSString *kShopProfileManager = @"MSShopProfileManager";
static NSString *kFetchShopProfileActionStr = @"fetchShopProfile:";

//更新商家资料页
static NSString *kUpdataShopProfileActionStr = @"updateShopProfile:";

//跳转商家资料页
static NSString *kShopProfileViewController = @"MSProfileShopViewController";
static NSString *kGotoShopProfileActionStr = @"gotoShopProfileViewControllerWithParam:";

@interface MSShopService ()<MSShopServiceProtocol>
@property (nonatomic ,strong) NSMutableDictionary *cacheTargetDic;
@end

@implementation MSShopService
MSRegistService(MSShopServiceProtocol)//注册服务
- (void)serviceDidInit
{
    
}

#pragma mark - 页面跳转
//1.跳转商家搜索结果界面
- (void)gotoShopSearchResultViewControllerWithText:(NSString *)searchText
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:searchText forKey:@"searchText"];
    [self performTarget:kShopSearchResultViewController action:kShopSearchResultActionStr params:paramDic];
}
#pragma mark - 数据处理
//2.检测商家状态
- (void)checkShopStatusWithSourceType:(MSApplyServiceShopSourceType)sourceType
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(sourceType) forKey:@"source"];
    [self performTarget:kShopCenterViewController action:kShopCenterActionStr params:param];

}

//3.获取商家资料
- (void)fetchShopProfileWithShopId:(NSString *)shopId completedblock:(MSShopProfileBlock)shopProfileBlock
{
    NSMutableDictionary *paraDic = [NSMutableDictionary new];
    [paraDic setObject:shopId forKey:@"shopId"];
    [paraDic setObject:shopProfileBlock forKey:@"block"];
    [self performTarget:kShopProfileManager action:kFetchShopProfileActionStr params:paraDic];
}

//4.设置商家资料
- (void)updateShopProfile:(id)shopProfile
{
    NSMutableDictionary *paraDic = [NSMutableDictionary new];
    [paraDic setObject:shopProfile forKey:@"shopProfile"];
    [self performTarget:kShopProfileManager action:kUpdataShopProfileActionStr params:paraDic];
}

#pragma mark - 网络API
//5.关闭广告
- (void)closeADWithADId:(NSString *)adId
{
    NSMutableDictionary *postParam = [NSMutableDictionary dictionary];
    [postParam setObject:adId forKey:@"adid"];
    
//    [MSApiBase postRequestWithUrl:API_CLOSE_RECOMMEND_AD
//                requestIdentifier:nil
//                            param:postParam
//                          timeout:kDefaultTimeOutValue
//                         userInfo:nil
//                           target:nil
//                               ok:nil
//                              err:nil
//                             fail:nil];
}


//6. 跳转商家资料页
- (void)gotoShopProfileViewControllerWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paraDic = [NSMutableDictionary new];
    [paraDic setObject:groupId forKey:@"shopId"];
    [self performTarget:kShopProfileViewController action:kGotoShopProfileActionStr params:paraDic];
    
}

//7. 跳转商家中心
- (void)gotoShopCenterViewControllerWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paraDic = [NSMutableDictionary new];
    [paraDic setObject:groupId forKey:@"shopId"];
    [self performTarget:kShopCenterViewController action:kGotoShopCenterViewController params:paraDic];

}

/**
 *  对于执行异步操作的需要延长生命周期
 *
 *  @param actionStr 判断执行什么操作
 *  @param aTargetClass    targetClass
 */
- (id)increaseTargetLife:(NSString *)actionStr targetClass:(Class)aTargetClass
{
    NSString *signalActionStr = nil;
    id tempTarget = nil;
  
    if([actionStr isEqualToString:kShopCenterActionStr])
    {
        signalActionStr = kShopCenterActionStr;
    }else if ([actionStr isEqualToString:kFetchShopProfileActionStr])
    {
        signalActionStr = kFetchShopProfileActionStr;
    }
    
    if(signalActionStr)
    {
        tempTarget = [self.cacheTargetDic objectForKey:signalActionStr];
        if(!tempTarget)
        {
            tempTarget = [[aTargetClass alloc] init];
            [self.cacheTargetDic setObject:tempTarget forKey:signalActionStr];
        }
    }else
    {
        tempTarget = [[aTargetClass alloc] init];
    }
    return tempTarget;
}


- (void)performTarget:(NSString *)targetStr
               action:(NSString *)actionStr
               params:(NSDictionary *)paramDic
{
    
    NSDictionary *tempParaDic = paramDic;
    Class targetClass = NSClassFromString(targetStr);
    id target = [self increaseTargetLife:actionStr targetClass:targetClass];
    
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

#pragma mark - 属性

- (NSMutableDictionary *)cacheTargetDic
{
    if(!_cacheTargetDic)
    {
        _cacheTargetDic = [NSMutableDictionary new];
    }
    return _cacheTargetDic;
}

@end

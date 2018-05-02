//
//  GroupService.m
//  DEMO
//
//  Created by JZJ on 16/7/20.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import "MSGroupService.h"
#import "MSAppBusHeader.h"

//获取群组profile
static NSString *kGroupProfileManager = @"GroupProfileManager";
static NSString *kGroupProfileGetFetchActionStr = @"fetchGroupProfileWithParamDic:";

//设置群组的相关信息
static NSString *kGroupInfoActionStr = @"setGroupInfo:";

//获取群成员海报墙
static NSString *kGroupGetMemberWallActionStr = @"getGroupMemberWallWithParams:";

//处理群组svip的相关问题
static NSString *kGroupExtendHelper = @"MSGroupExtendHelper";
static NSString *kGroupSvipCheckActionStr = @"checkSvipGroupWithParams:";

//网络请求
static NSString *kGroupApi = @"MSGroupApi";


@interface MSGroupService()<MSGroupServiceProtocol>

@property (nonatomic ,strong) NSMutableDictionary *cacheTargetDic;
@end

@implementation MSGroupService

MSRegistService(MSGroupServiceProtocol)//注册服务

- (void)serviceDidInit
{
    
}

//跳转组合
- (void)gotoViewControllerWithGroupId:(NSString *)groupId
                   WithControllerType:(MSViewControllerType)GotoGroupViewControllerType
{
    switch (GotoGroupViewControllerType) {
        case MSViewControllerTypeApplyGroup://申请群组
        {
            [self applyGroupWithGroupId:groupId];
        }
            break;
        case MSViewControllerTypeGroupInviting://群组邀请
        {
            [self gotoInviteViewControllerWithGroupId:groupId];
        }
            break;
        case MSViewControllerTypeGroupProfile://groupProfile
        {
            [self gotoGroupProfileWithGroupId:groupId];
        }
            break;
        case MSViewControllerTypeGroupSetting://群组设置
        {
            [self gotoGroupSettingWithGroupId:groupId];
        }
            break;
            
        default:
            break;
    }
}

//1. 申请加入群组
- (void)applyGroupWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self performTarget:@"MSNewApplyAndRecommendViewController"
                 action:@"pushToApplyAndRecommendViewControllerWithDic:" params:paramDic];

}

//2. 创建群组
- (void)createGroupWithCompletedBlock:(CompletedBlock)block
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:block forKey:@"block"];
    [self performTarget:@"MSGroupApplyViewController" action:@"presentViewControllerWithParams:" params:paramDic];
}

//3. 跳转群组profile
- (void)gotoGroupProfileWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self performTarget:@"MSProfileGroupViewController" action:@"pushToGroupProfileWithDic:" params:paramDic];
}

//4. 获取群组profile
- (void)fetchGroupProfileWithGroupId:(NSString *)groupId
                         requestType:(MSGroupProfileRequestCachePolicy)requestType
                      completedBlock:(GroupProfileBlock)block
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [paramDic setObject:block forKey:@"block"];
    [paramDic setObject:[NSNumber numberWithInt:requestType] forKey:@"requestType"];
    [self performTarget:kGroupProfileManager action:kGroupProfileGetFetchActionStr params:paramDic];

}
//5. 设置群组
- (void)gotoGroupSettingWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self performTarget:@"MSGroupSettingViewController" action:@"pushToGroupProfileWithDic:" params:paramDic];
}

//6. 跳转群组成员列表
- (void)gotoGroupMemberlistWithGroupId:(NSString *)groupId
                        gotoActionType:(MSGotoViewControllerActionType)actionType
                              viewType:(MemberViewType)viewType
                            withSelectMemberBlock:(SelectMemberBlock)block
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [paramDic setObject:block forKey:@"block"];
    [paramDic setObject:[NSNumber numberWithInteger:actionType] forKey:@"actionType"];
    [paramDic setObject:[NSNumber numberWithInteger:viewType] forKey:@"viewType"];
    [self performTarget:@"MomoGroupMemberViewController"
                 action:@"gotoGroupMemberViewControllerWithParams:"
                 params:paramDic];
}
//7.设置群组相关信息
/**
 *  设置群组相关信息
 *
 *  @param groupId   群组id，对于不需要传id的可以传nil
 *  @param groupInfo 群组信息 如 profile，profileArray
 */
- (void)setGroupInfoWithInfo:(id)groupInfo WithInfoType:(MSGroupInfoType)infoType
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupInfo forKey:@"groupInfo"];
    [paramDic setObject:[NSNumber numberWithInteger:infoType] forKey:@"infoType"];
    [self performTarget:kGroupProfileManager action:kGroupInfoActionStr params:paramDic];
}

//8. 群组邀请
- (void)gotoInviteViewControllerWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self performTarget:@"MSGroupInviteViewController"
                 action:@"gotoGroupInviteViewControllerWithParams:"
                 params:paramDic];
}

//9. 群组搜索
- (void)gotoGroupSearchViewControllerWithSearchText:(NSString *)searchText
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:searchText forKey:@"searchText"];
    [self performTarget:@"MMGroupSearchResultController"
                 action:@"pushToSearchResultViewControllerWithParams:"
                 params:paramDic];

}

// 10. 获取群组墙照片
- (void)getGroupMemberWallWithGroupId:(NSString *)groupId
                                index:(NSUInteger)index
                                count:(NSUInteger)count
                       completedBlock:(ArrayCompletedBlock)block
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [paramDic setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [paramDic setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    [paramDic setObject:block forKey:@"block"];
    [self performTarget:@"MSGroupProfileHelper" action:kGroupGetMemberWallActionStr params:paramDic];
    
}

//11. 校验svip群组
- (void)checkSvipGroupWithGroupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self performTarget:kGroupExtendHelper action:kGroupSvipCheckActionStr params:paramDic];
}

//12. 处理SVIP群组相关响应处理
- (void)handleUpdteSvipWithDic:(NSDictionary *)dic groupId:(NSString *)groupId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [paramDic setObject:dic forKey:@"data"];
    [self performTarget:kGroupExtendHelper action:@"handleUpdateSvipResponseWithParams:" params:paramDic];

}

//13. 根据群组id 搜索群组
//13.0 根据群组id 搜索群组
- (void)searchGroupWithGroupId:(NSString *)groupId
                      delegate:(id)delegate
                    okSelector:(SEL)okSelector
                 errorSelector:(SEL)errorSelector
                  failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupId forKey:@"groupId"];
    [paramDic setObject:delegate forKey:@"delegate"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errorSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action:@"searchGroupWithParams:"  params:paramDic];
}

//14.0 群活动经纬度取地点
- (void)getGroupPartySiteByLat:(double)lat
                        andLng:(double)lng
             requestIdentifier:(NSString *)identifier
                      delegate:(id)aDelegate
                    okSelector:(SEL)okSelector
                   errSelector:(SEL)errSelector
                  failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:[NSNumber numberWithDouble:lat] forKey:@"lat"];
    [paramDic setObject:[NSNumber numberWithDouble:lng] forKey:@"lng"];
    [paramDic setObject:aDelegate forKey:@"delegate"];
    [paramDic setObject:identifier forKey:@"identifier"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action:@"getGroupPartySiteWithParams:"  params:paramDic];

}
//15.0移除群组成员
- (void)removeGroupMember:(NSString *)groupid
                   member:(NSString *)momoid
               withReason:(NSString *)reason
                   target:(id)aTarget
               okSelector:(SEL)okSelector
              errSelector:(SEL)errSelector
             failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupid forKey:@"groupId"];
    [paramDic setObject:momoid forKey:@"momoId"];
    [paramDic setObject:reason forKey:@"reason"];
    [paramDic setObject:aTarget forKey:@"delegate"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action:@"removeGroupMemberWithParams:"  params:paramDic];
}
//17.0 邀请好友加入群组
- (void)inviteMomoFriend:(NSString *)remoteID
                     gid:(NSString *)gid
                  target:(id)target
              okSelector:(SEL)okSelector
             errSelector:(SEL)errSelector
            failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:gid   forKey:@"groupId"];
    [paramDic setObject:remoteID forKey:@"remoteId"];
    [paramDic setObject:target forKey:@"delegate"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action: @"inviteMomoFriendWithParams:"  params:paramDic];

}
//拒绝群组申请
- (void)refuseApplyJoinGroup:(NSString *)groupid
                      reason:(NSString *)aReason
                      momoID:(NSString *)momoid
                      target:(id)aTarget
                  okSelector:(SEL)okSelector
                 errSelector:(SEL)errSelector
                failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:groupid forKey:@"groupId"];
    [paramDic setObject:momoid forKey:@"momoId"];
    [paramDic setObject:aReason forKey:@"reason"];
    [paramDic setObject:aTarget forKey:@"delegate"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action:@"refuseApplyJoinGroupWithParams:"  params:paramDic];

}
//群组动态点击按钮等的处理方法
- (void)groupNoticeMethod:(NSString *)strUrl
                  fullUrl:(BOOL)fullUrl
                 userInfo:(NSDictionary *)anUserInfo
                 delegate:(id)delegate
               okSelector:(SEL)okSelector
              errSelector:(SEL)errSelector
             failSelector:(SEL)failSelector
{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject:strUrl forKey:@"strUrl"];
    [paramDic setObject:[NSNumber numberWithBool:fullUrl] forKey:@"fullUrl"];
    [paramDic setObject:anUserInfo forKey:@"userInfo"];
    [paramDic setObject:delegate forKey:@"delegate"];
    [paramDic setObject:NSStringFromSelector(okSelector) forKey:@"okSelector"];
    [paramDic setObject:NSStringFromSelector(errSelector) forKey:@"errorSelector"];
    [paramDic setObject:NSStringFromSelector(failSelector) forKey:@"failSelector"];
    
    [self performTarget:kGroupApi action:@"groupNoticeMethodWithParams:"  params:paramDic];

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
    if([actionStr isEqualToString:kGroupGetMemberWallActionStr])
    {
        signalActionStr = kGroupGetMemberWallActionStr;
        
    }else if ([actionStr isEqualToString:kGroupProfileGetFetchActionStr])
    {
        signalActionStr = kGroupProfileGetFetchActionStr;
        
    }else if ([actionStr isEqualToString:kGroupSvipCheckActionStr])
    {
        signalActionStr = kGroupSvipCheckActionStr;
        
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
        [target performSelector:action withObject:tempParaDic];
       
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

- (NSMutableDictionary *)cacheTargetDic
{
    if(!_cacheTargetDic)
    {
        _cacheTargetDic = [NSMutableDictionary new];
    }
    return _cacheTargetDic;
}

@end




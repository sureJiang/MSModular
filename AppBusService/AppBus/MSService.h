//
//  MSService.h
//  DEMO
//
//  Created by JZJ on 16/4/29.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef MSRegistService
#define MSRegistService(serviceProtocol) \
+ (void)load { [MSAppBus registerService:@protocol(serviceProtocol) withImplementClass:[self class]]; }

@class MomoGroupProfileInfo;

@protocol MSService <NSObject>
@required

/*
 生命周期管理后的初始化方法
 */
- (void)serviceDidInit;

@end

/*
 details as
 */
@protocol MessagerService <MSService>
- (void)addSendMsg;
@end


#pragma mark - User服务
typedef NS_ENUM(NSInteger ,MSUserViewType) {
    MSUserViewTypeNone                              = 0,
    MSUserViewTypeNearby                            = 1, //附近人
    MSUserViewTypeProfile                           = 2, //资料页
    MSUserViewTypeCommonUserList                    = 4, //用户列表,block返回点击列表的momoid
};

typedef NS_ENUM(NSInteger ,MSUserActionType) {
    MSUserActionTypeNone                            = 0,
    MSUserActionTypeGetNearbyFilter                 = 1,  //获取附近人过滤规则，返回NSDictionary
    
    MSUserActionTypeSetUserWithArray                = 5,
    
    MSUserActionTypeSetIsSecret                     = 6,
    
    MSUserActionTypeModelingUserOnly                = 7,
    MSUserActionTypeModelingUserCallBackMomoidList  = 8,// 返回momoid对应的数组
    MSUserActionTypeModelingUserCallBackUpiList     = 9,// 返回upi的数组
    
    MSUserActionTypeParseSimpleList                 = 10,//解析话题评论、赞等结构中包含的简略的user信息(name,momoid,avatar)
    
    MSUserActionTypeFetchProfileSync                = 11,
    MSUserActionTypeFetchProfileAsync               = 12,
    MSUserActionTypeFetchMiniProfileSync            = 13,
    
    MSUserActionTypeFetchBatchLimitedUserInfo       = 14,//批量获取受限用户的信息，type：1，点赞； 2，评论，当前在动态通知中使用
};

typedef NS_ENUM(NSInteger ,MSUserApiType) {
    MSUserApiTypeNone                               = 0,
    MSUserApiTypeFetchProfile                       = 1,//[p-1]取用户资料
    MSUserApiTypeFetchNiceProfile                   = 2,
    
    MSUserApiTypeRemoveMultiFans                    = 5,//批量移除粉丝
};

typedef NS_ENUM(NSInteger ,MSUserHelperType) {
    MSUserHelperTypeNone                            = 0,
    MSUserHelperTypeFollow                          = 1,
    MSUserHelperTypeBlock                           = 2,
    MSUserHelperTypeRemoveFans                      = 3,
};

typedef void(^UserUtilityBlock)(id obj);
typedef void(^UserProfileBlock)(id upi);
typedef void(^UserHelperBlock)(id);
@protocol MSUserServiceProtocol <MSService>
//User相关goto
- (void)gotoViewControllerWithUserViewType:(MSUserViewType)userViewType andInfoParams:(NSDictionary *)params;
//MSUserViewTypeCommonUserList                    = 4, //block返回点击列表的momoid
- (void)gotoViewControllerWithUserViewType:(MSUserViewType)userViewType andInfoParams:(NSDictionary *)params andCallBackBlock:(UserUtilityBlock)block;

//User相关action
- (void)doServiceGetUserProfile:(NSString *)momoid fromLocalOnly:(BOOL)local syncCallBackBlock:(UserProfileBlock)callBackBlock;
- (void)doServiceSetUserProfile:(id)upi;
- (void)doUserActionWithType:(MSUserActionType)actionType withParams:(NSDictionary *)params;
//MSUserActionTypeGetNearbyFilter                 = 1,  // block返回过滤规则NSDictionary
//MSUserActionTypeModelingUserCallBackMomoidList  = 8,  // block返回momoid对应的数组
//MSUserActionTypeModelingUserCallBackUpiList     = 9,  // block返回upi的数组
- (void)doUserActionWithType:(MSUserActionType)actionType withParams:(NSDictionary *)params andCallBack:(UserUtilityBlock)block;

//User相关api
- (void)requestInfomationsFromRemotebyParams:(NSDictionary *)params andApiType:(MSUserApiType)apiType target:(id)aTarget okSelector:(SEL)okSelector errSelector:(SEL)errSelector failSelector:(SEL)failSelector;

//User相关helper
- (void)doServiceFollow:(BOOL)follow momoid:(NSString *)momoid message:(NSString *)message asyncCallBack:(UserHelperBlock)helpBlock; // follow为YES关注，NO取关
- (void)doServiceBlock:(BOOL)block momoid:(NSString *)momoid source:(NSInteger)source asyncCallBack:(UserHelperBlock)helpBlock;      // block为YES拉黑，NO解除
- (void)doServiceRemoveFans:(NSString *)momoid asyncCallBack:(UserHelperBlock)helpBlock;                                             // 移除粉丝

@end


#pragma mark - Feed服务

typedef NS_ENUM (NSInteger ,MSFeedControllerType) {
    MSFeedControllerTypeNone,
    MSFeedControllerTypeFriends,                //好友动态
    MSFeedControllerTypeUser,                   //个人动态
    MSFeedControllerTypeGroup,                  //群空间
    MSFeedControllerTypeShopContainer,          //商家动态聚合页
    MSFeedControllerTypeShop,                   //商家动态列表
    MSFeedControllerTypeDetailNormal,           //动态详情（普通动态）
    MSFeedControllerTypeDetailShop              //商家动态详情
};

typedef NS_ENUM (NSInteger ,MSFeedSelectViewType) {
    MSFeedSelectViewTypeNone,
    MSFeedSelectViewTypeWhoCanSee,              //选择对谁可见
    MSFeedSelectViewTypeSite,                   //选择地点
};

typedef NS_ENUM(NSInteger ,MSFeedManagerType) {
    MSFeedManagerTypeNone,
    MSFeedManagerTypeNormal,                    //普通FeedManager
    MSFeedManagerTypeGroup,                     //群FeedManager
    MSFeedManagerTypeShop,                      //商家FeedManager
    
    MSFeedManagerTypeFeedListDB,
    MSFeedManagerTypeFeedCommentDraftDB,
    MSFeedManagerTypeFeedDraft,
};

typedef enum {
    MSPublishType_None = 0, //未定义
    
    //feed数据结构是 MSPublishFeedParam， 需存入数据库
    MSPublishType_Feed = 1, //留言板
    MSPublishType_Board = 2,//MM吧
    MSPublishType_GroupFeed = 3, //群留言板
    MSPulishType_PartyFeed  = 4,//活动留言
    MSPublishType_BoardFeedComment = 5,//帖子评论
    MSPublishType_EditBoardFeed    = 6,//编辑帖子
    MSPublishType_ShopFeed    = 7, //商家留言
    MSPublishType_Post = 8, //发布圈子
    MSPublishType_PostFeed = 9, //分享圈子帖子到动态
    
    //comment数据结构不是MSPublishFeedParam, Ø而是 MSPublishCommentParam,不存入数据库
    MSPublishType_FeedComment    = 10,//留言板评论,
    MSPublishType_GroupFeedComment    = 11, //群留言板评论
    MSPublishType_PartyFeedComment    = 12, //活动评论
    MSPublishType_QzFeedComment  = 13,       //圈子评论
    MSPublishType_moment = 14       //时刻
} MSPublishType;


typedef void (^SelectedFeedSiteBlock)(NSDictionary *siteDic);
typedef void (^SelectedWhoCanSeeMeBlock)(NSInteger type, NSArray *selectedIDs);
typedef void (^SyncCallBackFeedBlock)(id mfeed);
typedef void (^GetFeedReleaseDraftBlock)(id draft);
//#import "MSPublishFeedParam.h"
@protocol MSFeedServiceProtocol <MSService>
//动态相关goto
- (void)gotoFeedViewControllerWithType:(MSFeedControllerType)type andParams:(NSDictionary *)params;
//地点选择
- (void)getSiteFromFeedSitelistWithParams:(NSDictionary *)params byCallBackBlock:(SelectedFeedSiteBlock)callBackBlock;
//谁可以看
- (void)getItemsFromWhoCanSeeMeWithParams:(NSDictionary *)params byCallBackBlock:(SelectedWhoCanSeeMeBlock)callBackBlock;

/*
 发布动态
 需要的参数
 stickyQuickEntrance
 topicItem
 publishFeedSource
 releaseFeedType        //发动态,发群组帖子,群动态分享到动态,贴子,贴子分享到动态
 
 groupId
 preloadImage           //发布页预加载的图片
 preloadString          //发布页预加载的文案
 videoResult            //发布页预加载的video
 infoDict
 musicItem              //发布页预加载的music
 postType
 */
- (void)releaseFeedActivityQuickEntranceWithParams:(NSDictionary *)params;

//getFeed by feedId
- (void)getFeedWithType:(MSFeedManagerType)feedType feedId:(NSString *)feedId syncCallBackBlock:(SyncCallBackFeedBlock)block;

//UserProfileManager处理返回的feed列表，转换成feed数据，如果有user， site数据也一起转换
- (void)modelingSingleFeed:(NSDictionary *)aFeedDic syncCallBackBlock:(SyncCallBackFeedBlock)block;
//setFeed
- (void)resetFeed:(id)aFeed;
//FeedSiteDataManager用户退出重新登录时用来刷新fastQueryFielter
- (void)updateFeedFastQueryFilterWithMomoID:(NSString *)momoid;
//DBFriendFeedListProvider   DBFeedCommentDraftProvider DBFeedDraftProvider
- (void)clearAllInfoFromDbWithType:(MSFeedManagerType)type;
//发布草稿
- (void)getFeedReleaseDraftWithTargetId:(NSString *)targetId publishType:(MSPublishType)type syncCallBackBlock:(GetFeedReleaseDraftBlock)block;

@end



#pragma mark - 群组服务

typedef NS_ENUM(NSUInteger, MSGroupProfileRequestCachePolicy)
{
    MSGroupProfileReloadIgnoringLocalCacheData = 0, //不使用缓存,只从网络更新数据
    MSGroupProfileReloadLocalCache, //优先使用缓存，无法找到缓存时才连网更新
    MSGroupProfileReloadLocalOnly, //只读缓存
};

typedef NS_ENUM(NSUInteger,MSGotoViewControllerActionType) {
    MSGotoViewControllerActionTypePush,//push
    MSGotoViewControllerActionTypePresent,//present
};

//群组成员列表用
typedef NS_ENUM(NSUInteger, MemberViewType)
{
    MemberViewNormal = 0,
    MemberViewSelect = 1
};

//设置群组相关信息
typedef NS_ENUM(NSUInteger,MSGroupInfoType)
{
    MSGroupInfoTypeProfile,
    MSGroupInfoTypeProfileArray,
    MSGroupInfoTypeSiteProfile,
    MSGroupInfoTypeSiteProfileArray,
};

//跳转viewcontroller的类型
typedef NS_ENUM(NSUInteger,MSViewControllerType)
{
    MSViewControllerTypeApplyGroup,
    MSViewControllerTypeGroupProfile,
    MSViewControllerTypeGroupSetting,
    MSViewControllerTypeGroupInviting,
    
};

typedef void(^CompletedBlock)(NSDictionary *dic);
typedef void(^GroupProfileBlock)(MomoGroupProfileInfo *groupInfo);
typedef void (^SelectMemberBlock)(NSString *memberName, NSString *momoID);//群组成员列表的block
//block 返回值是数组 便于通用
typedef void(^ArrayCompletedBlock)(NSArray *array);

@protocol MSGroupServiceProtocol <MSService>
#pragma mark - 群组相关页面跳转

//1. 跳转的方法
/**
 *  跳转方法
 *
 *  @param groupId                     群组id
 *  @param GotoGroupViewControllerType 跳转到哪个界面
 MSViewControllerTypeApplyGroup,
 MSViewControllerTypeGroupProfile,
 MSViewControllerTypeGroupSetting,
 MSViewControllerTypeGroupInviting,
 */
- (void)gotoViewControllerWithGroupId:(NSString *)groupId
                   WithControllerType:(MSViewControllerType)GotoGroupViewControllerType;

//2. 创建群组
- (void)createGroupWithCompletedBlock:(CompletedBlock)block;

//3. 跳转群组成员列表
- (void)gotoGroupMemberlistWithGroupId:(NSString *)groupId
                        gotoActionType:(MSGotoViewControllerActionType)actionType
                              viewType:(MemberViewType)viewType
                 withSelectMemberBlock:(SelectMemberBlock)block;

//4. 群组搜索结果
- (void)gotoGroupSearchViewControllerWithSearchText:(NSString *)searchText;

#pragma mark - 群相关数据处理
//5.设置群组相关信息
/**
 *  设置群组相关信息
 *
 *  @param groupId   群组id，对于不需要传id的可以传nil
 *  @param groupInfo 群组信息 如 profile，profileArray
 */
- (void)setGroupInfoWithInfo:(id)groupInfo WithInfoType:(MSGroupInfoType)infoType;

#pragma mark - 群相关api处理
//6. 获取群组profile
- (void)fetchGroupProfileWithGroupId:(NSString *)groupId
                         requestType:(MSGroupProfileRequestCachePolicy)requestType
                      completedBlock:(GroupProfileBlock)block;
//7. 获取群组墙照片
- (void)getGroupMemberWallWithGroupId:(NSString *)groupId
                                index:(NSUInteger)index
                                count:(NSUInteger)count
                       completedBlock:(ArrayCompletedBlock)block;
//8. 校验svip群组
- (void)checkSvipGroupWithGroupId:(NSString *)groupId;

@end


#pragma mark - 商家

@class MSShopProfile;
//这个是作为service的枚举 为了不和具体类内部冲突而写的，与类内部的MDApplyShopSourceType 一一对应
typedef enum {
    MSApplyServiceShopSourceTypeUndefined,
    MSApplyServiceShopSourceTypeShopProfile,
    MSApplyServiceShopSourceTypeSetting,
    MSApplyServiceShopSourceTypeSpread,//包括type6 banner等
}MSApplyServiceShopSourceType;

typedef void(^MSShopProfileBlock)(MSShopProfile *shopProfile);


@protocol MSShopServiceProtocol <MSService>
//1.跳转商家搜索结果界面
- (void)gotoShopSearchResultViewControllerWithText:(NSString *)searchText;

//2.检测商家状态
- (void)checkShopStatusWithSourceType:(MSApplyServiceShopSourceType)sourceType;

//3.获取商家资料
- (void)fetchShopProfileWithShopId:(NSString *)shopId
                    completedblock:(MSShopProfileBlock)shopProfileBlock;

//4.设置商家资料
/**
 *  更新商家profile
 *
 *  @param shopProfile : 1 数组，更新的是数组 2 传入的是profile，更新profile
 */
- (void)updateShopProfile:(id)shopProfile;

//5.关闭广告
- (void)closeADWithADId:(NSString *)adId;
//6. 跳转商家资料页
- (void)gotoShopProfileViewControllerWithGroupId:(NSString *)groupId;
@end









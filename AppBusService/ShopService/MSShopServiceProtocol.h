//
//  MSShopServiceProtocol.h
//  DEMO
//
//  Created by JZJ on 16/8/10.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSShopServiceProtocol <NSObject>


//2 lbaApi
/*
 removeShopFeed ok
 likeAdWithADId  ok
 commentListByFeed ok
 removeShopFeedComment ok
 shopFeedProfileById ok
 shopFeedById ok
 shopFeedListWithShopID ok
 shopCommentListWithShopID ok
 checkShopFeedContent ok
 
 */



#pragma mark - 页面跳转
//1 商家搜索结果
// push  +1 （text）

//3 lbaCenter
/*
 checkShopStatusWithSource  +1 （shopId）
 */


#pragma mark - 数据处理
//5 MSShopProfileManager
/*
 shopProfile/setShopProfile + 2
 */
//4 MSProfileShopViewController
/*
 判断类获取shopKeepMomoId +1
 */
#pragma mark - 网络API
// closeADWithADId 6     +1

@end

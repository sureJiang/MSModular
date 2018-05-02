//
//  GroupService.h
//  DEMO
//
//  Created by JZJ on 16/7/20.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSGroupServiceProtocolNew <NSObject>

//群组搜索
- (void)pushToSearchResultViewControllerWithParams:(NSDictionary *)params;
//创建群组
- (void)presentViewControllerWithParams:(NSDictionary *)paramDic;

@end
@interface MSGroupService : NSObject

@end

@interface MSGroupUnit : NSObject

@end

//
//  MSAppBus.h
//  DEMO
//
//  Created by JZJ on 16/5/4.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSAppBus : NSObject
@property(nonatomic,strong)    NSMutableDictionary *serviceContainer;
;
/*
 just like
 id<XXXServiceProtocol> service = [MSAppContext service:XXXServiceProtocol];
 */


/*
  生命周期关联User 但是不对外部提供接口
 */
+ (id)element:(Class)aclass;


/*
 生命周期关联User 同时对外部提供接口
 */
+ (id)service:(Protocol *)serviceProtocol;
+ (BOOL)existService:(Protocol *)serviceProtocol;
+ (void)registerService:(Protocol *)serviceProtocol withImplementClass:(Class)implClass;

@end

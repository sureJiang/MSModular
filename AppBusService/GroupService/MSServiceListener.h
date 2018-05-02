//
//  MSServiceListener.h
//  DEMO
//
//  Created by JZJ on 16/9/27.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSGroupService.h"

@interface MSServiceListener : NSObject
@property (atomic, weak, readonly) id delegate;
@property (nonatomic, readonly) dispatch_queue_t delegateQueue;

@property (nonatomic,copy,readonly) NSString *delegateString;
@property (nonatomic,assign,readonly) BOOL isRealTime;
@property (nonatomic,weak) id delegateObject;


+ (MSServiceListener *)listenerWithDelegateString:(NSString *)aDelegateString isRealTime:(BOOL)realTime;
+ (MSServiceListener *)listenerWithDelegateString:(NSString *)aDelegateString
                                    delegateQueue:(dispatch_queue_t)adelegateQueue isRealTime:(BOOL)realTime;
+ (MSServiceListener *)listenerWithDelegate:(id)aDelegate;
+ (MSServiceListener *)listenerWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)adelegateQueue;
- (void)removeListenerDelegate;
- (NSString *)description;
@end

@interface MSServiceListenerManager : NSObject<MSGroupServiceProtocolNew>

+ (instancetype)sharedManager;
- (void)removeListenerInfoKindOfClass:(Class)aClass;

//调试使用，查看所有的listener
- (void)logAll;


@end

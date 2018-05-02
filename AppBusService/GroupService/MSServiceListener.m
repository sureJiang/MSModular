//
//  MSServiceListener.m
//  DEMO
//
//  Created by JZJ on 16/9/27.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#if !__has_feature(objc_arc)
#error MSServiceListener must be built with ARC.
#endif

#define LISTENLOCK(...) OSSpinLockLock(&_lock); \
__VA_ARGS__; \
OSSpinLockUnlock(&_lock);

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import "MSServiceListener.h"


/*
 维护一个序列使用弱引用delegate的指针作为中间层
 */
@interface _ServiceListenerInfo : NSObject
@end

@implementation _ServiceListenerInfo
{
@public
    __strong MSServiceListener *_listener;
    SEL _action;
    Protocol *_protocol;
    NSString * _key;
    dispatch_queue_t queue;
}

- (instancetype)initWithListener:(MSServiceListener *)alistener action:(SEL)action key:(NSString *)akey
{
    self = [super init];
    if (self) {
        _listener = alistener;
        _action = action;
        _key = akey;
    }
    return self;
}

- (NSUInteger)hash
{
    return [_key hash];
}

- (BOOL)isEqual:(id)object
{
    if (nil == object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [_key isEqualToString:((_ServiceListenerInfo *)object)->_key];
}

@end


typedef void (^MSListenerBlock)(id adelegate, id object, NSDictionary *change);



@implementation MSServiceListenerManager
{
    NSHashTable *_infos;
     OSSpinLock _lock;
}

+ (instancetype)sharedManager
{
    static MSServiceListenerManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MSServiceListenerManager alloc] init];
    });
    
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _infos = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory |
                  NSPointerFunctionsObjectPointerPersonality capacity:0];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)addListenerInfo:(_ServiceListenerInfo *)alistenerInfo
{
    if (alistenerInfo) {
        LISTENLOCK([_infos addObject:alistenerInfo]);
    }
}

- (void)removeListenerInfo:(_ServiceListenerInfo *)alistenerInfo
{
    if (alistenerInfo && _infos.count) {
        LISTENLOCK([_infos removeObject:alistenerInfo]);
    }
}


- (void)removeListenerInfoKindOfClass:(Class)aClass;
{
    //清除是aClass的delegate
    NSMutableArray *array = [self tempDelegateArray];
    for (_ServiceListenerInfo *obj in array) {
        MSServiceListener *listener = ((_ServiceListenerInfo *)obj)->_listener;
        if (listener) {
            id delegate = listener.delegate;
            if (delegate) {
                if ([delegate isKindOfClass:aClass]){
                    [self removeListenerInfo:obj];
                }
            }
        }
    }
}

- (NSMutableArray *)tempDelegateArray
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    LISTENLOCK(
               NSEnumerator *enumerator = [_infos objectEnumerator];
               id anObject = nil;
               while ((anObject = [enumerator nextObject])) {
                   [tempArray addObject:anObject];
               }
               );
    
    return tempArray;
}

//调试使用，查看所有的listener
- (void)logAll
{
    NSMutableArray *array = [self tempDelegateArray];
    NSLog(@"-------->log all MSMultiListener count = %@", @([array count]));
    for (_ServiceListenerInfo *obj in array) {
        MSServiceListener *listener = ((_ServiceListenerInfo *)obj)->_listener;
        
        if (listener) {
            id delegate = listener.delegate;
            if (delegate) {
                NSLog(@"delegate = %@",delegate);
            }
        }
    }
}

- (void)doNothing
{
    
}

+ (id)createTargetObjectWithListener:(MSServiceListener *)aListener targetClass:(Class)aTargetClass
{
    id aTargetObject = nil;
    if(!aListener.isRealTime)
    {
        if(aListener.delegateObject)
        {
            aTargetObject = aListener.delegateObject;
        }else
        {
            aTargetObject = [[aTargetClass alloc] init];
            aListener.delegateObject = aTargetObject;
        }
    }else
    {
        aTargetObject = [[aTargetClass alloc] init];
    }
    return aTargetObject;

}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for(_ServiceListenerInfo *obj in [self tempDelegateArray])
    {
        MSServiceListener *listener = ((_ServiceListenerInfo *)obj)->_listener;
        
        if(listener)
        {
            id delegateString = listener.delegateString;
            if([delegateString isKindOfClass:[NSString class]])
            {
                Class aTargetClass = NSClassFromString(delegateString);
                id aTargetObject = [MSServiceListenerManager createTargetObjectWithListener:listener
                                                                                targetClass:aTargetClass];
                
                NSMethodSignature *result = [aTargetObject methodSignatureForSelector:aSelector];
                
                if(result)
                {
                    return result;
                }
            }
        }
    }
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation
{
    NSMethodSignature *methodSignature = [origInvocation methodSignature];
    NSInvocation *duInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [duInvocation setSelector:[origInvocation selector]];
    
    NSUInteger i, count = [methodSignature numberOfArguments];
    
    for(i = 2; i < count; i ++)
    {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        if(*type == *@encode(BOOL))
        {
            BOOL value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(char) || *type == *@encode(unsigned char))
        {
            char value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(short) || *type == *@encode(unsigned short))
        {
            short value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(int) || *type == *@encode(unsigned int))
        {
            int value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(long) || *type == *@encode(unsigned long))
        {
            long value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(long long) || *type == *@encode(unsigned long long))
        {
            long long value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(double))
        {
            double value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == *@encode(float))
        {
            float value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == '@')
        {
            void *value;
            [origInvocation getArgument:&value atIndex:i];
            [duInvocation setArgument:&value atIndex:i];
        }else if (*type == '^')
        {
            void *block;
            [origInvocation getArgument:&block atIndex:i];
            [duInvocation setArgument:&block atIndex:i];
        }else
        {
            NSString *selectorStr = NSStringFromSelector([origInvocation selector]);
            NSString *format = @"Argument %lu to method %@ - Type(%c) not supported";
            NSString *reason = [NSString stringWithFormat:format,(unsigned long)(i - 2),selectorStr,*type];
            
            [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
        }
        
    }
    
    [duInvocation retainArguments];
    return duInvocation;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    for(_ServiceListenerInfo *obj in [self tempDelegateArray])
    {
        _ServiceListenerInfo *info = nil;
        LISTENLOCK(info = [_infos member:obj]);
        
        if(nil != info)
        {
            MSServiceListener *listener = info->_listener;
            if(nil != listener && nil != listener.delegateString)
            {
                Class aTargetClass = NSClassFromString(listener.delegateString);
                id aTargetObject = [MSServiceListenerManager createTargetObjectWithListener:listener
                                                                                targetClass:aTargetClass];
                
                if([aTargetObject respondsToSelector:selector])
                {
                    NSInvocation *duplication = [self duplicateInvocation:anInvocation];
                    dispatch_async(listener.delegateQueue, ^{
                        [duplication invokeWithTarget:aTargetObject];
                    });
                }
            }
        }
    }
}

- (void)presentViewControllerWithParams:(NSDictionary *)paramDic {
    
}

- (void)pushToSearchResultViewControllerWithParams:(NSDictionary *)params {
    
}

@end

@interface MSServiceListener ()
@end

@implementation MSServiceListener
{
    _ServiceListenerInfo *info;
}


@synthesize delegate;
@synthesize delegateQueue;
@synthesize delegateString;
@synthesize delegateObject;
@synthesize isRealTime;


+ (MSServiceListener *)listenerWithDelegate:(id)aDelegate
{
    return [[MSServiceListener alloc] initWithDelegate:aDelegate];
}

- (MSServiceListener *)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        delegate = aDelegate;
    }
    return self;
}

+ (MSServiceListener *)listenerWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)adelegateQueue
{
    return [[MSServiceListener alloc] initWithListenerDelegate:aDelegate delegateQueue:adelegateQueue];
}

- (instancetype)initWithListenerDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)adelegateQueue
{
    self = [super init];
    if (self) {
        delegate = aDelegate;
        delegateQueue = adelegateQueue;
        info = [[_ServiceListenerInfo alloc] initWithListener:self action:nil key:nil];
        [[MSServiceListenerManager sharedManager] addListenerInfo:info];
    }
    return self;
}

//代理为字符串

+ (MSServiceListener *)listenerWithDelegateString:(NSString *)aDelegateString isRealTime:(BOOL)realTime
{
    return [[MSServiceListener alloc] initWithDelegateString:aDelegateString isRealTime:realTime];
}

- (MSServiceListener *)initWithDelegateString:(NSString *)aDelegateString isRealTime:(BOOL)realTime
{
    self = [super init];
    if (self) {
        delegateString = aDelegateString;
        isRealTime = realTime;
    }
    return self;
}

+ (MSServiceListener *)listenerWithDelegateString:(NSString *)aDelegateString delegateQueue:(dispatch_queue_t)adelegateQueue isRealTime:(BOOL)realTime
{
    return [[MSServiceListener alloc] initWithListenerDelegateString:aDelegateString delegateQueue:adelegateQueue isRealTime:realTime];
}

- (instancetype)initWithListenerDelegateString:(NSString *)aDelegateString delegateQueue:(dispatch_queue_t)adelegateQueue isRealTime:(BOOL)realTime
{
    self = [super init];
    if (self) {
        delegateString = aDelegateString;
        delegateQueue = adelegateQueue;
        isRealTime = realTime;
        info = [[_ServiceListenerInfo alloc] initWithListener:self action:nil key:nil];
        [[MSServiceListenerManager sharedManager] addListenerInfo:info];
    }
    return self;
}

- (void)removeListenerDelegate
{
    if(info)
        
    {
        [[MSServiceListenerManager sharedManager] removeListenerInfo:info];
    }
}

- (void)dealloc
{
    delegate = nil;
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MSListener: %p delegate:%p %@",self,delegate,delegate];
}

@end


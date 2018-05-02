//
//  MSAppBus.m
//  DEMO
//
//  Created by JZJ on 16/5/4.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import "MSAppBus.h"
#import "MSService.h"
#import "MSUnit.h"
static NSMutableDictionary   *_serviceClasses;
static NSMutableDictionary   *_unitClasses;

@interface MSAppBus ()

@end

@implementation MSAppBus

+ (instancetype)sharedBus
{
    static MSAppBus *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[self alloc] init];
    });
    return context;
}

- (NSDictionary * )serviceContainer
{
    // lifeCircle belong to MSUser
    return _serviceContainer;
}

- (NSDictionary *)unitClassDictionary
{
    // todo
    return nil;
}

- (NSDictionary *)serviceClasses
{
    return (_serviceClasses ? _serviceClasses : (_serviceClasses = [[NSMutableDictionary alloc] init]));
}

- (NSDictionary *)unitClasses
{
    return (_unitClasses ? _unitClasses : (_unitClasses = [[NSMutableDictionary alloc] init]));
}

- (id)init
{
    self = [super init];
    if (self) {
        _unitClasses = [[NSMutableDictionary alloc] init];
        _serviceClasses = [[NSMutableDictionary alloc] init];
        _serviceContainer = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (id)element:(Class)aclass;
{
   NSParameterAssert(aclass != nil);
    if (!aclass) return nil;
    MSAppBus *appBus = [MSAppBus sharedBus];
    id <MSService> element = [[appBus serviceContainer] objectForKey:NSStringFromClass(aclass)];
    if (element) return element;
    
    id elementInstance = [[aclass alloc] init];
    if ([elementInstance respondsToSelector:@selector(serviceDidInit)]) {
        [elementInstance serviceDidInit];
    }
    [[appBus serviceContainer] setObject:elementInstance forKey:NSStringFromClass(aclass)];
    return elementInstance;
}

+ (void)registerService:(Protocol *)serviceProtocol withImplementClass:(Class)implClass
{
    NSParameterAssert(serviceProtocol != nil);
    NSParameterAssert(implClass != nil);
    if (!serviceProtocol || !implClass) return;
    MSAppBus *appBus = [MSAppBus sharedBus];
    [[appBus serviceClasses] setValue:implClass forKey:NSStringFromProtocol(serviceProtocol)];
}

+ (id)service:(Protocol *)serviceProtocol
{
    NSParameterAssert(serviceProtocol != nil);
    if (!serviceProtocol) return nil;
    MSAppBus *appBus = [MSAppBus sharedBus];
    id <MSService> service = [[appBus serviceContainer] objectForKey:NSStringFromProtocol(serviceProtocol)];
    if (service) return service;
    
    Class serviceClass = [[appBus serviceClasses] objectForKey:NSStringFromProtocol(serviceProtocol)];
    id serviceInstance = [[serviceClass alloc] init];
    if ([serviceInstance respondsToSelector:@selector(serviceDidInit)]) {
        [serviceInstance serviceDidInit];
    }
    [[appBus serviceContainer] setObject:serviceInstance forKey:NSStringFromProtocol(serviceProtocol)];
    return serviceInstance;
}

+ (BOOL)existService:(Protocol *)serviceProtocol
{
    NSParameterAssert(serviceProtocol != nil);
    MSAppBus *appBus = [MSAppBus sharedBus];
    id obj = [[appBus serviceContainer] objectForKey:NSStringFromProtocol(serviceProtocol)];
    return obj? YES : NO;
}

+ (Class)unit:(Protocol*)unitProtocol
{
    NSParameterAssert(unitProtocol != nil);
    if (!unitProtocol) return nil;
    MSAppBus *appBus = [MSAppBus sharedBus];
    Class <MSUnit> unitClass = [[appBus unitClasses] objectForKey:NSStringFromProtocol(unitProtocol)];
    return unitClass ? unitClass : nil;
}

+ (BOOL)existUnit:(Protocol *)unitProtocol
{
    NSParameterAssert(unitProtocol != nil);
    if (!unitProtocol) return nil;
    MSAppBus *appBus = [MSAppBus sharedBus];
    Class <MSUnit> unitClass = [[appBus unitClasses] objectForKey:NSStringFromProtocol(unitProtocol)];
    return unitClass ? YES : NO;
}

+ (void)registerUnit:(Protocol *)unitProtocol withUnitClass:(Class)implClass
{
    NSParameterAssert(unitProtocol != nil);
    NSParameterAssert(implClass != nil);
    if (!unitProtocol || !implClass) return;
    MSAppBus *appBus = [MSAppBus sharedBus];
    [[appBus unitClasses] setValue:implClass forKey:NSStringFromProtocol(unitProtocol)];
}

@end

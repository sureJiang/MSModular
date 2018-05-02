//
//  ViewController.m
//  APPBus
//
//  Created by JZJ on 2016/6/17.
//  Copyright © 2016 JZJ. All rights reserved.
//

#import "ViewController.h"
#import "MSAppBusHeader.h"

@interface ViewController ()<MSFeedServiceProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.text  = @"feed";
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.frame = CGRectMake(100, 100, 100, 50);
    [btn addTarget:self action:@selector(feed) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:25];
    [self.view addSubview:btn];
    
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.backgroundColor = [UIColor lightGrayColor];
    btn2.titleLabel.text  = @"user";
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:25];

    btn2.frame = CGRectMake(100, 200, 100, 50);
    [btn2 addTarget:self action:@selector(user) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

    
}

-(void)feed{
    
    id<MSFeedServiceProtocol>feedService = [MSAppBus service:@protocol(MSFeedServiceProtocol)];//获取模块service
    [feedService gotoFeedViewControllerWithType:MSFeedControllerTypeUser andParams:@{@"name":@"MSFeedControllerTypeUser"}];//根据模块协议跳转到具体vc
}


-(void)user{
    
    id<MSUserServiceProtocol>userService = [MSAppBus service:@protocol(MSUserServiceProtocol)];//获取模块service
    [userService gotoViewControllerWithUserViewType:MSUserViewTypeProfile andInfoParams:@{@"name":@"MSUserController"}];//根据模块协议跳转到具体vc
}

@end

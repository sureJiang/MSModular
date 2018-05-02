//
//  FeedController.m
//  APPBusDEMO
//
//  Created by JZJ on 2019/6/18.
//  Copyright © 2019 JZJ. All rights reserved.
//

#import "MSUserFeedListViewController.h"
#import "MSAppBusHeader.h"
#import "AppDelegate.h"

@interface MSUserFeedListViewController ()

@end

@implementation MSUserFeedListViewController


//动态相关goto
- (void)pushToUserFeedListViewControllerWithParam:(NSDictionary *)params{
     [[self.class appDelegate] pushViewController:self animated:YES];
    self.title = params[@"name"];
}

+ (UINavigationController*)appDelegate{
    id vc = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if(![vc isKindOfClass:[UINavigationController class]])
        return nil;
   return (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
}


@end

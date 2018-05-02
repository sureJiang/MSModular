//
//  MSUserController.m
//  APPBusDEMO
//
//  Created by JZJ on 2019/6/18.
//  Copyright © 2019 JZJ. All rights reserved.
//

#import "MSProfileUserViewController.h"

@interface MSProfileUserViewController ()

@end

@implementation MSProfileUserViewController
-(void)pushToProfileUserViewControllerWithParam:(NSDictionary*)params{
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

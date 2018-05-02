//
//  MSUnit.h
//  DEMO
//
//  Created by JZJ on 16/4/29.
//  Copyright © 2016年 JZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
@protocol MSUnit <NSObject>

@end

#pragma mark - Feed

typedef void(^FilterTitleBlock)(NSString *title);
@protocol MSNearbyFeedUnitProtocol <MSUnit>

@required
- (id)initNearbyFeedControllerWithInfoDictionary:(NSDictionary *)infoDict;
@optional
- (void)setScrollDelegate:(id)delegate;
- (void)doHandlerFeedFilterAction;

@end


@protocol MSFeedDetailUnitProtocol <MSUnit>

@required
- (NSString *)feedIdFromFeedDetailController;

@end

@protocol MSFeedBackGroundHandlerUnitProtocol <MSUnit>

@required
+ (id)sharedFeedBackGroundHandler;
@optional
- (void)initFeedBackGroundRequestStatus;

@end


#pragma mark - 群组

@protocol MSNearbyGroupsUnitProtocol <MSUnit>

- (id)initViewControllerWithFromSegment:(BOOL)fromSegment;
- (void)setScrollDelegate:(id)delegate;
- (BOOL)searchIsActive;
- (void)resignResponder;

@end

@protocol MSGroupSearchUnitProtocol <MSUnit>

- (instancetype)initGroupSearchViewController;

@end

@protocol MSContactGroupsUnitProtocol <MSUnit>

- (instancetype)initContactGroupsViewControllerIsInSegment:(BOOL)isSegment;
- (BOOL)searchIsActive;

@end

@protocol MSProfileGroupViewUnitProtocol <MSUnit>


@end

#pragma mark - 商家

@protocol MSShopProfileViewControllerUnitProtocol <MSUnit>

- (NSString *)shopUnitKeepMomoId;

@end

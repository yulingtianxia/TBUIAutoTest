//
//  TBUIAutoTest.h
//  Tribe
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const kAutoTestUIKey = @"isAutoTestUI";

@interface TBUIAutoTest : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, getter=isLongPressEnabled) BOOL longPressEnabled;
+ (instancetype)sharedInstance;

@end

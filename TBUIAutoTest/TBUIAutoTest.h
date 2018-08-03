//
//  TBUIAutoTest.h
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kAutoTestUIKey;

@interface TBUIAutoTest : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, getter=isLongPressEnabled) BOOL longPressEnabled;
+ (instancetype)sharedInstance;

@end

@interface NSObject (TBUIAutoTest)

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector;

@end

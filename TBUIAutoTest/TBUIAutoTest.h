//
//  TBUIAutoTest.h
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kAutoTestUITurnOnKey; // 是否生成 UI 标签
extern NSString * const kAutoTestUILongPressKey; // 是否开启长按弹窗显示 UI 标签

@interface TBUIAutoTest : NSObject <UIGestureRecognizerDelegate>

+ (instancetype)sharedInstance;

@end

@interface NSObject (TBUIAutoTest)

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector;

@end

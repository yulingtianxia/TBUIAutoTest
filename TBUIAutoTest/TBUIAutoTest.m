//
//  TBUIAutoTest.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBUIAutoTest.h"
#import <objc/runtime.h>

NSString * const kAutoTestUITurnOnKey = @"kAutoTestUITurnOnKey";
NSString * const kAutoTestUILongPressKey = @"kAutoTestUILongPressKey";

@implementation TBUIAutoTest

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TBUIAutoTest *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [TBUIAutoTest new];
    });
    return _instance;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isDescendantOfView:gestureRecognizer.view]) {
        return YES;
    }
    if (![otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSObject (TBUIAutoTest)

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

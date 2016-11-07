//
//  TBUIAutoTest.m
//  Tribe
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBUIAutoTest.h"

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

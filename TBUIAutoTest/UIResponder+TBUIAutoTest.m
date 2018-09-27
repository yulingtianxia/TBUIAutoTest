//
//  UIResponder+TBUIAutoTest.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/3.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIResponder+TBUIAutoTest.h"
#import <objc/runtime.h>

@implementation UIResponder (TBUIAutoTest)

- (NSString *)nameWithInstance:(id)instance
{
    unsigned int numIvars = 0;
    NSString *key = nil;
    Ivar *ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        void *val = ((void *(*)(id, Ivar))object_getIvar)(self, thisIvar);
        if (val == (__bridge void *)(instance)) {//此处 crash 不要慌！
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

- (NSString *)findNameWithInstance:(UIView *)instance
{
    id nextResponder = [self nextResponder];
    NSString *name = [self nameWithInstance:instance];
    if (!name) {
        return [nextResponder findNameWithInstance:instance];
    }
    if ([name hasPrefix:@"_"]) {  //去掉变量名的下划线前缀
        name = [name substringFromIndex:1];
    }
    return name;
}

@end

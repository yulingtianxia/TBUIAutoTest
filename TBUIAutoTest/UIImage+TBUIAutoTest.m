//
//  UIImage+TBUIAutoTest.m
//  Tribe
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIImage+TBUIAutoTest.h"
#import <objc/runtime.h>
#import "TBUIAutoTest.h"

@implementation UIImage (TBUIAutoTest)
+ (void)load
{
    
#if DEBUG
    BOOL isAutoTestUI = NO;
    
#if (TARGET_IPHONE_SIMULATOR)
    // 为保证不影响其它开发，在模拟器情况下只能自己手动打开这个自动化选项
    isAutoTestUI = [[[NSUserDefaults standardUserDefaults] objectForKey:kAutoTestUIKey] boolValue];
#else
    // 在自动化测试时无法通过脚本来打开这个选项，所以只能在真机下的debug版默认打开
    isAutoTestUI = YES;
#endif
    
    if (isAutoTestUI)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class aClass = object_getClass((id)self);
            
            SEL originalSelector = @selector(imageNamed:);
            SEL swizzledSelector = @selector(tb_imageNamed:);
            
            Method originalMethod = class_getClassMethod(aClass, originalSelector);
            Method swizzledMethod = class_getClassMethod(aClass, swizzledSelector);
            
            BOOL didAddMethod =
            class_addMethod(aClass,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(aClass,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        });
    }
    
#endif
}

#pragma mark - Method Swizzling

+ (UIImage *)tb_imageNamed:(NSString *)imageName{
    UIImage *image = [UIImage tb_imageNamed:imageName];
    image.accessibilityIdentifier = imageName;
    return image;
}
@end

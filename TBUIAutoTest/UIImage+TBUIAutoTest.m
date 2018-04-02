//
//  UIImage+TBUIAutoTest.m
//  Tribe
//
//  Created by 杨萧玉 on 16/3/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIImage+TBUIAutoTest.h"
#import "TBUIAutoTest.h"
#import <objc/runtime.h>

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
            [object_getClass(self) swizzleSelector:@selector(imageNamed:) withAnotherSelector:@selector(tb_imageNamed:)];
            [object_getClass(self) swizzleSelector:@selector(imageWithContentsOfFile:) withAnotherSelector:@selector(tb_imageWithContentsOfFile:)];
            [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(tb_accessibilityIdentifier)];
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

+ (UIImage *)tb_imageWithContentsOfFile:(NSString *)path
{
    UIImage *image = [UIImage tb_imageWithContentsOfFile:path];
    NSArray *components = [path pathComponents];
    if (components.count > 0) {
        image.accessibilityIdentifier = components.lastObject;
    }
    else {
        image.accessibilityIdentifier = path;
    }
    return image;
}

- (id)assetName {return nil;}

- (NSString *)tb_accessibilityIdentifier {
    NSString *tb_accessibilityIdentifier = [self tb_accessibilityIdentifier];
    if (tb_accessibilityIdentifier.length == 0 && [self respondsToSelector:@selector(imageAsset)]) {
        tb_accessibilityIdentifier = [(id)self.imageAsset assetName];
        self.accessibilityIdentifier = tb_accessibilityIdentifier;
    }
    
    return tb_accessibilityIdentifier;
}

@end

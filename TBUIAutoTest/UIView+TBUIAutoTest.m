//
//  UIView+TBUIAutoTest.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/3.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIView+TBUIAutoTest.h"
#import "UIResponder+TBUIAutoTest.h"
#import "TBUIAutoTest.h"
#import <objc/runtime.h>

#define kiOS8Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation UIView (TBUIAutoTest)
+ (void)load
{
    BOOL isAutoTestUI = [NSUserDefaults.standardUserDefaults boolForKey:kAutoTestUIKey];
    if (isAutoTestUI)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(tb_accessibilityIdentifier)];
            [self swizzleSelector:@selector(accessibilityLabel) withAnotherSelector:@selector(tb_accessibilityLabel)];
            if ([TBUIAutoTest sharedInstance].isLongPressEnabled) {
                [self swizzleSelector:@selector(addSubview:) withAnotherSelector:@selector(tb_addSubview:)];
            }
        });
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (kiOS8Later) {
            CGFloat previousWidth = self.layer.borderWidth;
            CGColorRef previousColor =  self.layer.borderColor;
            self.layer.borderWidth = 3;
            self.layer.borderColor = [UIColor redColor].CGColor;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自动化测试Label" message:self.accessibilityIdentifier preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.layer.borderWidth = previousWidth;
                self.layer.borderColor = previousColor;
            }];
            [alert addAction:confirmAction];
            [[self viewController] presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Method Swizzling

- (NSString *)tb_accessibilityIdentifier
{
    NSString *accessibilityIdentifier = [self tb_accessibilityIdentifier];
    if (accessibilityIdentifier.length > 0 && [[accessibilityIdentifier substringToIndex:1] isEqualToString:@"("]) {
        return accessibilityIdentifier;
    }
    else if ([accessibilityIdentifier isEqualToString:@"null"]) {
        accessibilityIdentifier = @"";
    }
    
    NSString *labelStr = [self.superview findNameWithInstance:self];
    
    if (labelStr && ![labelStr isEqualToString:@""]) {
        labelStr = [NSString stringWithFormat:@"(%@)",labelStr];
    }
    else {
        if ([self isKindOfClass:[UILabel class]]) {//UILabel 使用 text
            labelStr = [NSString stringWithFormat:@"(%@)",((UILabel *)self).text?:@""];
        }
        else if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 使用 image 的 imageName
            labelStr = [NSString stringWithFormat:@"(%@)",((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
        else if ([self isKindOfClass:[UIButton class]]) {//UIButton 使用 button 的 text 和 image
            labelStr = [NSString stringWithFormat:@"(%@%@)",((UIButton *)self).titleLabel.text?:@"",((UIButton *)self).imageView.image.accessibilityIdentifier?:@""];
        }
        else if (accessibilityIdentifier) {// 已有 label，则在此基础上再次添加更多信息
            labelStr = [NSString stringWithFormat:@"(%@)",accessibilityIdentifier];
        }
        if ([self isKindOfClass:[UIButton class]]) {
            self.accessibilityValue = [NSString stringWithFormat:@"(%@)",((UIButton *)self).currentBackgroundImage.accessibilityIdentifier?:@""];
        }
    }
    if ([labelStr isEqualToString:@"()"] || [labelStr isEqualToString:@"(null)"] || [labelStr isEqualToString:@"null"]) {
        labelStr = @"";
    }
    [self setAccessibilityIdentifier:labelStr];
    return labelStr;
}

- (NSString *)tb_accessibilityLabel
{
    if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 特殊处理
        NSString *name = [self.superview findNameWithInstance:self];
        if (name) {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@)",name];
        }
        else {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@)",((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
    }
    if ([self isKindOfClass:[UITableViewCell class]]) {//UITableViewCell 特殊处理
        UIView *view = [self superview];
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        UITableView *tableView = (UITableView *)view;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)self];
        self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@-%ld.%ld)", ((UITableViewCell *)self).reuseIdentifier, (long)indexPath.section, (long)indexPath.row];
    }
    if ([self isKindOfClass:[UICollectionViewCell class]]) {//UICollectionViewCell 特殊处理
        UIView *view = [self superview];
        while (view && [view isKindOfClass:[UICollectionView class]] == NO) {
            view = [view superview];
        }
        UICollectionView *collectionView = (UICollectionView *)view;
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)self];
        self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@-%ld.%ld)", ((UICollectionViewCell *)self).reuseIdentifier, (long)indexPath.section, (long)indexPath.row];
    }
    return [self tb_accessibilityLabel];
}

- (void)tb_addSubview:(UIView *)view {
    if (!view) {
        return;
    }
    [self tb_addSubview:view];
    UILongPressGestureRecognizer *longPress = objc_getAssociatedObject(view, _cmd);
    if (!longPress) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(longPress:)];
        longPress.delegate = [TBUIAutoTest sharedInstance];
        [view addGestureRecognizer:longPress];
        objc_setAssociatedObject(view, _cmd, longPress, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIViewController*)viewController {
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end

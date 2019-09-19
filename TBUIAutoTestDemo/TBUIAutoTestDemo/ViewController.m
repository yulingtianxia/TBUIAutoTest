//
//  ViewController.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 2016/11/7.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *testLabel;

@end

@implementation ViewController

+ (void)load
{
    extern NSString * const kAutoTestUITurnOnKey;
    extern NSString * const kAutoTestUILongPressKey;
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kAutoTestUITurnOnKey];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kAutoTestUILongPressKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.testLabel = [[UILabel alloc] init];
    self.testLabel.textColor = [UIColor blackColor];
    self.testLabel.text = @"测试";
    [self.testLabel sizeToFit];
    self.testLabel.center = (CGPoint){self.view.bounds.size.width / 2, self.view.bounds.size.height / 2};
    self.testLabel.isAccessibilityElement = YES;
    [self.view addSubview:self.testLabel];
    self.testLabel.userInteractionEnabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

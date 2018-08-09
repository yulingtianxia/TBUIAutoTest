//
//  ViewController.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 2016/11/7.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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
    
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.textColor = [UIColor blackColor];
    testLabel.text = @"测试";
    [testLabel sizeToFit];
    testLabel.center = (CGPoint){self.view.bounds.size.width/2, self.view.bounds.size.height/2};
    [self.view addSubview:testLabel];
    testLabel.userInteractionEnabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

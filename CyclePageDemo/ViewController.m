//
//  ViewController.m
//  CyclePageDemo
//
//  Created by 高洋 on 16/9/1.
//  Copyright © 2016年 高洋. All rights reserved.
//

#import "ViewController.h"
#import "GYCyclePageView.h"

@interface ViewController () <GYCyclePageViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    GYCyclePageView *cyclyPageView = [[GYCyclePageView alloc] initWithFrame:CGRectMake(10, 30, 300, 130)];
    GYCyclePageView *cyclyPageView = [GYCyclePageView cyclePageView];
    cyclyPageView.frame = CGRectMake(10, 30, 300, 130);
    [self.view addSubview:cyclyPageView];
    cyclyPageView.delegate = self;
    cyclyPageView.pictures = @[ @"img_00", @"img_01"/*, @"img_02", @"img_03", @"img_04",*/ ];
}
- (void)cyclePageView:(GYCyclePageView *)cyclePageView didTapedPage:(UIImageView *)imgView atIndex:(NSUInteger)index
{
    NSLog(@"%s  -  %ld", __func__, index);
}

@end

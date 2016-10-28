//
//  ViewController.m
//  CyclePageDemo
//
//  Created by 高洋 on 16/9/1.
//  Copyright © 2016年 高洋. All rights reserved.
//

#import "ViewController.h"
#import "GYCyclePageView.h"

#define SCREENWIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREENHEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREENSCALEX (SCREENWIDTH / 320)
#define SCREENSCALEY (SCREENHEIGHT / 568)

@interface ViewController () <GYCyclePageViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    GYCyclePageView *cyclyPageView = [[GYCyclePageView alloc] initWithFrame:CGRectMake(10, 30, 300, 130)];
    // 使用方法
    GYCyclePageView *cyclyPageView = [GYCyclePageView cyclePageView];
    cyclyPageView.frame = CGRectMake(10, 30, SCREENWIDTH - 20, 130 * SCREENSCALEY);
    [self.view addSubview:cyclyPageView];
    cyclyPageView.delegate = self;
    cyclyPageView.pictures = @[ @"img_00", @"img_01", @"img_02",
                                @"http://img05.tooopen.com/images/20140919/sy_71272488121.jpg", @"img_03", @"img_04", ];
    // 建议动画持续时间小于每张图片的停留时间
    cyclyPageView.durTimeInterval = 1.;
    cyclyPageView.stayTimeInterval = 4.;
}
- (void)cyclePageView:(GYCyclePageView *)cyclePageView didTapedPage:(UIImageView *)imgView atIndex:(NSUInteger)index
{
    NSLog(@"%s  -  %ld", __func__, index);
}

@end

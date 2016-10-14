//
//  GYCyclePageView.h
//  ApplicationDemo
//
//  Created by 高洋 on 16/9/1.
//  Copyright © 2016年 高洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GYCyclePageView;
@protocol GYCyclePageViewDelegate;


/**!!!!!!!!!!
 *  实例化该控件后，请设置要显示的图片数组,属性名为 pictures
 */


@interface GYCyclePageView : UIView
/** 每张图片的停留时间, 默认3秒*/
@property (nonatomic, assign) NSTimeInterval stayTimeInterval;
/** 图片的切换动画持续时间，默认0.3秒*/
@property (nonatomic, assign) NSTimeInterval durTimeInterval;

/** 需要显示的图片数组*/
@property (nonatomic, strong) NSArray *pictures;

/** pageControl*/
@property (nonatomic, strong) UIPageControl *pageControl;

/** 控件代理对象,主要负责响应点击图片操作*/
@property (nonatomic, weak) id<GYCyclePageViewDelegate> delegate;

/** 便捷方法*/
+ (instancetype)cyclePageView;

/**
 开始循环播放图片
 */
- (void)startPlay;

/**
 结束循环播放
 */
- (void)stopPlay;

@end

// 制定协议
@protocol GYCyclePageViewDelegate <NSObject>

@optional
/**
 *  响应图片的点击
 *
 *  @param cyclePageView 当前主控件
 *  @param imgView       点击的UIImageView对象
 *  @param index         图片的索引
 */
- (void)cyclePageView:(GYCyclePageView *)cyclePageView didTapedPage:(UIImageView *)imgView atIndex:(NSUInteger)index;

@end

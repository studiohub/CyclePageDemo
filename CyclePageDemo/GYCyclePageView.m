//
//  GYCyclePageView.m
//  ApplicationDemo
//
//  Created by 高洋 on 16/9/1.
//  Copyright © 2016年 高洋. All rights reserved.
//

#import "GYCyclePageView.h"
/**
 * 分析：
 * 1. 整体是在scrollView上控制滚动。
 * 2. 图片数量是自定义
 * 3. 初始化时，加载设置默认的属性值
 * 4. 获取到图片数据时，填充内容
 * 5. 父控件布局完成后才能对内部内容布局
 *
 * 难点：
 * 1. scrollview内部图片视图的定位
 * 2. UIImageView用户交互开关
 * 3. 图片的切换
 */

#pragma mark -
#pragma mark - UIImageView
@interface UIImageView (AsynSetImage)
- (void)asynSetImage:(NSString *)imagePath;
@end
@implementation UIImageView (AsynSetImage)

/**
 优化图片设置
 */
- (void)asynSetImage:(NSString *)imagePath
{
    if (imagePath == nil || imagePath.length == 0)
    {
        // 这里可以设置站位图片
        return;
    }
    // 网络地址,或沙盒路径URL
    if ([imagePath containsString:@"http"] || [imagePath containsString:@"file://"])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImage:image];
                });
            }
        });
        return;
    }

    UIImage *image = [UIImage imageNamed:imagePath];
    if (image)
    {
        [self setImage:image];
    }
}

@end

#pragma mark -
#pragma mark - GYCyclePageView
@interface GYCyclePageView () <UIScrollViewDelegate>

/** scrollView盒子控件*/
@property (nonatomic, strong) UIScrollView *boxSV;
/** 保存UIImageView的数组*/
@property (nonatomic, strong) NSMutableArray *imgViews;
/** 当前页索引*/
@property (nonatomic, assign) NSUInteger curIndex;
/** 定时器*/
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GYCyclePageView


+ (instancetype)cyclePageView
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // 设定相关时间间隔
        _stayTimeInterval = 3;
        _durTimeInterval = 0.3;
    }
    return self;
}

/**
 *  布局子控件
 */
- (void)layoutSubviews
{
    // 设置scrollView和父控件同样大小
    _boxSV.frame = self.bounds;
    
    // 布局内部图片
    NSUInteger imgViewCount = _imgViews.count;
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    for (int i = 0; i < imgViewCount; ++i)
    {
        UIImageView *view = _imgViews[i];
        view.frame = CGRectMake(i * viewW, 0, viewW, viewH);
        view = nil;
    }
    
    CGFloat pcW = imgViewCount * 15;
    CGFloat pcH = 15;
    CGFloat offsetX = 10;
    _pageControl.frame = CGRectMake(viewW - pcW - offsetX, viewH - pcH, pcW, pcH);
}
- (void)dealloc
{
    [self stopTimer];
}
#pragma mark - 加载组件
/**
 *  加载scrollView内部的图片
 */
- (void)loadImg
{
    // 移除之前的视图
    [_boxSV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_imgViews removeAllObjects];
    
    NSUInteger picCount = _pictures.count;
    for (int i = 0; i < picCount; ++i)
    {
        // 创建UIImageView
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.userInteractionEnabled = YES;
        [self.imgViews addObject:imgV];
        [self.boxSV addSubview:imgV];
        
        // 创建手势识别，为每一个ImageView添加手势
        UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPageTaped:)];
        [imgV addGestureRecognizer:rec];
        
        // 设置图片
        [imgV asynSetImage:_pictures[i]];
    }
    
    // 设置scrollview的contentsize, 支持横向滑动
    _boxSV.contentSize = CGSizeMake(self.frame.size.width * picCount, 0);
}

- (void)loadPageControl
{
    self.pageControl.numberOfPages = _pictures.count;
    if (_pictures.count <= 1)
    {
        self.pageControl.hidden = YES;
    }
}

#pragma mark - tools
/**
 *  手势的响应方法，调用代理对象的方法
 *
 *  @param gestureRec UIImageView的手势
 */
- (void)onPageTaped:(UITapGestureRecognizer *)gestureRec
{
    if ([self.delegate respondsToSelector:@selector(cyclePageView:didTapedPage:atIndex:)])
    {
        NSUInteger index = [self currentPageIndex];
        [self.delegate cyclePageView:self didTapedPage:_imgViews[index] atIndex:index];
    }
}

/**
 *  获取当前页的索引
 *
 *  @return 索引值
 */
- (NSUInteger)currentPageIndex
{
//    CGFloat offsetX = _boxSV.contentOffset.x;
//    return offsetX / _boxSV.frame.size.width;
    return _curIndex;
}
/**
 *  设定定时器，使图片在指定时间切换
 */
- (void)initTimer
{
    if (_pictures.count > 1)
    {
        [self startTimerWithTimeInterval:self.stayTimeInterval];
    }
}

/**
 *  启动定时器
 */
- (void)startTimerWithTimeInterval:(NSTimeInterval)timeInterval
{
    if (!_timer.isValid)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

/**
 *  停止定时器
 */
- (void)stopTimer
{
    if (_timer.isValid)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

/**
 *  切换到下一个图片
 */
- (void)nextPage
{
    _curIndex ++;
    if (_curIndex == _pictures.count)
    {
        _curIndex = 0;
    }
    [UIView animateWithDuration:_durTimeInterval animations:^{
        _boxSV.contentOffset = CGPointMake(_boxSV.frame.size.width * _curIndex, 0);
        _pageControl.currentPage = _curIndex;
    }];
}

/**
 手动拖拽，进行页面切换
 */
- (void)nextPageByhand
{
    int index = self.boxSV.contentOffset.x / self.boxSV.frame.size.width;
    self.curIndex = index;
    [UIView animateWithDuration:self.durTimeInterval animations:^{
        [self.pageControl setCurrentPage:index];
    }];
}
/**
 开始循环播放图片
 */
- (void)startPlay
{
    [self startTimerWithTimeInterval:self.stayTimeInterval];
}

/**
 结束循环播放
 */
- (void)stopPlay
{
    [self stopTimer];
}
#pragma mark - setter
/**
 *  重写了pictures数组的set方法，根据图片数量，创建UIImageView，并加入到scrollView上
 *
 *  @param pictures 需要显示的图片数组
 */
- (void)setPictures:(NSArray *)pictures
{
    // 保存图片数组
    if (_pictures != pictures)
    {
        _pictures = pictures;
    }
    
    if (_pictures.count > 0)
    {
        // 加载图片部分
        [self loadImg];
        
        // 加载pageControl
        [self loadPageControl];
        
        // 启动定时器
        [self initTimer];
    }
}

- (void)setStayTimeInterval:(NSTimeInterval)stayTimeInterval
{
    _stayTimeInterval = stayTimeInterval;
    [self stopTimer];
    [self startTimerWithTimeInterval:stayTimeInterval];
}
#pragma mark - getter懒加载
/**
 *  懒加载scrollview
 *
 */
- (UIScrollView *)boxSV
{
    if (_boxSV == nil)
    {
        // 实例化scrollView
        _boxSV = [[UIScrollView alloc] init];
        [self addSubview:_boxSV];
        
        // 设置scrollView
        _boxSV.pagingEnabled = YES;
        _boxSV.showsVerticalScrollIndicator = NO;
        _boxSV.showsHorizontalScrollIndicator = NO;
        
        // 设置代理
        _boxSV.delegate = self;
    }
    return _boxSV;
}

/**
 *  懒加载pageControl
 *
 */
- (UIPageControl *)pageControl
{
    if (_pageControl == nil)
    {
        // 初始化当前页索引为0
        _curIndex = 0;
        
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_pageControl];
        _pageControl.pageIndicatorTintColor = [UIColor blueColor];
    }
    return _pageControl;
}

/**
 *  懒加载UIImageView数组
 *
 *  @return 用于保存所有图片控件的数组
 */
- (NSMutableArray *)imgViews
{
    if (_imgViews == nil)
    {
        _imgViews = [NSMutableArray array];
    }
    return _imgViews;
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self nextPageByhand];
    [self startTimerWithTimeInterval:self.stayTimeInterval];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self stopTimer];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self nextPageByhand];
    [self startTimerWithTimeInterval:self.stayTimeInterval];
}
@end

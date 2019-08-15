//
//  SFAmericanController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/7.
//  Copyright © 2019 随风流年. All rights reserved.
//


#import "SFAmericanController.h"
#import "SPPageMenu.h"
#import "SFHeaderView.h"
#import "SGScreenTool.h"

#import "SFAmericanFirstController.h"
#import "SFAmericanSecondController.h"
#import "SFAmericanThirdController.h"
#import "SFAmericanFourController.h"

#import "UINavigationController+Alpha.h"

#define kHeaderViewH 200
#define kPageMenuH 40
#define kNavH ([SGScreenTool isPhoneX] ? 84 : 64)


@interface SFAmericanController ()<SPPageMenuDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SFHeaderView  *headerView;
@property (nonatomic, strong) SPPageMenu    *pageMenu;

@property (nonatomic, assign) CGFloat       lastPageMenuY;
@property (nonatomic, assign) CGPoint       lastPoint;

@end

@implementation SFAmericanController
- (void)leftItmeClick:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"仿美团";
    if (@available(iOS 11.0,*)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navAlpha = 1;
    self.navTitleColor = [UIColor greenColor];//标题的颜色
    self.navBarTintColor = [UIColor redColor];//导航栏的背景色

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftItmeClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.lastPageMenuY = kHeaderViewH;
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.pageMenu];
    
    [self addChildViewController:[SFAmericanFirstController new]];
    [self addChildViewController:[SFAmericanSecondController new]];
    [self addChildViewController:[SFAmericanThirdController new]];
    [self addChildViewController:[SFAmericanFourController new]];
    [self.scrollView addSubview:self.childViewControllers.firstObject.view];
    
    // 监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subScrollViewDidScroll:) name:ChildScrollViewDidScrollNSNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshState:) name:ChildScrollViewRefreshStateNSNotification object:nil];
}
#pragma mark - 通知

// 子控制器上的scrollView已经滑动的代理方法所发出的通知(核心)
- (void)subScrollViewDidScroll:(NSNotification *)noti {
    // 取出当前正在滑动的tableView
    UIScrollView *scrollingScrollView = noti.userInfo[@"scrollingScrollView"];
    CGFloat offsetDifference = [noti.userInfo[@"offsetDifference"] floatValue];
    
    CGFloat distanceY;
    
    // 取出的scrollingScrollView并非是唯一的，当有多个子控制器上的scrollView同时滑动时都会发出通知来到这个方法，所以要过滤
    SFAmericanBaseController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    
    if (scrollingScrollView == baseVc.scrollView && baseVc.isFirstViewLoaded == NO) {
        
        // 让分页菜单跟随scrollView滑动
        CGRect pageMenuFrame = self.pageMenu.frame;
        
        if (pageMenuFrame.origin.y >= Height_NavBar) {
            // 往上移
            if (offsetDifference > 0 && scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset > 0) {
                if(((scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset+self.pageMenu.frame.origin.y)>=kHeaderViewH) || scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset < 0) {
                    // 分页菜单的y值等于当前正在滑动且显示在屏幕范围内的的scrollView的contentOffset.y的改变量(这是最难的点)
                    pageMenuFrame.origin.y += -offsetDifference;
                    if (pageMenuFrame.origin.y <= Height_NavBar) {
                        pageMenuFrame.origin.y = Height_NavBar;
                    }
                }
            } else { // 往下移
                if ((scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset+self.pageMenu.frame.origin.y)<kHeaderViewH) {
                    pageMenuFrame.origin.y = -scrollingScrollView.contentOffset.y-kScrollViewBeginTopInset+kHeaderViewH;
                    if (pageMenuFrame.origin.y > kHeaderViewH) {
                        pageMenuFrame.origin.y = kHeaderViewH;
                    }
                }
            }
        }
        self.pageMenu.frame = pageMenuFrame;
        
        CGRect headerFrame = self.headerView.frame;
        headerFrame.origin.y = self.pageMenu.frame.origin.y-kHeaderViewH;
        self.headerView.frame = headerFrame;
        
        // 记录分页菜单的y值改变量
        distanceY = pageMenuFrame.origin.y - self.lastPageMenuY;
        self.lastPageMenuY = self.pageMenu.frame.origin.y;
        
        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
        [self followScrollingScrollView:scrollingScrollView distanceY:distanceY];
        
        [self changeColorWithOffsetY:-self.pageMenu.frame.origin.y+kHeaderViewH];
    }
    baseVc.isFirstViewLoaded = NO;
}
- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView distanceY:(CGFloat)distanceY{
    SFAmericanBaseController *baseVC = nil;
    for (int i = 0; i< self.childViewControllers.count; i ++) {
        baseVC = self.childViewControllers[i];
        if (baseVC.scrollView == scrollingScrollView) {
            continue;
        }else{
            CGPoint contentOffSet = baseVC.scrollView.contentOffset;
            contentOffSet.y += -distanceY;
            baseVC.scrollView.contentOffset = contentOffSet;//设置其他控制器的table同上上移或者下移
        }
    }
}
#pragma mark -- 修改导航栏的颜色 ---
- (void)changeColorWithOffsetY:(CGFloat)offsetY{
    if (offsetY >= 0) {
        CGFloat alpha = (offsetY)/(HeaderViewH - Height_NavBar);
        self.navAlpha = alpha;
        self.navTitleColor = [UIColor colorWithWhite:0 alpha:alpha];
    }else{//向下移动
        self.navAlpha = 1;
        self.navBarTintColor = [UIColor purpleColor];
    }
}
- (void)refreshState:(NSNotification *)noti {
    BOOL state = [noti.userInfo[@"isRefreshing"] boolValue];
    // 正在刷新时禁止self.scrollView滑动
    self.scrollView.scrollEnabled = !state;
}
#pragma mark --- 头部视图的滑动手势 ---
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        CGPoint currentPoint = [pan translationInView:pan.view];
        CGFloat distanceY = currentPoint.y - self.lastPoint.y;
        NSLog(@"distancY:%f--currentPoint:%@----self.lastPoint:%@",distanceY,NSStringFromCGPoint(currentPoint) ,NSStringFromCGPoint(self.lastPoint));
        self.lastPoint = currentPoint;
        
        SFAmericanBaseController *baseVC = self.childViewControllers[self.pageMenu.selectedItemIndex];
        CGPoint offset = baseVC.scrollView.contentOffset;
        offset.y += -distanceY;
        if (offset.y <= -kScrollViewBeginTopInset) {
            offset.y = - kScrollViewBeginTopInset;
        }
        baseVC.scrollView.contentOffset = offset;
        
    }else{
        [pan setTranslation:CGPointZero inView:pan.view];
        self.lastPoint = CGPointZero;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    SFAmericanBaseController *baseVC = self.childViewControllers[self.pageMenu.selectedItemIndex];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (baseVC.scrollView.contentSize.height < SCREEN_HEIGHT && [baseVC isViewLoaded]) {
            [baseVC.scrollView setContentOffset:CGPointMake(0, -kScrollViewBeginTopInset) animated:YES];
        }
    });
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    SFAmericanBaseController *baseVC = self.childViewControllers[self.pageMenu.selectedItemIndex];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (baseVC.scrollView.contentSize.height < SCREEN_HEIGHT && [baseVC isViewLoaded]) {
            [baseVC.scrollView setContentOffset:CGPointMake(0, -kScrollViewBeginTopInset) animated:YES];
        }
    });
}
#pragma mark -- SPPageMenuDelegate ---
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (!self.childViewControllers.count) {return;}
    //如果上一次点击的button下标与当前点击button的下标之差大于等于2，说明跨界面移动了，此时不动画
    if (labs(toIndex - fromIndex) >= 2 ) {
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:NO];
    }else{
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex,0) animated:YES];
    }
    SFAmericanBaseController *targetViewController = self.childViewControllers[toIndex];
    //如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) {return;}
    //来到这里必然是第一次加载控制器的view，这个属性是为了防止下面的偏移量的改变导致走scrolllViewDidScroll
    targetViewController.isFirstViewLoaded = YES;
    targetViewController.view.frame = CGRectMake(SCREEN_WIDTH * toIndex, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIScrollView *s = targetViewController.scrollView;
    CGPoint contentOffset = s.contentOffset;
    NSLog(@"self.headerView.frame.origin.y:%f",self.headerView.frame.origin.y);
    contentOffset.y = - self.headerView.frame.origin.y - kScrollViewBeginTopInset;
    NSLog(@"contentOffset.y:%f",contentOffset.y);
    if (contentOffset.y + kScrollViewBeginTopInset >= kHeaderViewH) {
        contentOffset.y = kHeaderViewH + kScrollViewBeginTopInset;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}
#pragma mark --- lazy ---
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - BottomMargin);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *4, 0);
        _scrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _scrollView;
}
- (SFHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SFHeaderView alloc]init];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HeaderViewH);
        _headerView.backgroundColor = [UIColor purpleColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [_headerView addGestureRecognizer:pan];
    }
    return _headerView;
}
- (SPPageMenu *)pageMenu{
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), SCREEN_WIDTH, kPageMenuH) trackerStyle:SPPageMenuTrackerStyleLineLongerThanItem];
        [_pageMenu setItems:@[@"第一页",@"第二页",@"第三页",@"第四页"] selectedItemIndex:0];
        _pageMenu.delegate = self;
        _pageMenu.itemTitleFont = [UIFont systemFontOfSize:16];
        _pageMenu.selectedItemTitleColor = [UIColor blackColor];
        _pageMenu.unSelectedItemTitleColor = [UIColor colorWithWhite:0 alpha:0.6];
        _pageMenu.tracker.backgroundColor = [UIColor orangeColor];
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
        _pageMenu.bridgeScrollView = self.scrollView;
        
    }
    return _pageMenu;
}
@end

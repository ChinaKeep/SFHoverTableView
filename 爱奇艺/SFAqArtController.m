//
//  SFAqArtController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/12.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFAqArtController.h"
#import "SFHeaderView.h"
#import "SPPageMenu.h"

#import "SFArtFirstController.h"
#import "SFArtSecondController.h"
#import "SFArtThirdController.h"
#import "SFArtFourController.h"

@interface SFAqArtController ()<SPPageMenuDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SFHeaderView *headerView;
@property (nonatomic, strong) SPPageMenu   *pageMenu;
@property (nonatomic, assign) CGFloat lastPageMenuY;
@property (nonatomic, assign) CGFloat lastPoint;

@end

@implementation SFAqArtController
- (void)leftItmeClick:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"爱奇艺";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftItmeClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.lastPageMenuY = HeaderViewH;
    // 添加一个全屏的scrollView
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageMenu];
    SFArtFirstController *firstVC = [[SFArtFirstController alloc]init];
    [self addChildViewController:firstVC];
    firstVC.headerView = self.headerView;
    
    [self addChildViewController:[[SFArtSecondController alloc]init]];
    [self addChildViewController:[[SFArtThirdController alloc]init]];
    [self addChildViewController:[[SFArtFourController alloc]init]];
    
    [self.scrollView addSubview:self.childViewControllers[0].view];
    //监听子控制器中scrollView正在滑动所发出的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subScrollViewDidScroll:) name:ArtChildScrollViewDidScrollNSNotification object:nil];
}
#pragma mark -- ArtChildScrollViewDidScrollNSNotification --
- (void)subScrollViewDidScroll:(NSNotification *)noti{
   
    // 取出当前正在滑动的tableView
    UIScrollView *scrollingScrollView = noti.userInfo[@"scrollingScrollView"];
    CGFloat offsetDifference = [noti.userInfo[@"offsetDifference"] floatValue];
    
    CGFloat distanceY;
    
    SFAqArtBaseController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    
    // 取出的scrollingScrollView并非是唯一的，当有多个子控制器上的scrollView同时滑动时都会发出通知来到这个方法，所以要过滤
    if (scrollingScrollView == baseVc.scrollView && baseVc.isFirstViewLoaded == NO) {
        // 让分页菜单跟随scrollView滑动
        CGRect pageMenuFrame = self.pageMenu.frame;
        
        if (pageMenuFrame.origin.y >= 0) {
            // 往上滑
            if (offsetDifference > 0) {
                NSLog(@"往上上上滑---:%.1f===%.1f"
                      ,scrollingScrollView.contentOffset.y
                      ,self.pageMenu.frame.origin.y);

                if (((scrollingScrollView.contentOffset.y+self.pageMenu.frame.origin.y)>=HeaderViewH) || scrollingScrollView.contentOffset.y < 0) {
                    // 分页菜单的y值等于当前正在滑动且显示在屏幕范围内的的scrollView的contentOffset.y的改变量(这是最难的点)
                    pageMenuFrame.origin.y += -offsetDifference;
                    if (pageMenuFrame.origin.y <= 0) {
                        pageMenuFrame.origin.y = 0;
                    }
                    
                }
            } else { // 往下滑
                NSLog(@"往下滑---:%.1f===%.1f"
                      ,scrollingScrollView.contentOffset.y
                      ,self.pageMenu.frame.origin.y);
                
                if ((scrollingScrollView.contentOffset.y+self.pageMenu.frame.origin.y)-0<HeaderViewH) {
                    pageMenuFrame.origin.y = -scrollingScrollView.contentOffset.y+HeaderViewH+0;
                }
            }
        }
        self.pageMenu.frame = pageMenuFrame;
        
        // 配置头视图的y值
        [self adjustHeaderY];
        
        // 记录分页菜单的y值改变量
        NSLog(@"分页菜单改变之前：%f===:%f===%.1f",pageMenuFrame.origin.y,self.lastPageMenuY,self.pageMenu.frame.origin.y);
        distanceY = pageMenuFrame.origin.y - self.lastPageMenuY;
        self.lastPageMenuY = self.pageMenu.frame.origin.y;
        NSLog(@"分页菜单改变之后之后之后：%f",self.lastPageMenuY);

        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
        [self followScrollingScrollView:scrollingScrollView distanceY:distanceY];
        
    }
    baseVc.isFirstViewLoaded = NO;
}
//所有子控制器上特定的scrollView同时联动
- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView distanceY:(CGFloat)distanceY{
    SFAqArtBaseController *baseVC = nil;
    for (int i = 0; i<self.childViewControllers.count; i++) {
        baseVC = self.childViewControllers[i];
        if (baseVC.scrollView == scrollingScrollView) {
            continue;
        }else{
            //除去当前正在滑动的scrollView外，其余scrollView的改变量等于分页菜单的改变量
            CGPoint contentOffSet = baseVC.scrollView.contentOffset;
            contentOffSet.y += - distanceY;
            baseVC.scrollView.contentOffset = contentOffSet;
        }
    }
}
#pragma mark - SPPageMenuDelegate -
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (!self.childViewControllers.count) {return;}
    //如果上一次点击的button下标与当前点击的button的下标之差大于等于2，说明跨界面移动了，此时不动画
    if (labs(toIndex - fromIndex) >= 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(self->_scrollView.frame.size.width * toIndex, 0) animated:NO];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(self->_scrollView.frame.size.width * toIndex, 0) animated:YES];
        });
    }
    SFAqArtBaseController *targetViewController = self.childViewControllers[toIndex];
    if (self.scrollView.dragging || self.scrollView.decelerating || self.scrollView.contentOffset.x / SCREEN_WIDTH == self.pageMenu.selectedItemIndex) {
        // 1. 切换headerView的父视图 2.将headerView的x、y值都归0
        targetViewController.headerView = self.headerView;
    }
    if ([targetViewController isViewLoaded]) {
        return;//如果已经加载过，就不再加载
    }
    //是第一次加载控制器的View，这个属性是为了防止下面的偏移量的改变导致scrollViewDidScroll
    targetViewController.isFirstViewLoaded = YES;
    targetViewController.view.frame = CGRectMake(SCREEN_WIDTH * toIndex, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIScrollView *s = targetViewController.scrollView;
    CGPoint contentOffset = s.contentOffset;
    contentOffset.y = - self.pageMenu.frame.origin.y + HeaderViewH;
    if (contentOffset.y >= HeaderViewH) {
        contentOffset.y = HeaderViewH;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        SFAqArtBaseController *baseVC = self.childViewControllers[self.pageMenu.selectedItemIndex];
        if ([baseVC isViewLoaded]) {
            [self.scrollView bringSubviewToFront:baseVC.view];
        }
        //如果是手指滑动
        if (scrollView.dragging || scrollView.decelerating) {
            //横向切换tableView时，头部不要跟随tableView偏移
            CGRect headerFrame = self.headerView.frame;
            headerFrame.origin.x = scrollView.contentOffset.x - SCREEN_WIDTH * self.pageMenu.selectedItemIndex;
            self.headerView.frame = headerFrame;
        }else{
            //如果不是手指滑动，通过点击pageMenu上的item滑动。这里先将headerView加到self.view上，目的是过度一下，如果不过度，点击相邻item，改变scrollView的偏移量使用了动画参数，这个动画会导致切换headerview有一个闪跳现象
            CGRect rectInView = [self.headerView convertRect:self.headerView.bounds toView:self.view];
            rectInView.origin.x = 0;
            [self adjustHeaderY];
            [self.view addSubview:self.headerView];
            self.headerView.frame = rectInView;
            
            if (scrollView.contentOffset.x / SCREEN_WIDTH == self.pageMenu.selectedItemIndex)  {
                [self.headerView removeFromSuperview];
                baseVC.headerView = self.headerView;
                [self adjustHeaderY];
            }
        }
        //如果scrollView的内容很少，在屏幕内，自动回落
        if (scrollView.contentOffset.x / SCREEN_WIDTH == self.pageMenu.selectedItemIndex) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (baseVC.scrollView.contentSize.height < SCREEN_HEIGHT && [baseVC isViewLoaded]) {
                    [baseVC.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                }
            });
        }
    }
}
-(void)adjustHeaderY{
    //取出当前子控制器
    SFAqArtBaseController *baseVC = self.childViewControllers[self.pageMenu.selectedItemIndex];
    CGRect headerFrame = self.headerView.frame;
    //将pageMenu的frame切换到当前正在滑动的scrollView上
    CGRect pageMenuFrameInScrollView = [self.pageMenu convertRect:self.pageMenu.bounds toView:baseVC.scrollView];
    NSLog(@"pageMenuY:%.1f",pageMenuFrameInScrollView.origin.y);
    //每个tableView的头视图的y值都等于pageMenu的y值减去头部高度，这是为了保证头部的底部永远跟pageMenu的顶部紧贴
    headerFrame.origin.y = pageMenuFrameInScrollView.origin.y - HeaderViewH;
    self.headerView.frame = headerFrame;
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self adjustHeaderY];
    }
    SFAqArtBaseController *baseVc = self.childViewControllers[self.pageMenu.selectedItemIndex];
    // 这个方法是因为手指拖拽了scrollView松开手指，结束减速时调用，如果是因为代码改变scrollView偏移量不会来到这个方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (baseVc.scrollView.contentSize.height < SCREEN_HEIGHT && [baseVc isViewLoaded]) {
            [baseVc.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    });
}
#pragma mark --- lazy ---
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - BottomMargin)];;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 4, 0);
    }
    return  _scrollView;
}
- (SFHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SFHeaderView alloc]init];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HeaderViewH);
        _headerView.backgroundColor = [UIColor greenColor];
    }
    return _headerView;
}
- (SPPageMenu *)pageMenu{
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), SCREEN_WIDTH, PageMenuH) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
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



































/*
 
 UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(200, 200, 100, 100)];
 redView.backgroundColor = [UIColor redColor];
 [self.view addSubview:redView];
 
 UIView *greenView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
 greenView.backgroundColor = [UIColor greenColor];
 [self.view addSubview:greenView];
 
 UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
 blueView.backgroundColor = [UIColor blueColor];
 [redView addSubview:blueView];
 
 CGRect rec = [self.view convertRect:blueView.frame fromView:redView];
 NSLog(@"rec:%@",NSStringFromCGRect(rec));//rec:{{200, 200}, {40, 40}}
 // redview中的blueview相对于self.view的位置 ✔️
 
 CGRect rec1 = [self.view convertRect:redView.frame fromView:blueView];
 NSLog(@"rec1:%@",NSStringFromCGRect(rec1));//rec1:{{400, 400}, {100, 100}} ✅
 // 蓝色view中的定义一个相对于蓝色view的frame的view，这个view相对于self.view的位置
 
 CGRect rect =  [redView convertRect:greenView.frame toView:self.view];
 NSLog(@"rect:%@",NSStringFromCGRect(rect));//rect:{{300, 300}, {50, 50}} ✅
 /// 在redView中，定义一个相对于redView（100，100）,大小为（50，50）的view，这个view相对于self.view的位置
 
 
 /// 需要注意的是toview可以传nil
 CGRect rect1 =  [redView convertRect:greenView.frame toView:nil];
 NSLog(@"rect1:%@",NSStringFromCGRect(rect1));//rect1:{{100, 100}, {50, 50}} ✅
 /// 上面的代码的意思是：在redView中，定义一个目标区域，该区域相对于window的位置（nil代表的是self.view.window）
 
 CGRect rect2 =  [redView convertRect:greenView.frame toView:blueView];
 NSLog(@"rect2:%@",NSStringFromCGRect(rect2));//rect2:{{100, 100}, {50, 50}}
 //在redView中，定义一个相对于redview（100，100）,大小为（50，50）的view，这个view相对于blueView的位置
 
 CGRect rect3 =  [redView convertRect:CGRectMake(80, 80, 80, 80) toView:blueView];
 NSLog(@"rect3:%@",NSStringFromCGRect(rect3));//rect3:{{80, 80}, {80, 80}}
 //在redView中，定义一个相对于redview（80,80）,大小为（80，80）的view，这个view相对于blueView的位置
 
 CGRect rect4 =  [redView convertRect:CGRectMake(80, 80, 80, 80) toView:greenView];
 NSLog(@"rect4:%@",NSStringFromCGRect(rect4));//rect4:{{180, 180}, {80, 80}}
 //在redView中，定义一个相对于redview（80,80）,大小为（80，80）的view，这个view相对于greenView的位置
 
 CGRect rect5 =  [redView convertRect:CGRectMake(20, 20, 80, 80) toView:greenView];
 NSLog(@"rect5:%@",NSStringFromCGRect(rect5));//rect5:{{120, 120}, {80, 80}}
 //在redView中，定义一个相对于redview（80,80）,大小为（80，80）的view，这个view相对于greenView的位置
 
 CGRect newRect = [redView convertRect:greenView.bounds toView:nil];
 NSLog(@"newRect:%@",NSStringFromCGRect(newRect));//newRect:{{0, 0}, {50, 50}}
 
 CGRect newRect0 = [redView convertRect:greenView.frame toView:nil];
 NSLog(@"newRect0:%@",NSStringFromCGRect(newRect0));//newRect0:{{100, 100}, {50, 50}}
 
 CGRect newRect1 = [redView convertRect:redView.bounds toView:nil];
 NSLog(@"newRect1:%@",NSStringFromCGRect(newRect1));//newRect1:{{0, 0}, {100, 100}}
 
 CGRect newRect2 = [redView convertRect:redView.frame toView:nil];
 NSLog(@"newRect2:%@",NSStringFromCGRect(newRect2));//newRect2:{{200, 200}, {100, 100}}
 

 2019-08-12 14:54:04.798060+0800 SFHoverTableView[10946:186139] rec:{{200, 200}, {40, 40}}
 2019-08-12 14:54:04.798231+0800 SFHoverTableView[10946:186139] rec1:{{400, 400}, {100, 100}}
 2019-08-12 14:54:04.798333+0800 SFHoverTableView[10946:186139] rect:{{300, 300}, {50, 50}}
 2019-08-12 14:54:04.798420+0800 SFHoverTableView[10946:186139] rect1:{{100, 100}, {50, 50}}
 2019-08-12 14:54:04.798508+0800 SFHoverTableView[10946:186139] rect2:{{100, 100}, {50, 50}}
 2019-08-12 14:54:04.798594+0800 SFHoverTableView[10946:186139] rect3:{{80, 80}, {80, 80}}
 2019-08-12 14:54:04.798678+0800 SFHoverTableView[10946:186139] rect4:{{180, 180}, {80, 80}}
 2019-08-12 14:54:04.798758+0800 SFHoverTableView[10946:186139] rect5:{{120, 120}, {80, 80}}
 2019-08-12 14:54:04.798832+0800 SFHoverTableView[10946:186139] newRect:{{0, 0}, {50, 50}}
 2019-08-12 14:54:04.798913+0800 SFHoverTableView[10946:186139] newRect0:{{100, 100}, {50, 50}}
 2019-08-12 14:54:04.799096+0800 SFHoverTableView[10946:186139] newRect1:{{0, 0}, {100, 100}}
 2019-08-12 14:54:04.799377+0800 SFHoverTableView[10946:186139] newRect2:{{200, 200}, {100, 100}}
 


//总结：
//toView就是从左往右开始读代码，也是从左往右理解意思
//fromView就是从右往左开始读代码，也是从右往左理解意思

 */
































































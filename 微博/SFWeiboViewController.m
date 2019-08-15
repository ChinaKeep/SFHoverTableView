//
//  SFWeiboViewController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/22.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFWeiboViewController.h"
#import "SFTableView.h"
#import "SPPageMenu.h"
#import "SFHeaderView.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourViewController.h"

@interface SFWeiboViewController ()<UITableViewDelegate,UITableViewDataSource,SPPageMenuDelegate>
@property (nonatomic, strong) SFTableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SPPageMenu   *pageMenu;
@property (nonatomic, strong) SFHeaderView *headerView;
@property (nonatomic, strong) UIScrollView *childVCScrollView;


@end

@implementation SFWeiboViewController
- (void)leftItmeClick:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"仿微博";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftItmeClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.headerView;
    
    //添加子控制器
    [self addChildViewController:[FirstViewController new]];
    [self addChildViewController:[SecondViewController new]];
    [self addChildViewController:[ThirdViewController new]];
    [self addChildViewController:[FourViewController new]];
    //将第一个子控制器的View添加到scrollView上
    [self.scrollView addSubview:self.childViewControllers[0].view];
    
    //监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTableViewDidScroll:) name:RECEIVE_MESSAGE_NOTIFICATION object:nil];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_HEIGHT;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    // 添加分页菜单
    [cell.contentView addSubview:self.pageMenu];
    [cell.contentView addSubview:self.scrollView];
    return cell;
}
#pragma mark -- Observer ---
- (void)subTableViewDidScroll:(NSNotification *)notification{
    UIScrollView *scrollView = notification.object;
    NSLog(@"notificatioin==%@",notification.object);
    self.childVCScrollView = scrollView;
    
    NSLog(@"self.tableView.contentOffset.y=%f",self.tableView.contentOffset.y);
    
    if (self.tableView.contentOffset.y < HeaderViewH) {
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator  = NO;
    }else{
        scrollView.showsVerticalScrollIndicator = YES;
    }
}

#pragma mark -- UISCrollViewDelegate ---
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView == scrollView) {
        if ((self.childVCScrollView && _childVCScrollView.contentOffset.y > 0) || (scrollView.contentOffset.y > HeaderViewH)) {
            self.tableView.contentOffset = CGPointMake(0, HeaderViewH);
        }
        CGFloat offSetY = scrollView.contentOffset.y;
        NSLog(@"offSetY:%f",offSetY);
        if (offSetY < HeaderViewH) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"headerViewToTop" object:nil];
        }
    }else if (scrollView == self.scrollView){
        
    }
}
#pragma mark --- SPPageMenuDelegate ---
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (!self.childViewControllers.count) {
        return;
    }
    //如果上一次点击的button下标与当前的button下标之差大于等于2，说明界面移动了，此时不动画
    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:NO];
    }else{
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:YES];
    }
    UIViewController *targetViewController = self.childViewControllers[toIndex];
    targetViewController.view.frame = CGRectMake(SCREEN_WIDTH * toIndex, 0, SCREEN_WIDTH, SCREEN_HEIGHT - insert);
    UIScrollView *scrollView = targetViewController.view.subviews[0];
    CGPoint contentOffset = scrollView.contentOffset;
    if (contentOffset.y >= HeaderViewH) {
        contentOffset.y = HeaderViewH;
    }
    scrollView.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}
- (SFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[SFTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = CGRectMake(0, PageMenuH, SCREEN_WIDTH, SCREEN_HEIGHT - insert);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 4, 0);
        _scrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _scrollView;
}
- (SFHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[SFHeaderView alloc]init];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HeaderViewH);
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.layer.masksToBounds = NO;
        
        UIView *contentView = [[UIView alloc] initWithFrame:_headerView.bounds];
        contentView.backgroundColor = [UIColor greenColor];
        [_headerView addSubview:contentView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 30);
        btn.center = CGPointMake(_headerView.center.x, _headerView.center.y);
        btn.backgroundColor = [UIColor purpleColor];
        [btn setTitle:@"爱你吆" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    }
    return _headerView;
}

- (SPPageMenu *)pageMenu{
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PageMenuH) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
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
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end














//
//  SFAqArtBaseController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/9.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFAqArtBaseController.h"

NSNotificationName const ArtChildScrollViewDidScrollNSNotification = @"ChildScrollViewDidScrollNSNotification";
NSNotificationName const ArtChildScrollViewRefreshStateNSNotification = @"ChildScrollViewRefreshStateNSNotification";


@interface SFAqArtBaseController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HeaderContentView *placeholderHeaderView;
@property (nonatomic, assign)  NSInteger rowCount;

@end

@implementation SFAqArtBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableHeaderView = self.placeholderHeaderView;
    [self.view addSubview:self.tableView];
    self.scrollView = self.tableView;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //下拉刷新
        [self downPullUpdateData];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
       //上拉加载
        [self upPullLoadMoreData];
    }];
    
}
////下拉刷新
- (void)downPullUpdateData{
    [[NSNotificationCenter defaultCenter]postNotificationName:ArtChildScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(YES)}];
    //模拟网络请求，1秒后结束刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rowCount = 20;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:ArtChildScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(NO)}];
    });
}
//上拉加载
- (void)upPullLoadMoreData{
    [[NSNotificationCenter defaultCenter]postNotificationName:ArtChildScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(YES)}];
    self.rowCount = 30;
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rowCount = 20;
        [self.tableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter]postNotificationName:ArtChildScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(NO)}];
    });
}
#pragma mark -- 设置头视图 --
- (void)setHeaderView:(SFHeaderView *)headerView{
    _headerView = headerView;
    CGRect headerFrame = self.headerView.frame;
    headerFrame.origin.x = 0;
    headerFrame.origin.y = 0;
    self.headerView.frame = headerFrame;
    [self.placeholderHeaderView addSubview:headerView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetDisfference = scrollView.contentOffset.y - self.lastContentOffset.y;
    //滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:ArtChildScrollViewDidScrollNSNotification object:nil userInfo:@{@"scrollingScrollView":scrollView,@"offsetDifference":@(offsetDisfference)}];
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.lastContentOffset = scrollView.contentOffset;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

#pragma ---- lazy ----

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BottomMargin) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.masksToBounds = NO;
    }
    return _tableView;
}
- (HeaderContentView *)placeholderHeaderView{
    if (!_placeholderHeaderView) {
        _placeholderHeaderView = [[HeaderContentView alloc]init];
        _placeholderHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HeaderViewH+PageMenuH);
    }
    return _placeholderHeaderView;
}

#pragma mark -- 移除所有的监听 --

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

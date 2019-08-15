

//
//  SFBaseViewController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/22.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFBaseViewController.h"

@interface SFBaseViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger rowCount;
@end

@implementation SFBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.scrollView = self.tableView;
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       //下拉刷新
        [self upPullUpdateData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
       //上拉加载
        [self upPullLoadMoreData];
    }];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil
     ];
    
}
- (void)pageTitleViewToTop{
    self.tableView.contentOffset = CGPointZero;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //滚动时 发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_MESSAGE_NOTIFICATION object:scrollView];
}
//下拉刷新
- (void)upPullUpdateData{
//    [[NSNotificationCenter defaultCenter] postNotificationName:ChindScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(YES)}];
    //模拟网络请求1秒后结束刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rowCount = 20;
        [self.tableView.mj_header endRefreshing];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ChindScrollViewRefreshStateNSNotification object:nil userInfo:@{@"isRefreshing":@(NO)}];
    });
}

- (void)upPullLoadMoreData{
    self.rowCount = 30;
    [self.tableView reloadData];
    //模拟网络请求，1秒后结束刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            self.rowCount = 20;
            [self.tableView.mj_footer endRefreshing];
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PageMenuH - NaviH) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

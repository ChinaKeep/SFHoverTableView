//
//  ViewController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/17.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Helper.h"
#import "SFWeiboViewController.h"
#import "SFAmericanController.h"
#import "SFAqArtController.h"
#import "SFOtherController.h"

typedef enum : NSUInteger {
    SFHoverWeibo,
    SFHoverTypeAmerican,
    SFHoverTypeAiqiArt,
} SFHoverType;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   UITableView         *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor redColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"仿微博";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"仿美团";
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"仿爱奇艺";
    }else{
        cell.textLabel.text = @"富文本";
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        
        SFWeiboViewController *weiboVC = [[SFWeiboViewController alloc]init];
        [self.navigationController  pushViewController: weiboVC animated:YES];
        
    }else if (indexPath.row == 1){
        
        SFAmericanController *americanVC = [[SFAmericanController alloc]init];
        [self.navigationController pushViewController:americanVC animated:YES];
        
    }else if(indexPath.row == 2){
        SFAqArtController *artVC = [[SFAqArtController alloc]init];
        [self.navigationController pushViewController:artVC animated:YES];
    }else{
        SFOtherController *otherVC = [[SFOtherController alloc]init];
        [self.navigationController pushViewController:otherVC animated:YES];
    }
}

@end



























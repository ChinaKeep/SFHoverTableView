//
//  SFOtherController.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/13.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFOtherController.h"
#import "WJLabel.h"

@interface SFOtherController ()

@end

@implementation SFOtherController
- (void)leftItmeClick:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftItmeClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    NSString *string = @"阿法拉伐打飞机奥美拉大V安啦大V拉丁名辣么绿帽13951771238发件方大量发的律师费17551059517falfds @123 http://www.baidu.com";
    
    WJLabel *label = [[WJLabel alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    label.numberOfLines = 0;
    label.textColor = [UIColor greenColor];
    label.text = string;
    [self.view addSubview:label];
    
}


@end

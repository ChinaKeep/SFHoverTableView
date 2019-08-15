//
//  SFAmericanBaseController.h
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/9.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSNotificationName const ChildScrollViewDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ChildScrollViewRefreshStateNSNotification;

@interface SFAmericanBaseController : UIViewController
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) BOOL  isFirstViewLoaded;
@property (nonatomic, assign) BOOL  refreshState;


@end

NS_ASSUME_NONNULL_END

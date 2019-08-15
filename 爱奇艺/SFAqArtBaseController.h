//
//  SFAqArtBaseController.h
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/9.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHeaderView.h"
#import "HeaderContentView.h"

UIKIT_EXTERN NSNotificationName const ArtChildScrollViewDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ArtChildScrollViewRefreshStateNSNotification;


NS_ASSUME_NONNULL_BEGIN


@interface SFAqArtBaseController : UIViewController
@property (nonatomic, strong)   UIScrollView *scrollView;
@property (nonatomic, strong)   SFHeaderView *headerView;
@property (nonatomic, assign)   CGPoint      lastContentOffset;
@property (nonatomic, assign)   BOOL         isFirstViewLoaded;


@end

NS_ASSUME_NONNULL_END

























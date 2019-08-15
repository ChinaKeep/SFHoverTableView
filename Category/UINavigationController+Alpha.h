//
//  UINavigationController+Alpha.h
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/7.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (Alpha)

@end


@interface UIViewController(Alpha)

@property (nonatomic, assign) CGFloat navAlpha;
@property (null_resettable,nonatomic,strong) UIColor *navBarTintColor;
@property (null_resettable,nonatomic,strong) UIColor *navTintColor;
@property (null_resettable,nonatomic,strong) UIColor *navTitleColor;

@end


NS_ASSUME_NONNULL_END

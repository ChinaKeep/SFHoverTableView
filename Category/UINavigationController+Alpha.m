//
//  UINavigationController+Alpha.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/7.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "UINavigationController+Alpha.h"
#import "UINavigationBar+Alpha.h"

@implementation UINavigationController (Alpha)
/// UINavigationBar
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item{
    navigationBar.tintColor = self.topViewController.navTintColor;
    navigationBar.barTintColor = self.topViewController.navBarTintColor;
    navigationBar.navAlpha = self.topViewController.navAlpha;
    
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(nonnull UINavigationItem *)item{
    navigationBar.tintColor = self.topViewController.navTintColor;
    navigationBar.barTintColor = self.topViewController.navBarTintColor;
    navigationBar.navAlpha = self.topViewController.navAlpha;
    return YES;
}

@end

#pragma mark - UIViewController + Alpha -
@implementation UIViewController(Alpha)

static char *vcAlphaKey = "vcAlphaKey";
static char *vcColorKey = "vcColorKey";
static char *vaNavtintColorKey = "vcNavtintColorKey";
static char *vcTitleColorKey = "vcTitleColorKey";

- (void)setNavAlpha:(CGFloat)navAlpha{
    CGFloat alpha = MAX(MIN(navAlpha, 1), 0);
    self.navigationController.navigationBar.navAlpha = alpha;
    objc_setAssociatedObject(self, vcAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)navAlpha{
    if (objc_getAssociatedObject(self, vcAlphaKey) == nil) {
        return 1;
    }
    return [objc_getAssociatedObject(self, vcAlphaKey) floatValue];
}

/// backgroundColor
- (UIColor *)navBarTintColor{
    UIColor *color = objc_getAssociatedObject(self, vcColorKey);
    if(color == nil){
        color = [UINavigationBar appearance].barTintColor;
    }
    return color;
}
- (void)setNavBarTintColor:(UIColor *)navBarTintColor{
    self.navigationController.navigationBar.barTintColor = navBarTintColor;
    objc_setAssociatedObject(self, vcColorKey, navBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/// tintColor 适配iOS7 修改背景色
- (UIColor*)navTintColor{
    UIColor *color = objc_getAssociatedObject(self, vaNavtintColorKey);
    if (color == nil) {
        color = [UINavigationBar appearance].tintColor;
    }
    return color;
}
- (void)setNavTintColor:(UIColor *)navTintColor{
    self.navigationController.navigationBar.tintColor = navTintColor;
    objc_setAssociatedObject(self, vaNavtintColorKey, navTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/// titleColor
- (UIColor *)navTitleColor{
    UIColor *color = objc_getAssociatedObject(self, vcTitleColorKey);
    if (color == nil) {
        color = self.navigationController.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    }
    return color;
}

- (void)setNavTitleColor:(UIColor *)navTitleColor{
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = navTitleColor;
    [self.navigationController.navigationBar setTitleTextAttributes:textAttrs];
    objc_setAssociatedObject(self, vcTitleColorKey, navTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


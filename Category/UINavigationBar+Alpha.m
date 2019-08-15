//
//  UINavigationBar+Alpha.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/6.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "UINavigationBar+Alpha.h"

#define IOS10 [[[UIDevice currentDevice]systemVersion] floatValue] >= 10.0


@implementation UINavigationBar (Alpha)

static char *navAlphaKey = "navAlphaKey";
#pragma mark --- set ---
- (void)setNavAlpha:(CGFloat)navAlpha{
    CGFloat alpha = MAX(MIN(navAlpha, 1), 0);//透明度必须在0~1的范围之间
    UIView *barBackground = self.subviews[0];
    if (self.translucent == NO || [self backgroundImageForBarMetrics:UIBarMetricsDefault] != nil) {
        barBackground.alpha = alpha;
    }else{
        if (IOS10) {
            UIView *effectFilterView = barBackground.subviews.lastObject;
            effectFilterView.alpha = alpha;
        }else{
            UIView *effectFilterView = barBackground.subviews.firstObject;
            effectFilterView.alpha = alpha;
        }
    }
    /// 黑线
    UIImageView *shadowView = [barBackground valueForKey:@"_shadowView"];
    if (alpha < 0.01) {
        shadowView.hidden = YES;
    }else{
        shadowView.hidden = NO;
        shadowView.alpha = alpha;
    }
    objc_setAssociatedObject(self, navAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
#pragma mark --- get ---
- (CGFloat)navAlpha{
    if (objc_getAssociatedObject(self, navAlphaKey) == nil) {
        return 1;
    }
    return [objc_getAssociatedObject(self, navAlphaKey) floatValue];
}

@end

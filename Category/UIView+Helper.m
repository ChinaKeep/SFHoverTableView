//
//  UIView+Helper.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/17.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

#pragma mark -- set get --
- (void)setX:(CGFloat)x{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}
- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}
- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}
- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}
- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}
- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y  = centerY;
    self.center = center;
}
- (CGFloat)centerY{
    return self.center.y;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
- (CGSize)size{
    return  self.frame.size;
}

- (void)setTop:(CGFloat)top{
    self.frame = CGRectMake(self.left, top, self.width, self.height);
}
- (CGFloat)top{
    return self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom{
    self.frame = CGRectMake(self.left, bottom - self.height, self.width, self.height);
}
- (CGFloat)bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLeft:(CGFloat)left{
    self.frame = CGRectMake(left, self.top, self.width, self.height);
}
- (CGFloat)left{
    return self.frame.origin.x;
}

- (void)setRight:(CGFloat)right{
    self.frame = CGRectMake(right - self.width, self.top, self.width, self.height);
}
- (CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}



@end






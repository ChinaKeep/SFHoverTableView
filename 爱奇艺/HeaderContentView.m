//
//  HeaderContentView.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/8/9.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "HeaderContentView.h"

@implementation HeaderContentView

#warning  如果子控件的子控件还设有子控件，以此下去，同样超出父控件无法点击，此问题应该有开发者自己判定

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view =[super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
            for (UIView *subsubView in subView.subviews) {
                //当前视图中，point点相对于subsubView的位置
                CGPoint tp = [subsubView convertPoint:point fromView:self];
                if (CGRectContainsPoint(subsubView.bounds, tp)) {//如果包含点击点，返回subsubview作为view
                    view = subsubView;
                }
            }
        }
    }
    return view;
}
@end

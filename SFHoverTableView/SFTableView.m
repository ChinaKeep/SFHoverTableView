//
//  SFTableView.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/22.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFTableView.h"

@implementation SFTableView
//支持多手势 当滑动子控制器的scrollView时，SFTableView也能接受滑动事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end

//
//  WJStatusLabel.h
//  EVR
//
//  Created by apple on 16-7-17.
//  Copyright (c) 2016年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJLabel;

@protocol WJLabelDelegate <NSObject>

@required
// 点击label
- (void)labelDidTap:(WJLabel *)myLabel;

@end

@interface WJLabel : UILabel

@property (nonatomic, weak) id <WJLabelDelegate> customDelegate;

- (void)isHiddenTextView:(BOOL)flag;

- (id)initWithFrame:(CGRect)frame;

@end

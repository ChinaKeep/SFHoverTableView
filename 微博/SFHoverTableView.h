//
//  SFHoverTableView.h
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/17.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFHoverTableView;

@protocol SFHoverTableViewDataSource <NSObject> //数据源代理方法

- (NSInteger)numberOfItemsInSFTableView:(SFHoverTableView *)tableView;
- (UIScrollView *)hoverTableView:(SFHoverTableView *)hoverTableView viewForItemAtIndex:(NSInteger)index reusingView:(UIScrollView *)view;

@end


NS_ASSUME_NONNULL_BEGIN

@interface SFHoverTableView : UIView
@property (nonatomic, weak) id<SFHoverTableViewDataSource> dataSource;

@property (nonatomic, strong, readonly) UICollectionView *cotentView;
/**
 头部视图
 */
@property (nonatomic, strong)   UIView      *sfHeaderView;
/**
 悬停视图
 */
@property (nonatomic, strong)   UIView      *sfHeaderBar;
/**
 sfHeaderView 顶部的留白inset，这个属性可以设置顶部导航栏的inset，默认 64
 */
@property (nonatomic, assign)   CGFloat     sfHeaderTopInset;
/**
 当前itemView的index，在滑动SFHoverView过程中，index的变化以显示窗口的1/2宽为界限
 */
@property (nonatomic, readonly) NSInteger   currentItemIndex;
/**
 当前的itemView，在滑动的过程中，currentItemView的变化以显示窗口的1/2宽为界限
 */
@property (nonatomic, readonly, strong) UIScrollView    *currentItemView;
/**
 是否开启水平bounce的效果，默认 YES
 */
@property (nonatomic, assign) BOOL alwaysBounceHorizontal;
/**
 在实际操作过程中，不同item的listView显示的数据不同，当数据多个item垂直滚动后，水平切换到数据少的item时，后一个item
 垂直滚动的范围便小于前一个item的垂直滚动范围，此时操作当前的item会产生一个回弹的动作。
 设置这个属性，可以调整前后两个item的滚动范围一致。默认为NO
 */
@property (nonatomic, assign) BOOL shouldAdjustContentSize;
/**
 headerBar是否跟随滚动，默认为NO
 */
@property (nonatomic, assign) BOOL sfHeaderBarScrollDisabled;

@property (nonatomic, assign) BOOL scrollEnabled;

- (void)reloadData;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END



























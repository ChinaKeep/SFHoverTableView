//
//  SFHoverTableView.m
//  SFHoverTableView
//
//  Created by 随风流年 on 2019/7/17.
//  Copyright © 2019 随风流年. All rights reserved.
//

#import "SFHoverTableView.h"
#import "UIView+Helper.h"
#import <objc/runtime.h>
#pragma mark --- 分类 ----
@interface UICollectionViewCell(ScrollView)
- (UIScrollView *)scrollView;
@end

@implementation UICollectionViewCell (ScrollView)

- (UIScrollView *)scrollView{
    UIScrollView *scrollView = nil;
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView*)subView;
            break;
        }
    }
    return scrollView;
}
@end

@interface SFHoverTableView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate
>
@property (nonatomic, strong, readwrite) UICollectionView *contentView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, assign) CGFloat headerInset;
@property (nonatomic, assign) CGFloat barInset;
@property (nonatomic, assign) NSIndexPath *currentItemIndexPath;
@property (nonatomic, readwrite) NSInteger currentItemIndex;
@property (nonatomic, strong, readwrite) UIScrollView *currentItemView;
/**
 将要显示的item的index
 */
@property (nonatomic, assign) NSInteger shouldVisibleItemIndex;
/**
 将要显示的itemView
 */
@property (nonatomic, strong) UIScrollView *shouldVisibleItemView;
/**
 记录重用中各个item的contentOffset，最后还原用
 */
@property (nonatomic, strong) NSMutableDictionary *contentOffsetQuene;
/**
 记录item的contentSize
 */
@property (nonatomic, strong) NSMutableDictionary *contentSizeQuene;
/**
 记录item所要求的最小的contentSize
 */
@property (nonatomic, strong) NSMutableDictionary *contentMinSizeQuene;
/**
 调用 scrollToItemAtIndex:animated: animated为NO的状态
 */
@property (nonatomic, assign) BOOL switchPageWithoutAnimation;
/**
 标记itemView自适应contentSize的状态，用于在observe中修改当前itemView的contentOffset（重设contentSizex影响contentOffset）
 */
@property (nonatomic, assign) BOOL isAdjustingcontentSize;
/**
 设置当前scrollViewItem的contentOffset时，在KVO中不对contentOffset进行观察处理
 */
@property (nonatomic, assign) BOOL contentOffsetKVODisabled;

@end

static NSString * const SFContentViewCellIdfy       = @"SFContentViewCellIdfy";
static const void *SFHoverTableViewItemTopInsetKey  = &SFHoverTableViewItemTopInsetKey;
static void *SFHoverTableViewItemContentOffsetContext = &SFHoverTableViewItemContentOffsetContext;
static void *SFHoverTableViewItemContentSizeContext = &SFHoverTableViewItemContentSizeContext;
static void *SFHoverTableViewItemPanGegstureContext = &SFHoverTableViewItemPanGegstureContext;


@implementation SFHoverTableView
#pragma mark -- init --
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}
- (void)setUI{
    self.contentView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.pagingEnabled = YES;
//    self.contentView.scrollsToTop = NO;
    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    [self.contentView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:SFContentViewCellIdfy];
    //添加一个空白视图，抵消iOS7后导航栏对scrollView的insets影响 -(void)automaticallyAdjustsScrollViewInsets:
    UIScrollView *autoAdjustInsetsView = [UIScrollView new];
    autoAdjustInsetsView.scrollsToTop = NO;
    [self addSubview:autoAdjustInsetsView];
    [self addSubview:self.contentView];
    
    self.contentOffsetQuene = [NSMutableDictionary dictionaryWithCapacity:0];
    self.contentSizeQuene = [NSMutableDictionary dictionaryWithCapacity:0];
    self.contentMinSizeQuene = [NSMutableDictionary dictionaryWithCapacity:0];
    self.sfHeaderTopInset = 64;
    self.headerInset = 0;
    self.barInset = 0;
    self.currentItemIndex = 0;
    self.switchPageWithoutAnimation = YES;
    self.currentItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
}

- (UICollectionViewLayout *)layout{
    if (!_layout) {
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        _layout.sectionInset = UIEdgeInsetsZero;
        _layout.itemSize = self.bounds.size;
    }
    return _layout;
}

#pragma makr -- layout --
- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    self.layout.itemSize = self.bounds.size;
    self.sfHeaderBar.top = self.sfHeaderView.bottom;//悬停视图的头部紧邻头视图的尾部
    if (self.sfHeaderBarScrollDisabled) {// headerBar是否跟随滚动，默认为NO
        self.sfHeaderBar.top = self.sfHeaderTopInset;
    }
}
- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark --- reloadData ---
- (void)reloadData{
    CGFloat headerOffsetY = - (self.headerInset + self.sfHeaderTopInset + self.barInset);//透视图高度+ 透视图顶部导航bar高度 + 悬停视图高度
    [self setSwitchPageWithoutAnimation:YES];// 调用 scrollToItemAtIndex:animated: animated为NO的状态
    [self.contentOffsetQuene removeAllObjects];
    [self.contentSizeQuene removeAllObjects];
    [self.contentMinSizeQuene removeAllObjects];
    [self.contentView reloadData];
    [self.currentItemView setContentOffset:CGPointMake(0, headerOffsetY)];
    
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated{
    CGPoint contentOffset = self.currentItemView.contentOffset;
    CGSize contentSize = self.currentItemView.contentSize;
    self.contentOffsetQuene[@(self.currentItemIndex)] = [NSValue valueWithCGPoint:contentOffset];
    self.contentSizeQuene[@(self.currentItemIndex)] = [NSValue valueWithCGSize:contentSize];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.contentView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

#pragma mark ------ UICollectionView Delegate -------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInSFTableView:)]) {
        return [self.dataSource numberOfItemsInSFTableView:self];
    }
    return  0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFContentViewCellIdfy forIndexPath:indexPath];
    UIScrollView *subView = cell.scrollView;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(hoverTableView:viewForItemAtIndex:reusingView:)]) {
        UIScrollView *newSubView = [self.dataSource hoverTableView:self viewForItemAtIndex:indexPath.row reusingView:subView];
        newSubView.scrollsToTop = NO;
        CGFloat topInset = self.headerInset + self.barInset + self.sfHeaderTopInset;
        UIEdgeInsets contentInset = newSubView.contentInset;
        BOOL setTopInset = [objc_getAssociatedObject(newSubView, SFHoverTableViewItemTopInsetKey)boolValue];
        if (!setTopInset) {
            contentInset.top += topInset;
            newSubView.contentInset = contentInset;
            newSubView.scrollIndicatorInsets = contentInset;
            newSubView.contentOffset = CGPointMake(0, -topInset);
            objc_setAssociatedObject(newSubView, SFHoverTableViewItemTopInsetKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            //update
            CGFloat deltaTopInset = topInset - contentInset.top;
            contentInset.top += deltaTopInset;
            newSubView.contentInset = contentInset;
            newSubView.scrollIndicatorInsets = contentInset;
        }
        if (newSubView != subView) {
            [subView removeFromSuperview];
            [cell.contentView addSubview:newSubView];
            subView = newSubView;
        }
    }
    
    [_shouldVisibleItemView removeObserver:self forKeyPath:@"contentOffset"];
    [_shouldVisibleItemView removeObserver:self forKeyPath:@"contentSize"];
    [_shouldVisibleItemView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
    self.shouldVisibleItemView =  subView;
    self.shouldVisibleItemIndex = indexPath.item;
    [self.shouldVisibleItemView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemContentOffsetContext];
    [self.shouldVisibleItemView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemContentSizeContext];
    [self.shouldVisibleItemView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemPanGegstureContext];
    
    UIScrollView *lastItemView = _currentItemView;
    NSInteger lastIndex = _currentItemIndex;
    
    if (_switchPageWithoutAnimation) {
        // observe
        [_currentItemView removeObserver:self forKeyPath:@"contentOffset"];
        [_currentItemView removeObserver:self forKeyPath:@"contentSize"];
        [_currentItemView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
        [subView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemContentOffsetContext];
        [subView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemContentSizeContext];
        [subView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:SFHoverTableViewItemPanGegstureContext];
        self.currentItemIndex = indexPath.row;
        self.currentItemView  = subView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _switchPageWithoutAnimation = !_switchPageWithoutAnimation;
        });
    }
    
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark ---- observer -----
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    /** contentOffset */
    if (context == SFHoverTableViewItemContentOffsetContext) {
        if (self.contentOffsetKVODisabled) {//如果不需要观察则直接return
            return;
        }
        if (!self.sfHeaderBarScrollDisabled) {
            CGFloat newOffsetY = [change[NSKeyValueChangeNewKey]CGPointValue].y;
            CGFloat topMarginOffset = self.sfHeaderTopInset + self.barInset;
            //stick the bar
            if (newOffsetY < -topMarginOffset) {
                if (_sfHeaderBar) {
                    _sfHeaderBar.bottom = - newOffsetY;
                    _sfHeaderView.bottom = _sfHeaderBar.top;//header的底部为 bar的顶部
                } else {
                    _sfHeaderView.bottom = - newOffsetY;
                }
            }else{
                _sfHeaderBar.bottom = topMarginOffset;
                _sfHeaderView.bottom = fmax(-(newOffsetY + _barInset), 0);
            }
        }
        /**
         在自适应contentSize的状态下，itemView初始化后（初始化会导致contentOffset变化，此时又可能做相邻itemView自适应处理），contentOffset变化受影响，这里做处理保证contentOffset准确
         */
        if (self.isAdjustingcontentSize) {
            //当前scrollview所对应的index
            NSInteger index = self.currentItemIndex;
            if (object != self.currentItemView) {
                index = self.shouldVisibleItemIndex;
            }
            UIScrollView *scrollView = object;
            NSValue *offsetObj = self.contentOffsetQuene[@(index)];
            
        }
    }
}
































































@end













//
//  WJStatusLabel.m
//  EVR
//
//  Created by apple on 16-7-19.
//  Copyright (c) 2016年 wangjun. All rights reserved.
//

#import "WJLabel.h"
#import "WJLink.h"
#import "WJRegexResult.h"
#import "RegexKitLite.h"

#define WJLinkText @"WJLinkText"
#define WJLinkBackgroundTag 10000

@interface WJLabel()
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *links;
@end

@implementation WJLabel

- (NSMutableArray *)links
{
    if (!_links) {
        NSMutableArray *links = [NSMutableArray array];
        
        // 搜索所有的链接
        [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSString *linkText = attrs[WJLinkText];
            if (linkText == nil) return;
            
            // 创建一个链接
            WJLink *link = [[WJLink alloc] init];
            link.text = linkText;
            link.range = range;
            // 处理矩形框
            NSMutableArray *rects = [NSMutableArray array];
            // 设置选中的字符范围
            self.textView.selectedRange = range;
            // 算出选中的字符范围的边框
            NSArray *selectionRects = [self.textView selectionRectsForRange:self.textView.selectedTextRange];
            for (UITextSelectionRect *selectionRect in selectionRects) {
                if (selectionRect.rect.size.width == 0 || selectionRect.rect.size.height == 0) continue;
                [rects addObject:selectionRect];
            }
            link.rects = rects;
            
            [links addObject:link];
        }];
        self.links = links;
    }
    return _links;
}

/**
 0.查找出所有的链接（用一个数组存放所有的链接）
 
 1.在touchesBegan方法中，根据触摸点找出被点击的链接
 2.在被点击链接的边框范围内添加一个有颜色的背景
 
 3.在touchesEnded或者touchedCancelled方法中，移除所有的链接背景
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        UITextView *textView = [[UITextView alloc] init];
        // 不能编辑
        textView.editable = NO;
        // 不能滚动
        textView.scrollEnabled = NO;
        // 设置TextView不能跟用户交互
        textView.userInteractionEnabled = NO;
        // 设置文字的内边距
        textView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        textView.backgroundColor = [UIColor clearColor];
        [self addSubview:textView];
        self.textView = textView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textView.frame = self.bounds;
}

#pragma mark - 公共接口
- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:[self clearAttributedStringWithText:attributedText.string]];
    
    self.textView.attributedText = attributedText;
    self.links = nil;
}

#pragma mark - 事件处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    // 得出被点击的那个链接
    WJLink *touchingLink = [self touchingLinkWithPoint:point];
    
    // 设置链接选中的背景
    [self showLinkBackground:touchingLink];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    // 得出被点击的那个链接
    WJLink *touchingLink = [self touchingLinkWithPoint:point];
    if (touchingLink) {
        // 说明手指在某个链接上面抬起来, 发出通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:WJLinkDidSelectedNotification object:nil userInfo:@{WJLinkText : touchingLink.text}];
    }
    
    // 相当于触摸被取消
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeAllLinkBackground];
    });
}

- (void)isHiddenTextView:(BOOL)flag {
    self.textView.hidden = flag;
}
#pragma mark - 链接背景处理
/**
 *  根据触摸点找出被触摸的链接
 *
 *  @param point 触摸点
 */
- (WJLink *)touchingLinkWithPoint:(CGPoint)point
{
    __block WJLink *touchingLink = nil;
    [self.links enumerateObjectsUsingBlock:^(WJLink *link, NSUInteger idx, BOOL *stop) {
        for (UITextSelectionRect *selectionRect in link.rects) {
            if (CGRectContainsPoint(selectionRect.rect, point)) {
                touchingLink = link;
                break;
            }
        }
    }];
    return touchingLink;
}

/**
 *  显示链接的背景
 *
 *  @param link 需要显示背景的link
 */
- (void)showLinkBackground:(WJLink *)link
{
    for (UITextSelectionRect *selectionRect in link.rects) {
        UIView *bg = [[UIView alloc] init];
        bg.tag = WJLinkBackgroundTag;
        bg.layer.cornerRadius = 3;
        bg.frame = selectionRect.rect;
        bg.backgroundColor = [UIColor redColor];
        [self insertSubview:bg atIndex:0];
    }
}

- (void)removeAllLinkBackground
{
    for (UIView *child in self.subviews) {
        if (child.tag == WJLinkBackgroundTag) {
            [child removeFromSuperview];
        }
    }
}

/**
 *  这个方法会返回能够处理事件的控件
 *  这个方法可以用来拦截所有触摸事件
 *  @param point 触摸点
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self touchingLinkWithPoint:point]) {
        return self;
    }
    return nil;
}
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if ([self touchingLinkWithPoint:point]) {
//        return YES;
//    }
//    return NO;
//}

- (NSAttributedString *)clearAttributedStringWithText:(NSString *)text
{
    // 1.匹配字符串
    NSArray *regexResults = [self regexResultsWithText:text];
    
    // 2.根据匹配结果，拼接对应的图片表情和普通文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    // 遍历
    [regexResults enumerateObjectsUsingBlock:^(WJRegexResult *result, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString *substr = [[NSMutableAttributedString alloc] initWithString:result.string];
        
        // 匹配#话题#
        NSString *trendRegex = @"#[a-zA-Z0-9\\u4e00-\\u9fa5]+#";
        [result.string enumerateStringsMatchedByRegex:trendRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            [substr addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:*capturedRanges];
            [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
        }];
        
        // 匹配@提到
        NSString *mentionRegex = @"@[a-zA-Z0-9\\u4e00-\\u9fa5\\-_]+";
        [result.string enumerateStringsMatchedByRegex:mentionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            [substr addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:*capturedRanges];
            [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
        }];
        
        // 匹配超链接
        NSString *httpRegex = @"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
        [result.string enumerateStringsMatchedByRegex:httpRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            [substr addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:*capturedRanges];
            [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
        }];
        
        // 匹配超链接
        NSString *phoneRegex = @"1+[3578]+\\d{9}";
        [result.string enumerateStringsMatchedByRegex:phoneRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            [substr addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:*capturedRanges];
            [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
        }];
        
        [attributedString appendAttributedString:substr];
        //        }
    }];
    
    
    //
    //    // 设置字体
    //    [attributedString addAttribute:NSFontAttributeName value:WJChatFont range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}


- (NSAttributedString *)attributedStringWithText:(NSString *)text
{
    // 1.匹配字符串
    NSArray *regexResults = [self regexResultsWithText:text];
    
    // 2.根据匹配结果，拼接对应的图片表情和普通文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    // 遍历
    [regexResults enumerateObjectsUsingBlock:^(WJRegexResult *result, NSUInteger idx, BOOL *stop) {
//        WJEmotion *emotion = nil;
//        if (result.isEmotion) { // 表情
//            emotion = [WJEmotionTool emotionWithDesc:result.string];
//        }
//
//        if (emotion) { // 如果有表情
//            // 创建附件对象
//            WJEmotionAttachment *attach = [[WJEmotionAttachment alloc] init];
//
//            // 传递表情
//            attach.emotion = emotion;
//            attach.bounds = CGRectMake(0, -3, WJChatFont.lineHeight, WJChatFont.lineHeight);
//
//            // 将附件包装成富文本
//            NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
//            [attributedString appendAttributedString:attachString];
//        } else { // 非表情（直接拼接普通文本）
            NSMutableAttributedString *substr = [[NSMutableAttributedString alloc] initWithString:result.string];

            // 匹配#话题#
            NSString *trendRegex = @"#[a-zA-Z0-9\\u4e00-\\u9fa5]+#";
            [result.string enumerateStringsMatchedByRegex:trendRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:*capturedRanges];
                [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
            }];
        
            // 匹配@提到
            NSString *mentionRegex = @"@[a-zA-Z0-9\\u4e00-\\u9fa5\\-_]+";
            [result.string enumerateStringsMatchedByRegex:mentionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:*capturedRanges];
                [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
            }];
        
            // 匹配超链接
            NSString *httpRegex = @"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
            [result.string enumerateStringsMatchedByRegex:httpRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:*capturedRanges];
                [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
            }];
        
        // 匹配超链接
        NSString *phoneRegex = @"1+[3578]+\\d{9}";
        [result.string enumerateStringsMatchedByRegex:phoneRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            [substr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:*capturedRanges];
            [substr addAttribute:WJLinkText value:*capturedStrings range:*capturedRanges];
        }];

            [attributedString appendAttributedString:substr];
//        }
    }];
    

//
//    // 设置字体
//    [attributedString addAttribute:NSFontAttributeName value:WJChatFont range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

- (NSMutableArray *)regexResultsWithText:(NSString *)text {
    NSMutableArray *regexResults = [NSMutableArray array];
    // 匹配表情
    NSString *emotionRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    
    // 匹配非表情
    [text enumerateStringsSeparatedByRegex:emotionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        WJRegexResult *rr = [[WJRegexResult alloc] init];
        rr.string = *capturedStrings;
        rr.range = *capturedRanges;
        rr.emotion = NO;
        [regexResults addObject:rr];
    }];
    
    // 排序
    [regexResults sortUsingComparator:^NSComparisonResult(WJRegexResult *rr1, WJRegexResult *rr2) {
        int loc1 = (int)rr1.range.location;
        int loc2 = (int)rr2.range.location;
        return [@(loc1) compare:@(loc2)];
    }];
    return regexResults;
}

- (void)setText:(NSString *)text {
//    [super setText:text];
    self.attributedText = [self attributedStringWithText:text];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:[UIColor clearColor]];
    self.textView.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.textView.font = font;
}

@end

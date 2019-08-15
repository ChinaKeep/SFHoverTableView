//
//  WJLink.h
//  EVR
//
//  Created by c02rg472gg77 on 16/7/18.
//  Copyright © 2016年 renxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJLink : NSObject
/** 链接文字 */
@property (nonatomic, copy) NSString *text;
/** 链接的范围 */
@property (nonatomic, assign) NSRange range;
/** 链接的边框 */
@property (nonatomic, strong) NSArray *rects;

@end

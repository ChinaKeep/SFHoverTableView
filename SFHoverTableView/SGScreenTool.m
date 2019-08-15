//
//  SGScreenTool.m
//  KindleLaw
//
//  Created by sogubaby on 2019/3/21.
//  Copyright © 2019 sogubaby. All rights reserved.
//

#import "SGScreenTool.h"

@implementation SGScreenTool

+ (BOOL)isPhoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

@end

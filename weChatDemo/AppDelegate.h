//
//  AppDelegate.h
//  weChatDemo
//
//  Created by zyh on 15/12/7.
//  Copyright © 2015年 zyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "weChat_SDK_V1.6.2/WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


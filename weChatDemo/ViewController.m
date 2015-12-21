//
//  ViewController.m
//  weChatDemo
//
//  Created by zyh on 15/12/7.
//  Copyright © 2015年 zyh. All rights reserved.
//

#import "ViewController.h"

#import "WechatPay.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)wecat:(id)sender {
    //微信支付
    //微信支付step1  选择商品下单
    [WechatPay wechatPayByTrade_no:@"88858886688" order_name:@"iphone6" andPrice:@"1"];
}

@end

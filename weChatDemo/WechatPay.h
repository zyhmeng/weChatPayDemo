//
//  WechatPay.h
//  weCatDemo
//
//  Created by zyh on 15/12/3.
//  Copyright © 2015年 zyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "weChat_SDK_V1.6.2/WXApi.h"




@interface WechatPay : NSObject


//微信支付
/*
 *微信支付step1  选择商品下单
 *       step2  请求生成支付订单，返回信息（prepay_id,sign等）
 *       step3  调用统一下单API，返回预付单信息（prepay_id）
 *       step4  想获得prepayid需要由预支付信息生成带参数的签名包
 */

/**
 *  微信支付step1  选择商品下单
 *
 *  @param tradeNo     商户订单号
 *  @param orderName   订单标题，展示给用户
 *  @param price       商品价格
 */
+(void)wechatPayByTrade_no:(NSString *)tradeNo order_name:(NSString *)orderName andPrice:(NSString *)price;



@end

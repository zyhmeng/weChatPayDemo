//
//  WechatPay.m
//  weCatDemo
//
//  Created by zyh on 15/12/3.
//  Copyright © 2015年 zyh. All rights reserved.
//

#import "WechatPay.h"
#import "PayRequsestHandler.h"
#import "weChat_SDK_V1.6.2/WXApi.h"
#import "weChat_SDK_V1.6.2/WXApiObject.h"



@implementation WechatPay


//微信支付
/*
 *微信支付step1  选择商品下单
 *       step2  请求生成支付订单，返回信息（prepay_id,sign等）
 *       step3  调用统一下单API，返回预付单信息（prepay_id）
 *       step4  想获得prepayid需要由预支付信息生成带参数的签名包
 */



//微信支付step1  选择商品下单
+(void)wechatPayByTrade_no:(NSString *)tradeNo order_name:(NSString *)orderName andPrice:(NSString *)price
{
    //1. 创建支付签名对象
    PayRequsestHandler *req = [[PayRequsestHandler alloc] init];
    //  初始化支付签名对象
    [req init:WeChat_App_ID mch_id:WeChat_MCH_ID];
    //  设置密钥
    [req setKey:WeChat_Partner_ID];
    

    //2. step2 请求生成支付订单，返回信息（prepay_id,sign等）
    NSMutableDictionary *dict = [req WXPayByTrade_no:tradeNo order_name:orderName andPrice:price];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req = [[PayReq alloc] init];
        req.openID  = [dict objectForKey:@"appid"];
        req.partnerId = [dict objectForKey:@"partnerid"];
        req.prepayId = [dict objectForKey:@"prepayid"];
        req.nonceStr = [dict objectForKey:@"noncestr"];
        req.timeStamp = stamp.intValue;
        req.package = [dict objectForKey:@"package"];
        req.sign = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req]; //发起支付
    }

}

@end

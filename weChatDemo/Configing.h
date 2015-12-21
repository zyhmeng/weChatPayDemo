//
//  wecat.h
//  wecatDemo
//
//  Created by zyh on 15/12/2.
//  Copyright © 2015年 zyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApiObject.h"

/**
 *  将微信支付的配置信息 写入对应的宏定义里
 */
//APPID
#define WeChat_App_ID  @"wx7d09cdaa382814f1"

//appsecret
#define WeChat_App_Secret @"be91b2a541dea2bb79ca8dfe7919f4ad"

//商户号，填写商户对应参数
#define WeChat_MCH_ID   @"1246495701"

//商户API密钥，填写相应参数
#define WeChat_Partner_ID @"433ad8747fbe97fe8e5216627b0814e3"

//支付结果回调页面
#define WeChat_Notify_URL @"http://daping.api.yunfengapp.com:8888/WechatPay/PayNotify.aspx"

//获取服务器端支付数据地址（商户自定义）
#define WeChat_SP_URL @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"


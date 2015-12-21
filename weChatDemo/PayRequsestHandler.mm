
#import <Foundation/Foundation.h>
#import "PayRequsestHandler.h"
/*
 服务器请求操作处理
 */
@implementation PayRequsestHandler

//初始化函数
-(BOOL) init:(NSString *)app_id mch_id:(NSString *)mch_id;
{
    //初始构造函数
    payUrl     = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    if (debugInfo == nil){
        debugInfo   = [NSMutableString string];
    }
    [debugInfo setString:@""];
    appid   = app_id;
    mchid   = mch_id;
    return YES;
}
//设置商户密钥
-(void) setKey:(NSString *)key
{
    spkey  = [NSString stringWithString:key];
}
//获取debug信息
-(NSString*) getDebugifo
{
    NSString    *res = [NSString stringWithString:debugInfo];
    [debugInfo setString:@""];
    return res;
}

//获取最后服务返回错误代码
-(long) getLasterrCode
{
    return last_errcode;
}

//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", spkey];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];
    
    //输出Debug Info
    [debugInfo appendFormat:@"MD5签名字符串：\n%@\n\n",contentString];

    return md5Sign;
}

//微信支付step4 想获得prepayid需要由预支付信息生成带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}
//微信支付step3 调用统一下单API，返回预付单信息（prepay_id）
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams
{
    NSString *prepayid = nil;
    
    //1.获取提交支付拼接的签名
    //微信支付step4 想获得prepayid需要由预支付信息生成带参数的签名包
    NSString *send  = [self genPackage:prePayParams];
    //输出Debug Info
    [debugInfo appendFormat:@"API链接:%@\n", payUrl];
    [debugInfo appendFormat:@"发送的xml:%@\n", send];
    
    //2.发送请求post xml数据
    NSData *res = [WXUtil httpSend:payUrl method:@"POST" data:send];
    
    //3.输出Debug Info
    [debugInfo appendFormat:@"服务器返回：\n%@\n\n",[[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding]];
    
    XMLHelper *xml  = [[XMLHelper alloc] autorelease];
    
    //4.开始解析
    [xml startParse:res];
    
    NSMutableDictionary *resParams = [xml getDict];

    //5.判断返回
    NSString *return_code   = [resParams objectForKey:@"return_code"];
    NSString *result_code   = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid    = [resParams objectForKey:@"prepay_id"];
                return_code = 0;
                
                [debugInfo appendFormat:@"获取预支付交易标示成功！\n"];
            }
        }else{
            last_errcode = 1;
            [debugInfo appendFormat:@"gen_sign=%@\n   _sign=%@\n",sign,send_sign];
            [debugInfo appendFormat:@"服务器返回签名验证错误！！！\n"];
        }
    }else{
        last_errcode = 2;
        [debugInfo appendFormat:@"接口返回错误！！！\n"];
    }

    return prepayid;
}
//微信支付step2 请求生成支付订单，返回信息（prepay_id,sign等）
- (NSMutableDictionary *)WXPayByTrade_no:(NSString *)tradeNo order_name:(NSString *)orderName andPrice:(NSString*)price
{
    //1.把预支付的商品信息存入字典
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    
    //开放平台appid
    [packageParams setObject: appid forKey:@"appid"];
    //商户号
    [packageParams setObject: mchid forKey:@"mch_id"];
    //支付设备号或门店号
    [packageParams setObject:@"APP-001" forKey:@"device_info"];
    //随机串
    [packageParams setObject: noncestr forKey:@"nonce_str"];
    //支付类型，固定为APP
    [packageParams setObject: @"APP" forKey:@"trade_type"];
    //订单描述，展示给用户
    [packageParams setObject: orderName forKey:@"body"];
    //支付结果异步通知
    [packageParams setObject: WeChat_Notify_URL forKey:@"notify_url"];
    //商户订单号
    [packageParams setObject: tradeNo forKey:@"out_trade_no"];
    //发器支付的机器ip
    [packageParams setObject: @"196.168.1.1" forKey:@"spbill_create_ip"];
    //订单金额，单位为分
    [packageParams setObject: price  forKey:@"total_fee"];
    
    
    //2.利用预支付字典参数请求微信统一下单API，获取prepayId（预支付交易会话标识）
    //微信支付step3 调用统一下单API，返回预付单信息（prepay_id）
    NSString *prePayid = [self sendPrepay:packageParams];
    
    
    //3.如果prePayid获得成功，说明预支付订单提交给微信成功，用prePayid等参数获得签名，把签名和需要的参数存入字典并返回
    if ( prePayid != nil) {
        
        //获取到prepayid后进行第二次签名
        NSString *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [WXUtil md5:time_stamp];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        
        package  = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: appid  forKey:@"appid"];
        [signParams setObject: nonce_str forKey:@"noncestr"];
        [signParams setObject: package forKey:@"package"];
        [signParams setObject: mchid forKey:@"partnerid"];
        [signParams setObject: time_stamp forKey:@"timestamp"];
        [signParams setObject: prePayid forKey:@"prepayid"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        
        //添加签名
        [signParams setObject: sign         forKey:@"sign"];
        
        [debugInfo appendFormat:@"第二步签名成功，sign＝%@\n",sign];
        
        //返回参数列表
        return signParams;
        
    }else{
        [debugInfo appendFormat:@"获取prepayid失败！\n"];
    }
    return nil;
}

@end
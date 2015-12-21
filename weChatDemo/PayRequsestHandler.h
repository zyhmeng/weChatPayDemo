

#import <Foundation/Foundation.h>
#import "WXUtil.h"
#import "ApiXml.h"
#import "Configing.h"


@interface PayRequsestHandler : NSObject{
	//预支付网关url地址
    NSString *payUrl;

    //lash_errcode;
    long     last_errcode;
	//debug信息
    NSMutableString *debugInfo;
    NSString *appid,*mchid,*spkey;
}
//初始化函数
-(BOOL) init:(NSString *)app_id mch_id:(NSString *)mch_id;
-(NSString *) getDebugifo;

//设置商户密钥
-(void) setKey:(NSString *)key;
//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict;
//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams;
//获取最后服务返回错误代码
-(long) getLasterrCode;

//支付
- (NSMutableDictionary *)WXPayByTrade_no:(NSString *)order_id order_name:(NSString *)orderName andPrice:(NSString*)price;

@end
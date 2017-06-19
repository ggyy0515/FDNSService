//
//  FDNSService.h
//  FDNS
//
//  Created by 曙华国际 on 16/9/12.
//  Copyright © 2016年 FDNS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 *  客户端所连接使用的代理协议
 */
typedef NS_ENUM(NSInteger, FDNSProxyType) {
    /*!
     *  使用http协议
     */
    FDNSProxyTypeHttp                   = 0,
    /*!
     *  使用socks协议
     */
    FDNSProxyTypeSocks5                 = 1,
    /*!
     *  使用阿朗sock5代理服务器
     */
    FDNSProxyTypeSocks5ProvideByAL      = 2,
};

@interface FDNSConfig : NSObject
/*!
 *  客户端的appID
 */
@property (nonatomic ,strong) NSString *appID;
/*!
 *  客户端的appKey
 */
@property (nonatomic ,strong) NSString *appKey;
/*!
 *  客户端的reqIP
 */
@property (nonatomic ,strong) NSString *reqIP;
/*!
 *  客户端的用户手机号
 */
@property (nonatomic ,strong) NSString *mobile;
/*!
 *  客户端的用户地理位置，可不传，默认为CGPointZero，格式为：(longitude,latitude)
 */
@property (nonatomic ,assign) CGPoint locationPoint;
/*!
 *  使用的代理协议  默认为FDNSProxyTypeHttp
 */
@property (nonatomic ,assign) FDNSProxyType proxyType;
/*!
 *  是否支持WiFi测试，该选项仅仅用来测试,正式环境需设置为NO 默认为NO
 */
@property (nonatomic ,assign) BOOL WLANDebugEnabled;
/*!
 *  是否打印网络请求URL，默认为NO
 */
@property (nonatomic ,assign) BOOL logRequestURL;
/**
 *网关配置的单例
 *@return 网关配置实例
 */
+ (FDNSConfig *)sharedInstance;

@end

@interface FDNSResult : NSObject
/*!
 *  错误编码
 */
@property (nonatomic, strong) NSString *result;
/*!
 *  错误描述
 */
@property (nonatomic, strong) NSString *msg;
/*!
 *  手机号码
 */
@property (nonatomic, strong) NSString *mobile;

@end

@interface FDNSProxyResult : FDNSResult

/*!
 *  会话ID
 */
@property (copy,nonatomic) NSString *userName;
/*!
 *  会话秘钥
 */
@property (copy,nonatomic) NSString *password;
/*!
 *  过期时间，精确到毫秒，在这个时间之后会话失效
 */
@property (assign,nonatomic) NSTimeInterval timeoutInterval;
/*!
 *  代理服务器IP地址
 */
@property (copy,nonatomic) NSString *serverIP;
/*!
 *  代理服务器端口号
 */
@property (assign,nonatomic) int serverPort;
/*!
 *  运营商类型 0:YD  1:LT  2:DX
 */
@property (assign,nonatomic) int operatorType;

@end

@protocol FDNSServiceDelegate <NSObject>
@optional

/*!
 *  服务开启后调用
 *
 *  @param result 返回结果
 */
- (void)FDNSServiceDidStart:(FDNSResult *)result;
/*!
 *  服务关闭后调用
 *
 *  @param result 返回结果
 */
- (void)FDNSServiceDidStop:(FDNSResult *)result;
/*!
 *  代理服务信息发生改变时调用
 *
 *  @param result 返回结果
 */
- (void)fdnsServiceUpdate:(FDNSProxyResult *)result;

@end


@interface FDNSService : NSObject

#pragma mark  初始化方法
/*!
 *  代理服务的单例
 *
 *  @return 代理服务实例
 */
+ (FDNSService *)sharedInstance;

#pragma mark  配置方法
/*!
 *  注册代理服务
 *
 *  @param appID    客户端的appID
 *  @param appKey   客户端的appKey
 *  @param reqIP    客户端的reqIP
 *  @param delegate 代理回调
 */
- (void)registerWithAppID:(NSString *)appID
               WithAppKey:(NSString *)appKey
                WithReqIP:(NSString *)reqIP
                 delegate:(id<FDNSServiceDelegate>)delegate;
/*!
 *  设置用户手机号
 *
 *  @param mobile 用户手机号
 */
- (void)setMobile:(NSString *)mobile;
/*!
 *  设置用户地理位置
 *
 *  @param point 用户地理位置
 */
- (void)setLocationPoint:(CGPoint)point;
/*!
 *  开启代理服务
 */
- (void)startService;
/*!
 *  关闭代理服务
 */
- (void)stopService;
#pragma mark  辅助方法
/*!
 *  查看当前是否需要开启代理服务
 *
 *  @return 是/否
 */
- (BOOL)isNeedProxy;
/*!
 *  返回HTTP协议的代理信息，以NSURLSessionConfiguration的形式返回，NSURLSession可以直接使用
 *
 *  @return  HTTP协议代理信息
 */
- (NSURLSessionConfiguration *)HTTPConnectionProxyConfiguration;

@end

@interface FDNSProtocol : NSURLProtocol

@end

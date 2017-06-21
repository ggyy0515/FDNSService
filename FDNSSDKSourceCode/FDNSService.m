//
//  FDNSService.m
//  FDNS
//
//  Created by 曙华国际 on 16/9/12.
//  Copyright © 2016年 FDNS. All rights reserved.
//

#import "FDNSService.h"
#import <CommonCrypto/CommonDigest.h>

#import "FDNSReachability.h"

#define URLHEADER                   @"http://fdns.szwisdom.cn/fdns-cc/"
#define PACKAGEID                   @"packageId000001"
#define FDNSProtocolKey             @"FDNSProtocolKey"

@implementation FDNSConfig

+ (FDNSConfig *)sharedInstance{
    static FDNSConfig *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _proxyType = FDNSProxyTypeHttp;
        _WLANDebugEnabled = NO;
        _locationPoint = CGPointZero;
        _logRequestURL = NO;
    }
    return self;
}

@end

@implementation FDNSResult

@end

@implementation FDNSProxyResult

@end

@interface FDNSService()

/*!
 *  是否已经开启了代理服务，默认为NO
 */
@property (assign,nonatomic) BOOL isStart;
/*!
 *  代理方法
 */
@property (weak,nonatomic) id<FDNSServiceDelegate> delegate;

@property (strong,nonatomic) FDNSProxyResult *proxyResult;

@end

@implementation FDNSService

#pragma mark  初始化方法

+ (FDNSService *)sharedInstance{
    static FDNSService *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _isStart = NO;
    }
    return self;
}

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
                 delegate:(id<FDNSServiceDelegate>)delegate{
    [FDNSConfig sharedInstance].appID = appID;
    [FDNSConfig sharedInstance].appKey = appKey;
    [FDNSConfig sharedInstance].reqIP = reqIP;
    self.delegate = delegate;
}

/*!
 *  设置用户手机号
 *
 *  @param mobile 用户手机号
 */
- (void)setMobile:(NSString *)mobile{
    [FDNSConfig sharedInstance].mobile = mobile;
}
/*!
 *  设置用户地理位置
 *
 *  @param point 用户地理位置
 */
- (void)setLocationPoint:(CGPoint)point{
    [FDNSConfig sharedInstance].locationPoint = point;
}
/*!
 *  开启代理服务
 */
- (void)startService{
    [self requestAppSign];
}

/*!
 *  关闭代理服务
 */
- (void)stopService{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    if (self.isStart) {
        [NSURLProtocol unregisterClass:[FDNSProtocol class]];
        
        FDNSResult *result = [[FDNSResult alloc] init];
        result.mobile = [FDNSConfig sharedInstance].mobile;
        result.result = @"0000";
        result.msg = @"关闭代理服务成功";
        [self.delegate FDNSServiceDidStop:result];
    }
    self.isStart = NO;
}
#pragma mark  辅助方法
/*!
 *  查看当前是否需要开启代理服务
 *
 *  @return 是/否
 */
- (BOOL)isNeedProxy{
    if (_isStart) {
        if ([FDNSConfig sharedInstance].WLANDebugEnabled) {
            return YES;
        }else{
            if ([[self getDeviceNetworkStatus] isEqualToString:@"1"]) {
                return NO;
            }else{
                return YES;
            }
        }
    }else{
        return NO;
    }
}
/*!
 *  返回HTTP协议的代理信息，以NSURLSessionConfiguration的形式返回，NSURLSession可以直接使用
 *
 *  @return  HTTP协议代理信息
 */
- (NSURLSessionConfiguration *)HTTPConnectionProxyConfiguration{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableArray * protocolsArray = [sessionConfiguration.protocolClasses mutableCopy];
    [protocolsArray insertObject:[FDNSProtocol class] atIndex:0];
    sessionConfiguration.protocolClasses = protocolsArray;
    return sessionConfiguration;
}

#pragma mark  私有方法
//MD5加密
- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    if (!srcString) {
        return @"";
    }
    const char *cStr = [srcString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString *resultStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return [resultStr lowercaseString];
}
//获取设备UUID
- (NSString *)getDeviceOpenUUID{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}
//获取当前网络状态
- (NSString *)getDeviceNetworkStatus{
    switch ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        case NotReachable: return @"0"; break;
        case ReachableViaWiFi: return @"1"; break;
        default: return @"4"; break;
    }
}

#pragma mark  接口请求方法
- (void)requestAppSign{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@auth/app",URLHEADER]];
    
    NSString *appID = [FDNSConfig sharedInstance].appID;
    NSString *appKey = [FDNSConfig sharedInstance].appKey;
    NSString *timestamp = [NSNumber numberWithInteger:([[NSDate date] timeIntervalSince1970] * 1000)].stringValue;
    NSString *iMei = [self getDeviceOpenUUID];
    NSString *sign = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@%@%@",appID,iMei,timestamp,appKey]];
    NSString *netType = [self getDeviceNetworkStatus];
    NSString *location = CGPointEqualToPoint([FDNSConfig sharedInstance].locationPoint, CGPointZero) ? @"" : [NSString stringWithFormat:@"%@,%@",@([FDNSConfig sharedInstance].locationPoint.x),@([FDNSConfig sharedInstance].locationPoint.y)];
    NSString *destinationIps = @"";
    NSString *nodeProtocal = @"1";
    
    NSDictionary *paramDic = @{
                               @"appId":appID,
                               @"userId":iMei,
                               @"netType":netType,
                               @"mobileNo":[FDNSConfig sharedInstance].mobile,
                               @"imei":iMei,
                               @"location":location,
                               @"reqIp":[FDNSConfig sharedInstance].reqIP,
                               @"destinationIps":destinationIps,
                               @"nodeProtocal":nodeProtocal,
                               @"sign":sign,
                               @"timestamp":timestamp
                               };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.f];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{@"Accept":@"application/json",
                                    @"Content-Type":@"application/json"};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:paramDic options:NSJSONWritingPrettyPrinted error:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError == nil) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"responseDict : %@",responseDict);
            
            NSInteger status = [responseDict[@"status"] integerValue];
            
            if (status == 1) {
                _proxyResult = [[FDNSProxyResult alloc] init];
                _proxyResult.mobile = [FDNSConfig sharedInstance].mobile;
                _proxyResult.result = @"";
                _proxyResult.msg = @"";
                _proxyResult.userName = responseDict[@"data"][@"username"];
                _proxyResult.password = responseDict[@"data"][@"password"];
                _proxyResult.serverIP = responseDict[@"data"][@"ip"];
                _proxyResult.serverPort = [responseDict[@"data"][@"port"] intValue];
                _proxyResult.timeoutInterval = [responseDict[@"data"][@"expireTime"] integerValue];
                NSString *operatorCode = responseDict[@"data"][@"operatorCode"];
                _proxyResult.operatorType = [operatorCode isEqualToString:@"YD"] ? 0 : ([operatorCode isEqualToString:@"LT"] ? 1 : 2);
                
                [self performSelector:@selector(startService) withObject:nil afterDelay:([responseDict[@"data"][@"expireTime"] integerValue] / 1000.f - [[NSDate date] timeIntervalSince1970] - 10.f)];
                
                [self.delegate fdnsServiceUpdate:_proxyResult];
                
                if (!self.isStart) {
                    [self.delegate FDNSServiceDidStart:_proxyResult];
                    
                    [NSURLProtocol registerClass:[FDNSProtocol class]];
                }
                
                self.isStart = YES;
            }else{
                FDNSResult *result = [[FDNSResult alloc] init];
                result.result = responseDict[@"error"][@"code"];
                result.msg = responseDict[@"error"][@"msg"];
                result.mobile = [FDNSConfig sharedInstance].mobile;
                [self.delegate FDNSServiceDidStart:result];
                [self stopService];
            }
        }else{
            FDNSResult *result = [[FDNSResult alloc] init];
            result.mobile = [FDNSConfig sharedInstance].mobile;
            result.result = @"0000";
            result.msg = @"请求代理鉴权参数失败";
            [self.delegate FDNSServiceDidStart:result];
            [self stopService];
        }
    }];
}

@end

@interface FDNSProtocol()<
    NSURLSessionDelegate
>
@end
@implementation FDNSProtocol{
    NSURLSession *m_session;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![[FDNSService sharedInstance] isNeedProxy]) {
        return NO;
    }
    if ([request.URL.host isEqualToString:@"fdns.szwisdom.cn"]) {//请求自带参数，不过代理
        return NO;
    }
    if ([NSURLProtocol propertyForKey:FDNSProtocolKey inRequest:request]){
        return NO;
    }
    NSString *scheme = request.URL.scheme.lowercaseString;
    
    FDNSProxyResult *proxyResult = [[FDNSService sharedInstance] valueForKey:@"proxyResult"];
    if (proxyResult.operatorType == 2 && [scheme isEqualToString:@"https"]) {//电信不支持免流
        return NO;
    }
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = request.mutableCopy;
    return [self configMutableReuestWithMutableReuest:mutableRequest];
}

+ (NSMutableURLRequest *)configMutableReuestWithMutableReuest:(NSMutableURLRequest *)request {
    FDNSProxyResult *proxyResult = [[FDNSService sharedInstance] valueForKey:@"proxyResult"];
    NSString *userAgent = [request.allHTTPHeaderFields objectForKey:@"User-Agent"];
    if (proxyResult.operatorType == 2) {//如果是电信
        if ([FDNSConfig sharedInstance].proxyType == FDNSProxyTypeHttp) {
            [request setValue:[NSString stringWithFormat:@"%@ %@",userAgent,[FDNSProtocol getUserAgentHttp:proxyResult WithUrl:request.URL.absoluteString]] forHTTPHeaderField:@"User-Agent"];
        }else{
            [request setValue:[NSString stringWithFormat:@"%@ %@",userAgent,[FDNSProtocol getUserAgentSocks:proxyResult]] forHTTPHeaderField:@"User-Agent"];
        }
    }else{
        [request setValue:[NSString stringWithFormat:@"%@ %@",userAgent,[FDNSProtocol getAuthorization:proxyResult]] forHTTPHeaderField:@"User-Agent"];
    }
    
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:FDNSProtocolKey inRequest:request];
    
    m_session = [NSURLSession sessionWithConfiguration:[self getSessionconfiguration] delegate:self delegateQueue:nil];
    [[m_session dataTaskWithRequest:request] resume];
    
    FDNSProxyResult *proxyResult = [[FDNSService sharedInstance] valueForKey:@"proxyResult"];
    
    if ([FDNSConfig sharedInstance].logRequestURL) {
        switch (proxyResult.operatorType) {
            case 0:{
                NSLog(@"移动代理服务访问URL : %@",request.URL.absoluteString);
            }
                break;
            case 1:{
                NSLog(@"联通代理服务访问URL : %@",request.URL.absoluteString);
            }
                break;
            case 2:{
                NSLog(@"电信代理服务访问URL : %@",request.URL.absoluteString);
            }
                break;
        }
    }
}

- (NSURLSessionConfiguration *)getSessionconfiguration{
    FDNSProxyResult *proxyResult = [[FDNSService sharedInstance] valueForKey:@"proxyResult"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    id hostKey;
    id portKey;
    NSString *enableKey;
    
    if ([FDNSConfig sharedInstance].proxyType == FDNSProxyTypeHttp) {
        hostKey = (id)kCFStreamPropertyHTTPProxyHost;
        portKey = (id)kCFStreamPropertyHTTPProxyPort;
        enableKey = @"HTTPEnable";
        if ([[[self.request.URL scheme] lowercaseString] isEqualToString:@"https"]) {
            hostKey = (id)kCFStreamPropertyHTTPSProxyHost;
            portKey = (id)kCFStreamPropertyHTTPSProxyPort;
            enableKey = @"HTTPSEnable";
        }
    }else{
        hostKey = (id)kCFStreamPropertySOCKSProxyHost;
        portKey = (id)kCFStreamPropertySOCKSProxyPort;
        enableKey = @"SOCKSEnable";
    }
    
    config.connectionProxyDictionary = @{
                                         enableKey:@YES,
                                         hostKey:proxyResult.serverIP,
                                         portKey:@(proxyResult.serverPort)
                                         };
    return config;
}

+ (NSString *)getAuthorization:(FDNSProxyResult *)result{
    return [NSString stringWithFormat:@"FdnsUA(%@/V1.0)",result.userName];
}
//电信HTTP加密
+ (NSString *)getUserAgentHttp:(FDNSProxyResult *)result WithUrl:(NSString *)url{
    NSArray *urlArray = [url componentsSeparatedByString:@"/"];
    if (urlArray.count > 3) {
        url = [url substringFromIndex:(((NSString *)urlArray[2]).length + 7)];
    }
    NSString *key = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@|%@|%@",result.userName,result.password,url]];
    return [NSString stringWithFormat:@"zhpticg(%@/%@/api1.7)",result.userName,key];
}
//电信SOCKS加密
+ (NSString *)getUserAgentSocks:(FDNSProxyResult *)result{
    NSString *key = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@|%@|%@",result.userName,result.password,result.serverIP]];
    return [NSString stringWithFormat:@"zhpticg(%@/%@/api1.7)",result.userName,key];
}

+ (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    if (!srcString) {
        return @"";
    }
    const char *cStr = [srcString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString *resultStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return [resultStr lowercaseString];
}

- (void)stopLoading {
    [m_session invalidateAndCancel];
    m_session = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 处理每次接收的数据
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成,成功或者失败的处理
    [self.client URLProtocolDidFinishLoading:self];
    [self.client URLProtocol:self didFailWithError:error];
}

@end
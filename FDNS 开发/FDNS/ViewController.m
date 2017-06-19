//
//  ViewController.m
//  FDNS
//
//  Created by 曙华国际 on 16/8/18.
//  Copyright © 2016年 FDNS. All rights reserved.
//

#import "ViewController.h"
#import "typeViewController.h"

#import "FDNSService.h"

#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "YYWebImage.h"
#import "YYWebImage/YYImageCache.h"

#import <CFNetwork/CFHTTPStream.h>
//#import "<CFNetwork/CFHTTPStream.h>"

@interface ViewController ()<
    UIAlertViewDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    FDNSServiceDelegate
>
@property (copy,nonatomic) NSString *appID;

@property (copy,nonatomic) NSString *appKey;

@property (copy,nonatomic) NSString *reqIP;

@property (copy,nonatomic) NSString *account;

@property (assign,nonatomic) BOOL type;

@property (strong,nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appID = @"test02_api";
    self.appKey = @"124b5c50f01e418d8e624c01d8eda5d0";
    self.reqIP = @"127.0.0.1";
//    self.account = @"13480928947";//YD
//    self.account = @"18938831159";//DX
    self.account = @"18565857403";//DX
    self.type = YES;
    
    
    [FDNSConfig sharedInstance].logRequestURL = YES;
    [FDNSConfig sharedInstance].WLANDebugEnabled = YES;
    
    self.navigationItem.title = @"FDNSServer  Demo";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backGround"]];
    [self.view addSubview:_tableView];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 0.f, CGRectGetWidth(self.view.frame) - 20.f, 40.f)];
        imageView.image = [[UIImage imageNamed:@"ben_backGround"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f) resizingMode:UIImageResizingModeTile];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0.f, CGRectGetWidth(self.view.frame) - 20.f, 40.f)];
        label.tag = 101;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    UILabel *label = [cell.contentView viewWithTag:101];
    
    switch (indexPath.row) {
        case 0:{
            label.text = self.type ? @"配置参数（当前企业配置）" : @"配置参数（当前个人配置）";
        }
            break;
        case 1:{
            label.text = self.type ? @"开启企业免流代理" : @"开启个人免流代理";
        }
            break;
        case 2:{
            label.text = self.type ? @"关闭企业免流代理" : @"关闭个人免流代理";
        }
            break;
        case 3:{
            label.text = @"测试API请求";
        }
            break;
        case 4:{
            label.text = @"测试图片加载";
        }
            break;
        case 5:{
            label.text = @"测试文件下载";
        }
            break;
        case 6:{
            label.text = @"测试Webview";
        }
            break;
        case 7:{
            label.text = @"新增白名单";
        }
            break;
        case 8:{
            label.text = @"查询白名单";
        }
            break;
        case 9:{
            label.text = @"删除白名单";
        }
            break;
        case 10:{
            label.text = @"流量查询";
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            typeViewController *vc = [[typeViewController alloc] init];
            vc.appID = self.appID;
            vc.appKey = self.appKey;
            vc.reqIP = self.reqIP;
            [self.navigationController pushViewController:vc animated:YES];
            
            __weak typeof(self) weakSelf = self;
            
            [vc setTypeChangedBlock:^(NSString *appid,NSString *appKey,NSString *reqIP,BOOL type) {
                weakSelf.appID = appid;
                weakSelf.appKey = appKey;
                weakSelf.reqIP = reqIP;
                weakSelf.type = type;
                [weakSelf.tableView reloadData];
            }];
        }
            break;
        case 1:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入您的手机号" message:@"用户免流时必传，企业免流可不传" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = self.account;
            alertView.tag = 101;
            [alertView show];
        }
            break;
        case 2:{
            [[FDNSService sharedInstance] stopService];
        }
            break;
        case 3:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入测试API地址" message:@"API请求方式必须为POST" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = @"http://demo.ecapp.cc/mec/api/v1/common/login";
            alertView.tag = 102;
            [alertView show];
        }
            break;
        case 4:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入测试图片地址" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = @"http://love.doghouse.com.tw/image/wallpaper/011102/bf1554.jpg";
            alertView.tag = 103;
            [alertView show];
        }
            break;
        case 5:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入测试下载地址" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = @"http://love.doghouse.com.tw/image/wallpaper/011102/bf1554.jpg";
            alertView.tag = 104;
            [alertView show];
            
        }
            break;
        case 6:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入测试webview地址" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = @"http://nbweb.ky-express.com/h5/advertisement/2d397b62afe3cc4c8599b8cffefced6b.html";
            alertView.tag = 105;
            [alertView show];
        }
            break;
        default:{
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.f;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101 && buttonIndex == 1) {
        self.account = [alertView textFieldAtIndex:0].text;
        [[FDNSService sharedInstance] registerWithAppID:_appID WithAppKey:_appKey WithReqIP:_reqIP delegate:self];
        [[FDNSService sharedInstance] setMobile:_account];
        [[FDNSService sharedInstance] startService];
    }else if (alertView.tag == 102 && buttonIndex == 1){
        AFHTTPSessionManager *manager ;
        if ([[FDNSService sharedInstance] isNeedProxy]) {
            manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[[FDNSService sharedInstance] HTTPConnectionProxyConfiguration]];
        }else{
            manager = [AFHTTPSessionManager manager];
        }
        
        [manager POST:[alertView textFieldAtIndex:0].text parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@",responseObject);
            [SVProgressHUD showInfoWithStatus:@"请求成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            [SVProgressHUD showInfoWithStatus:@"请求失败"];
        }];
    }else if (alertView.tag == 103 && buttonIndex == 1){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.f, 100.f, 100.f, 100.f)];
        imageView.backgroundColor = [UIColor greenColor];
        [imageView yy_setImageWithURL:[NSURL URLWithString:[alertView textFieldAtIndex:0].text] placeholder:[UIImage imageNamed:@"backGround"]];
        [self.view addSubview:imageView];
        YYImageCache *cache = [YYWebImageManager sharedManager].cache;
        [cache.memoryCache removeAllObjects];
        [cache.diskCache removeAllObjects];
    }else if (alertView.tag == 104 && buttonIndex == 1){
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[alertView textFieldAtIndex:0].text] cachePolicy:1 timeoutInterval:6];
        
        AFHTTPSessionManager *manager ;
        if ([[FDNSService sharedInstance] isNeedProxy]) {
            manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[[FDNSService sharedInstance] HTTPConnectionProxyConfiguration]];
        }else{
            manager = [AFHTTPSessionManager manager];
        }
        
        [[manager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            return url;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error == nil) {
                [SVProgressHUD showInfoWithStatus:@"下载成功"];
            }else{
                [SVProgressHUD showInfoWithStatus:@"下载失败"];
            }
        }] resume];
        
    }else if (alertView.tag == 105 && buttonIndex == 1){
        UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.frame];
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[alertView textFieldAtIndex:0].text]]];
        [self.view addSubview:webview];
        self.tableView.hidden = YES;
    }

}

- (void)FDNSServiceDidStart:(FDNSResult *)result{

}
- (void)FDNSServiceDidStop:(FDNSResult *)result{

}
- (void)fdnsServiceUpdate:(FDNSProxyResult *)result{

}

@end

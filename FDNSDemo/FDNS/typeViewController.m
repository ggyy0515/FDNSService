//
//  typeViewController.m
//  FDNS
//
//  Created by 曙华国际 on 16/8/22.
//  Copyright © 2016年 FDNS. All rights reserved.
//

#import "typeViewController.h"
#import "SVProgressHUD.h"

@interface typeViewController ()

@property (assign,nonatomic) BOOL type;

@end

@implementation typeViewController{
    UITextField *appidTextField;
    UITextField *appkeyTextField;
    UITextField *reqipTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backGround"]];
    
    UIButton *enterpriseBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.f, 74.f, (CGRectGetWidth(self.view.frame) - 30) / 2.f, 44.f)];
    [enterpriseBtn setTitle:@"企业免流模式" forState:UIControlStateNormal];
    [enterpriseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterpriseBtn setBackgroundImage:[[UIImage imageNamed:@"ben_backGround"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f) resizingMode:UIImageResizingModeTile] forState:UIControlStateNormal];
    [self.view addSubview:enterpriseBtn];
    [enterpriseBtn addTarget:self action:@selector(enterpriseClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *personalBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.f + CGRectGetMaxX(enterpriseBtn.frame), 74.f, CGRectGetWidth(enterpriseBtn.frame), 44.f)];
    [personalBtn setTitle:@"用户免流模式" forState:UIControlStateNormal];
    [personalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [personalBtn setBackgroundImage:[[UIImage imageNamed:@"ben_backGround"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f) resizingMode:UIImageResizingModeTile] forState:UIControlStateNormal];
    [self.view addSubview:personalBtn];
    [personalBtn addTarget:self action:@selector(personalClick:) forControlEvents:UIControlEventTouchUpInside];
    
    appidTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(personalBtn.frame) + 10.f, CGRectGetWidth(self.view.frame) - 20.f, 44.f)];
    appidTextField.textColor = [UIColor whiteColor];
    appidTextField.placeholder = @"请输入APPID";
    appidTextField.text = self.appID;
    [appidTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:appidTextField];
    
    appkeyTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(appidTextField.frame) + 10.f, CGRectGetWidth(self.view.frame) - 20.f, 44.f)];
    appkeyTextField.textColor = [UIColor whiteColor];
    appkeyTextField.placeholder = @"请输入APPKEY";
    appkeyTextField.text = self.appKey;
    [appkeyTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:appkeyTextField];
    
    reqipTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(appkeyTextField.frame) + 10.f, CGRectGetWidth(self.view.frame) - 20.f, 44.f)];
    reqipTextField.textColor = [UIColor whiteColor];
    reqipTextField.placeholder = @"请输入REQIP";
    reqipTextField.text = self.reqIP;
    [reqipTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:reqipTextField];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(reqipTextField.frame) + 10.f, CGRectGetWidth(self.view.frame) - 20.f, 44.f)];
    [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[[UIImage imageNamed:@"ben_backGround"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f) resizingMode:UIImageResizingModeTile] forState:UIControlStateNormal];
    [self.view addSubview:saveBtn];
    [saveBtn addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)saveClick:(UIButton *)sender{
    if (appkeyTextField.text.length == 0 || appidTextField.text.length == 0 || reqipTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"参数不能为空"];
        return;
    }
    if (self.typeChangedBlock) {
        self.typeChangedBlock(appidTextField.text,appkeyTextField.text,reqipTextField.text,_type);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)enterpriseClick:(UIButton *)sender{
    appidTextField.text = @"test02_api";
    appkeyTextField.text = @"107b6adffa0149d0808c5b9f60c29684";
    reqipTextField.text = @"127.0.0.1";
    _type = YES;
}

- (void)personalClick:(UIButton *)sender{
    appidTextField.text = @"test03_api";
    appkeyTextField.text = @"a44bb3a271464c37822ea03680cfdadc";
    reqipTextField.text = @"127.0.0.1";
    _type = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

@end

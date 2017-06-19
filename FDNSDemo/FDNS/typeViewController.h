//
//  typeViewController.h
//  FDNS
//
//  Created by 曙华国际 on 16/8/22.
//  Copyright © 2016年 FDNS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface typeViewController : UIViewController

@property (copy,nonatomic) NSString *appID;

@property (copy,nonatomic) NSString *appKey;

@property (copy,nonatomic) NSString *reqIP;

@property (copy,nonatomic) void (^typeChangedBlock)(NSString *appid,NSString *appKey,NSString *reqIP,BOOL type);

@end

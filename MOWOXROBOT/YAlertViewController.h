//
//  YAlertViewController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^leftBlock)(void);
typedef void(^rightBlock)(void);

@interface YAlertViewController : UIViewController
@property (nonatomic) float WScale_alert;
@property (nonatomic) float HScale_alert;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic) leftBlock lBlock;
@property (nonatomic) rightBlock rBlock;

- (void)showView;
@end

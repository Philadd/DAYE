//
//  YAlertViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/8/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YAlertViewController.h"

@interface YAlertViewController ()

@property (nonatomic, strong) UIView *alertView;

@end

@implementation YAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (UIView *)alertView{
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.frame = CGRectMake(52.5 / _WScale_alert, 172 / _HScale_alert, 270 / _WScale_alert, 203 / _HScale_alert);
        _alertView.center = self.view.center;
        _alertView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _alertView.layer.cornerRadius = 10.f;
        [self.view addSubview:_alertView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(44 / _WScale_alert,20 / _HScale_alert,182 / _WScale_alert,21 / _HScale_alert);
        _titleLabel.text = @"";
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        [_alertView addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.frame = CGRectMake(16 / _WScale_alert,57 / _HScale_alert,238 / _WScale_alert,42 / _HScale_alert);
        _messageLabel.text = @"";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _messageLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        [_alertView addSubview:_messageLabel];
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(15 / _WScale_alert,129 / _HScale_alert,114 / _WScale_alert,44 / _HScale_alert);
        [_leftBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        [_leftBtn setTitle:LocalString(@"") forState:UIControlStateNormal];
        [_leftBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_leftBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [_leftBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f / _HScale_alert];
        [_leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_leftBtn];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(141 / _WScale_alert,129 / _HScale_alert,114 / _WScale_alert,44 / _HScale_alert);
        [_rightBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [_rightBtn setTitle:LocalString(@"") forState:UIControlStateNormal];
        [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_rightBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [_rightBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f / _HScale_alert];
        [_rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_rightBtn];
    }
    return _alertView;
}

- (void)leftAction{
    if (self.lBlock) {
        self.lBlock();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)rightAction{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.rBlock) {
        self.rBlock();
    }
}

- (void)showView{
    _alertView = [self alertView];
}

@end

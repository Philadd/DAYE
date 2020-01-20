//
//  RobotRunTimeViewController.m
//  MOWOXROBOT
//
//  Created by 安建伟 on 2019/11/1.
//  Copyright © 2019 yusz. All rights reserved.
//

#import "RobotRunTimeViewController.h"

@interface RobotRunTimeViewController ()

@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;
///@brife 机器时间提示
@property (nonatomic,strong) UILabel *motorWorkTime;
@property (nonatomic,strong) UILabel *motorRunningTime;
@property (nonatomic,strong) UILabel *motorOnTime;
@property (nonatomic,strong) UILabel *bladeUserTime;
@property (nonatomic,strong) UIButton *resetBladeUserTimeBtn;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RobotRunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = LocalString(@"Time of robot");
    _timer = [self timer];
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    [self viewLayoutSet];
    
    UIButton *refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [refreshButton setTitle:LocalString(@"Refresh") forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
    self.navigationItem.rightBarButtonItem= rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveBladeUserTime:) name:@"recieveBladeUserTime" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveRobotTimeContent:) name:@"recieveRobotTimeContent" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveBladeUserTime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveRobotTimeContent" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewLayoutSet{
    
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _resetBladeUserTimeBtn = [UIButton buttonWithTitle:LocalString(@"Reset Time") titleColor:[UIColor blackColor]];
    [_resetBladeUserTimeBtn setButtonStyle1];
    [self.view addSubview:_resetBladeUserTimeBtn];
    [_resetBladeUserTimeBtn addTarget:self action:@selector(goResetTime) forControlEvents:UIControlEventTouchUpInside];
    
    _motorWorkTime =[[UILabel alloc] init];
    _motorWorkTime.textColor = [UIColor blackColor];
    _motorWorkTime.backgroundColor = [UIColor clearColor];
    _motorWorkTime.font = [UIFont systemFontOfSize:19.0];
    _motorWorkTime.text = @"";
    _motorWorkTime.textAlignment = NSTextAlignmentCenter;
    _motorWorkTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_motorWorkTime];
    
    [_motorWorkTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 23/HScale));
        make.top.equalTo(self.view.mas_top).offset(yAutoFit(200));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    _motorRunningTime =[[UILabel alloc] init];
    _motorRunningTime.textColor = [UIColor blackColor];
    _motorRunningTime.backgroundColor = [UIColor clearColor];
    _motorRunningTime.font = [UIFont systemFontOfSize:19.0];
    _motorRunningTime.text = @"";
    _motorRunningTime.textAlignment = NSTextAlignmentCenter;
    _motorRunningTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_motorRunningTime];
    
    [_motorRunningTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 23/HScale));
        make.top.equalTo(self.motorWorkTime.mas_bottom).offset(yAutoFit(30));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    _motorOnTime =[[UILabel alloc] init];
    _motorOnTime.textColor = [UIColor blackColor];
    _motorOnTime.backgroundColor = [UIColor clearColor];
    _motorOnTime.font = [UIFont systemFontOfSize:19.0];
    _motorOnTime.text = @"";
    _motorOnTime.textAlignment = NSTextAlignmentCenter;
    _motorOnTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_motorOnTime];
    
    [_motorOnTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 23/HScale));
        make.top.equalTo(self.motorRunningTime.mas_bottom).offset(yAutoFit(30));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    _bladeUserTime =[[UILabel alloc] init];
    _bladeUserTime.textColor = [UIColor blackColor];
    _bladeUserTime.backgroundColor = [UIColor clearColor];
    _bladeUserTime.font = [UIFont systemFontOfSize:19.0];
    _bladeUserTime.text = @"";
    _bladeUserTime.textAlignment = NSTextAlignmentCenter;
    _bladeUserTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_bladeUserTime];
    
    [_bladeUserTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 23/HScale));
        make.top.equalTo(self.motorOnTime.mas_bottom).offset(yAutoFit(30));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_resetBladeUserTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.bladeUserTime.mas_bottom).offset(ScreenHeight * 0.08);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getRobotTimeContent) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate date]];
    }
    return _timer;
}

- (void)getRobotTimeContent
{
    [SVProgressHUD show];
    //子线程延时1s
    double delayInSeconds = 1.0;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, mainQueue, ^{
        NSLog(@"延时执行的1秒");
    });
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x1f];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)refresh{
    [self getRobotTimeContent];
}

- (void)goResetTime
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"Are you sure?")preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"action = %@",action);
        //清零时间
        [self restBladeTime];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"action = %@",action);
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)restBladeTime{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x01]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x1f];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}


- (void)recieveRobotTimeContent:(NSNotification *)nsnotification
{
    [SVProgressHUD dismiss];
    //停掉重发机制
    [_timer setFireDate:[NSDate distantFuture]];
    
    NSDictionary *userInfo = [nsnotification userInfo];
    NSString *motorWorkTime = [userInfo objectForKey:@"motorWorkTime"];
    NSString *motorRunningTime = [userInfo objectForKey:@"motorRunningTime"];
    NSString *onTime = [userInfo objectForKey:@"onTime"];
    dispatch_async(dispatch_get_main_queue(),^{
        self.motorWorkTime.text = [NSString stringWithFormat:@"%@:%@",LocalString(@"Walk Motor"),motorWorkTime];
        self.motorRunningTime.text = [NSString stringWithFormat:@"%@:%@",LocalString(@"Blade Motor"),motorRunningTime];
        self.motorOnTime.text = [NSString stringWithFormat:@"%@:%@",LocalString(@"Work time"),onTime];
    });
    
}
- (void)recieveBladeUserTime:(NSNotification *)nsnotification
{
    NSDictionary *userInfo = [nsnotification userInfo];
    NSString *bladeUserTime = [userInfo objectForKey:@"bladeUserTimeStr"];;
    dispatch_async(dispatch_get_main_queue(),^{
        self.bladeUserTime.text = [NSString stringWithFormat:@"%@:%@",LocalString(@"Blade Using Time"),bladeUserTime];
    });
    
}


- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  MowerControlViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/29.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "MowerControlViewController.h"
#import "BluetoothDataManage.h"
#import "SettingViewController.h"
#import "AlertsViewController.h"
#import "RobotRunTimeViewController.h"

@interface MowerControlViewController ()
///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *startButton;
@property (strong, nonatomic)  UIButton *stopButton;
@property (strong, nonatomic)  UIButton *alertsButton;
@property (strong, nonatomic)  UIButton *settingButton;
@property (strong, nonatomic)  UIButton *timeRobotButton;
///@brife 错误日志提示
@property (nonatomic,strong) NSString *errorTime;
@property (nonatomic,strong) NSString *errorAlert;

///@brife 机器时间提示
@property (nonatomic,strong) NSString *motorWorkTime;
@property (nonatomic,strong) NSString *motorRunningTime;
@property (nonatomic,strong) NSString *motorOnTime;

@end

@implementation MowerControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
        
    //解决navigationitem标题右偏移
//    NSArray *viewControllerArray = [self.navigationController viewControllers];
//    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
//    UIViewController *previous;
//    if (previousViewControllerIndex >= 0) {
//        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
//        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
//                                                     initWithTitle:@""
//                                                     style:UIBarButtonItemStylePlain
//                                                     target:self
//                                                     action:nil];
//    }
    self.navigationItem.title = LocalString(@"Robot Control");

    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    [self viewLayoutSet];
    if ([BluetoothDataManage shareInstance].versionupdate >= 268) {
        _alertsButton.hidden = NO;
        
        [_timeRobotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.alertsButton.mas_bottom).offset(ScreenHeight * 0.05);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else{
        _alertsButton.hidden = YES;
        
        [_timeRobotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.settingButton.mas_bottom).offset(ScreenHeight * 0.05);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    //暂时隐藏
    _timeRobotButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.settingButton addTarget:self action:@selector(goSettingView) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAlertsContent:) name:@"recieveAlertsContent" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveAlertsContent" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewLayoutSet{
    
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _startButton = [UIButton buttonWithTitle:LocalString(@"Start") titleColor:[UIColor blackColor]];
    _stopButton = [UIButton buttonWithTitle:LocalString(@"Stop") titleColor:[UIColor blackColor]];
    _alertsButton = [UIButton buttonWithTitle:LocalString(@"Error Memory") titleColor:[UIColor blackColor]];
    _settingButton = [UIButton buttonWithTitle:LocalString(@"Setting") titleColor:[UIColor blackColor]];
    _timeRobotButton = [UIButton buttonWithTitle:LocalString(@"Time Statistics") titleColor:[UIColor blackColor]];
    [_startButton setButtonStyle1];
    [_stopButton setButtonStyle1];
    [_alertsButton setButtonStyle1];
    [_settingButton setButtonStyle1];
    [_timeRobotButton setButtonStyle1];
    [self.view addSubview:_startButton];
    [self.view addSubview:_stopButton];
    [self.view addSubview:_alertsButton];
    [self.view addSubview:_settingButton];
    [self.view addSubview:_timeRobotButton];
    
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [_stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [_alertsButton addTarget:self action:@selector(showAlert:) forControlEvents:UIControlEventTouchUpInside];
    [_timeRobotButton addTarget:self action:@selector(showTime:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.02 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.02 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.startButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.stopButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_alertsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.settingButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

}


#pragma mark - mower control

- (void)start
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"Are you sure to go to work?")preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"action = %@",action);
        
        NSMutableArray *dataContent = [[NSMutableArray alloc] init];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        
        [self.bluetoothDataManage setDataType:0x01];
        [self.bluetoothDataManage setDataContent: dataContent];
        [self.bluetoothDataManage sendBluetoothFrame];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"action = %@",action);
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)stop
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x01]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x01];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}
//最近一次日志报错
- (void)showAlert:(UIButton *)sender {
    [self getAlertContent];
}

- (void)showTime:(UIButton *)sender {
    RobotRunTimeViewController *RobotVC = [[RobotRunTimeViewController alloc]init];
    [self.navigationController pushViewController:RobotVC animated:YES];
}

#pragma mark - get alert contents
- (void)getAlertContent
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x1e];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveAlertsContent:(NSNotification *)nsnotification
{
    NSDictionary *userInfo = [nsnotification userInfo];
    NSNumber *wrongContent = [userInfo objectForKey:@"wrongContent"];
    NSString *dateLabel = [userInfo objectForKey:@"dateLabel"];
    self.errorTime = [NSString stringWithFormat:@"%@", dateLabel];
    if ([wrongContent intValue] == 0xff) {
        self.errorTime = @"";
    }
    switch ([wrongContent intValue]) {
        case 0x42: //Battery Error
        {
            self.errorAlert = LocalString(@"Battery Error");
        }
            break;
        case 0x4e: //Signal Error
        {
            self.errorAlert = LocalString(@"Signal Error");
        }
            break;
        case 0x4c: //Mower Lifted
        {
            self.errorAlert = LocalString(@"Mower Lifted");
        }
            break;
        case 0x54: //Mower tilted
        {
            self.errorAlert = LocalString(@"Mower tilted");
        }
            break;
        case 0x52: //Rolling over
        {
            self.errorAlert = LocalString(@"Rolling over");
        }
            break;
        case 0x58: //Mower trapped
        {
            self.errorAlert = LocalString(@"Mower trapped");
        }
            break;
        case 0x43: //Motor over current
        {
            self.errorAlert = LocalString(@"Motor over current");
        }
            break;
        case 0x4d: //Motor Fault
        {
            self.errorAlert = LocalString(@"Motor Fault");
        }
            break;
        case 0x53: //Bat Temp.abnormal
        {
            self.errorAlert = LocalString(@"Bat Temp.abnormal");
        }
            break;
        case 0x50: //PCB Over temperature
        {
            self.errorAlert = LocalString(@"PCB Over temperature");
        }
            break;
        default:
        {
            self.errorAlert = LocalString(@"Errors that do not exist");
        }
            break;
    }
    //提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.errorTime message:self.errorAlert preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"OK") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)goSettingView{

    SettingViewController *setVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setVC animated:YES];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

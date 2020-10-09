//
//  SettingViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "SettingViewController.h"
#import "BluetoothDataManage.h"
#import "GeneralsettingLanguageViewController.h"
#import "GeneralsettingTimeViewController.h"
#import "WorkTimeSettingViewController.h"
#import "PincodeSettingViewController.h"
#import "MowerSettingViewController.h"
#import "FirmwareViewController.h"
#import "SecondarySettingViewController.h"
#import "WorkTimeSettingVC_268.h"
#import "OldFirmwareViewController.h"
#import "MowerSetingVC_type4.h"

@interface SettingViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *LanguageButton;
@property (strong, nonatomic)  UIButton *TimeButton;
@property (strong, nonatomic)  UIButton *WorktimeButton;
@property (strong, nonatomic)  UIButton *PinButton;
@property (strong, nonatomic)  UIButton *mowerButton;
@property (strong, nonatomic)  UIButton *updateButton;
@property (strong, nonatomic)  UIButton *secondaryButton;

@end

@implementation SettingViewController
static int latestVersion_4 =  402;//更新页面 同时修改！！
static int latestVersion = 273;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"Setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    
    if ([BluetoothDataManage shareInstance].version1 == 4) {
        if ([BluetoothDataManage shareInstance].versionupdate < latestVersion_4) {
            _updateButton.hidden = NO;
            
        }else{
            _updateButton.hidden = YES;
        }
    }else if ([BluetoothDataManage shareInstance].version1 == 2){
        
        if ([BluetoothDataManage shareInstance].versionupdate < latestVersion) {
            _updateButton.hidden = NO;
//            if ([BluetoothDataManage shareInstance].versionupdate <= 268) {
//                _updateButton.hidden = YES;
//            }
        }else{
            _updateButton.hidden = YES;
        }
    }
    
    NSLog(@"版本号%d",[BluetoothDataManage shareInstance].versionupdate);
    //分区按钮显示
    if ([BluetoothDataManage shareInstance].sectionvalve == 0) {
        _secondaryButton.hidden = YES;
        
        [_updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.PinButton.mas_bottom).offset(ScreenHeight * 0.05);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
    }else{
        _secondaryButton.hidden = NO;
        
        [_updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.secondaryButton.mas_bottom).offset(ScreenHeight * 0.05);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    NSLog(@"分区数值%d",[BluetoothDataManage shareInstance].sectionvalve);
    NSLog(@"设备数值%d",[BluetoothDataManage shareInstance].deviceType);
    NSLog(@"更新的版本%d",[BluetoothDataManage shareInstance].versionupdate);
    //延时1.0秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //蓝牙的数据间隔大于1秒
        [self setMowerTime];
        
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet
{
    if (self.rdv_tabBarController.selectedIndex == 2) {
        UIImage *image = [UIImage imageNamed:@"返回1"];
        [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    }else if (self.rdv_tabBarController.selectedIndex == 1){
        UIImage *image = [UIImage imageNamed:@"返回1"];
        [self addLeftBarButtonWithImage:image action:@selector(backAction1)];
    }
    
    _LanguageButton = [UIButton buttonWithTitle:LocalString(@"Language setting") titleColor:[UIColor blackColor]];
    //_TimeButton = [UIButton buttonWithTitle:LocalString(@"Time setting") titleColor:[UIColor blackColor]];
    _WorktimeButton = [UIButton buttonWithTitle:LocalString(@"Working time setting") titleColor:[UIColor blackColor]];
    _PinButton = [UIButton buttonWithTitle:LocalString(@"PIN setting") titleColor:[UIColor blackColor]];
    _mowerButton = [UIButton buttonWithTitle:LocalString(@"Robot setting") titleColor:[UIColor blackColor]];
    _updateButton = [UIButton buttonWithTitle:LocalString(@"Update Robot's Firmware") titleColor:[UIColor blackColor]];
    _secondaryButton = [UIButton buttonWithTitle:LocalString(@"Multi-Area-Mowing") titleColor:[UIColor blackColor]];
    _updateButton.hidden = YES;
    [_LanguageButton setButtonStyle1];
    [_TimeButton setButtonStyle1];
    [_WorktimeButton setButtonStyle1];
    [_PinButton setButtonStyle1];
    [_mowerButton setButtonStyle1];
    [_updateButton setButtonStyle1];
    [_secondaryButton setButtonStyle1];
    [_LanguageButton addTarget:self action:@selector(languageSet) forControlEvents:UIControlEventTouchUpInside];
    //[_TimeButton addTarget:self action:@selector(timeSet) forControlEvents:UIControlEventTouchUpInside];
    [_WorktimeButton addTarget:self action:@selector(worktimeSet) forControlEvents:UIControlEventTouchUpInside];
    [_PinButton addTarget:self action:@selector(pinSet) forControlEvents:UIControlEventTouchUpInside];
    [_mowerButton addTarget:self action:@selector(mowerSet) forControlEvents:UIControlEventTouchUpInside];
    [_updateButton addTarget:self action:@selector(updateWare) forControlEvents:UIControlEventTouchUpInside];
    [_secondaryButton addTarget:self action:@selector(secondarySet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_LanguageButton];
    //[self.view addSubview:_TimeButton];
    [self.view addSubview:_WorktimeButton];
    [self.view addSubview:_PinButton];
    [self.view addSubview:_mowerButton];
    [self.view addSubview:_updateButton];
    [self.view addSubview:_secondaryButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_LanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_LanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    //    [_TimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
    //        make.top.equalTo(self.LanguageButton.mas_bottom).offset(ScreenHeight * 0.05);
    //        make.centerX.equalTo(self.view.mas_centerX);
    //    }];
    [_WorktimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.LanguageButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_mowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.WorktimeButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_PinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.mowerButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_secondaryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.PinButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    
}
//校准机器时间
- (void)setMowerTime{
    NSDate *date = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];    //IOS 8 之后
    NSUInteger integer = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dataCom = [currentCalendar components:integer fromDate:date];
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom year] / 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom year] % 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom month]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom day]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom hour]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom minute]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x02];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}
#pragma mark - ViewController
- (void)languageSet{
    GeneralsettingLanguageViewController *VC = [[GeneralsettingLanguageViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)timeSet{
    GeneralsettingTimeViewController *VC = [[GeneralsettingTimeViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)worktimeSet{
    
    if ([BluetoothDataManage shareInstance].versionupdate >= 268) {
        WorkTimeSettingViewController *VC = [[WorkTimeSettingViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        
    }else{
        WorkTimeSettingVC_268 *VC_268 = [[WorkTimeSettingVC_268 alloc] init];
        [self.navigationController pushViewController:VC_268 animated:YES];
    }
    
    
}

- (void)pinSet{
    PincodeSettingViewController *VC = [[PincodeSettingViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)mowerSet{
    if ([BluetoothDataManage shareInstance].version1 == 4) {
        MowerSetingVC_type4 *typeVC = [[MowerSetingVC_type4 alloc] init];
        [self.navigationController pushViewController:typeVC animated:YES];
    }else{
        MowerSettingViewController *VC = [[MowerSettingViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}
- (void)secondarySet{
    SecondarySettingViewController *VC = [[SecondarySettingViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (void)backAction{
    self.rdv_tabBarController.selectedIndex = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingVCBack" object:nil userInfo:nil];
}

- (void)backAction1{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateWare{
    
    if ([BluetoothDataManage shareInstance].version1 == 4) {
        FirmwareViewController *VC = [[FirmwareViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        OldFirmwareViewController *OldVC = [[OldFirmwareViewController alloc] init];
        [self.navigationController pushViewController:OldVC animated:YES];
        
    }
}

@end

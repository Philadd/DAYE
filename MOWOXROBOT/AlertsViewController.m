//
//  AlertsViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/20.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "AlertsViewController.h"
#import "BluetoothDataManage.h"
#import "Masonry.h"

@interface AlertsViewController ()
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *alertLabel;


@end

@implementation AlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if RobotMower | RobotPark
    UIImage *backImage = [UIImage imageNamed:@"backgroundnew"];
    self.view.layer.contents = (id)backImage.CGImage;
#elif MOWOXROBOT
    UIImage *backImage = [UIImage imageNamed:@"App_BG_4"];
    self.view.layer.contents = (id)backImage.CGImage;
#endif
    _bluetoothDataManage = [BluetoothDataManage shareInstance];
    [self getAlertContent];
    self.timeLabel = [self timeLabel];
    self.alertLabel = [self alertLabel];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAlertsContent:) name:@"recieveAlertsContent" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveAlertsContent" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy load

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:17.f];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_timeLabel];
        //自动折行设置
        [_timeLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        if (UI_IS_IPHONE5) {
            
            [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(300/WScale, 75/HScale));
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.view.mas_top).offset(100/HScale);
            }];
        }else{
            [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(300/WScale, 45/HScale));
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.view.mas_top).offset(100/HScale);
            }];
        }
    }
    return _timeLabel;
}

- (UILabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.font = [UIFont systemFontOfSize:17.f];
        _alertLabel.backgroundColor = [UIColor clearColor];
        _alertLabel.textColor = [UIColor blackColor];
        _alertLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_alertLabel];
        [_alertLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _alertLabel.numberOfLines = 0;
        _alertLabel.textAlignment = NSTextAlignmentLeft;
        if (UI_IS_IPHONE5) {
            
            [_alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(300/WScale, 65/HScale));
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.timeLabel.mas_bottom).offset(20/HScale);
            }];
        }else{
            [_alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(300/WScale, 45/HScale));
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.timeLabel.mas_bottom).offset(20/HScale);
            }];
        }
    }
    return _alertLabel;
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
    self.timeLabel.text = [NSString stringWithFormat:@"%@", dateLabel];
    switch ([wrongContent intValue]) {
        case 0x42: //Battery Error
        {
            self.alertLabel.text = LocalString(@"Battery Error");
        }
            break;
        case 0x4e: //Signal Error
        {
            self.alertLabel.text = LocalString(@"Signal Error");
        }
            break;
        case 0x4c: //Mower Lifted
        {
            self.alertLabel.text = LocalString(@"Mower Lifted");
        }
            break;
        case 0x54: //Mower tilted
        {
            self.alertLabel.text = LocalString(@"Mower tilted");
        }
            break;
        case 0x52: //Rolling over
        {
            self.alertLabel.text = LocalString(@"Rolling over");
        }
            break;
        case 0x58: //Mower trapped
        {
            self.alertLabel.text = LocalString(@"Mower trapped");
        }
            break;
        case 0x43: //Motor over current
        {
            self.alertLabel.text = LocalString(@"Motor over current");
        }
            break;
        case 0x4d: //Motor Fault
        {
            self.alertLabel.text = LocalString(@"Motor Fault");
        }
            break;
        case 0x53: //Bat Temp.abnormal
        {
            self.alertLabel.text = LocalString(@"Bat Temp.abnormal");
        }
            break;
        case 0x50: //PCB Over temperature
        {
            self.alertLabel.text = LocalString(@"PCB Over temperature");
        }
            break;
        default:
        {
            self.alertLabel.text = LocalString(@"No error content");
        }
            break;
    }
    
    
    
}


@end

//
//  MowerSetingVC_type4.m
//  MOWOX_Park
//
//  Created by 安建伟 on 2020/10/9.
//  Copyright © 2020 yusz. All rights reserved.
//

#import "MowerSetingVC_type4.h"

@interface MowerSetingVC_type4 ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UILabel *rainLabel;
@property (strong, nonatomic)  UILabel *boundaryLabel;
@property (strong, nonatomic)  UILabel *ultrasoundLabel;
@property (strong, nonatomic)  UIButton *rainyesButton;
@property (strong, nonatomic)  UIButton *rainnoButton;
@property (strong, nonatomic)  UIButton *boundaryyesButton;
@property (strong, nonatomic)  UIButton *boundarynoButton;
@property (strong, nonatomic)  UIButton *ultrasoundyesButton;
@property (strong, nonatomic)  UIButton *ultrasoundnoButton;
@property (strong, nonatomic)  UIButton *okButton;

@end

@implementation MowerSetingVC_type4

static int isRain = 0;
static int isBoundary = 0;
static int isUltrasound = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    self.navigationItem.title = LocalString(@"Robot setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    [self inquireMowerSetting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMowerSetting:) name:@"recieveMowerSetting" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveMowerSetting" object:nil];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _rainLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"MOW in the rain")];
    _boundaryLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"Boundary cut")];
    _ultrasoundLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"Ultrasound")];
    [_rainLabel setLabelStyle1];
    [_boundaryLabel setLabelStyle1];
    [_ultrasoundLabel setLabelStyle1];
    
    _rainyesButton = [UIButton buttonWithTitle:LocalString(@"Yes") titleColor:[UIColor blackColor]];
    _rainnoButton = [UIButton buttonWithTitle:LocalString(@"NO") titleColor:[UIColor blackColor]];
    _boundaryyesButton = [UIButton buttonWithTitle:LocalString(@"Yes") titleColor:[UIColor blackColor]];
    _boundarynoButton = [UIButton buttonWithTitle:LocalString(@"NO") titleColor:[UIColor blackColor]];
    _ultrasoundyesButton = [UIButton buttonWithTitle:LocalString(@"Yes") titleColor:[UIColor blackColor]];
    _ultrasoundnoButton = [UIButton buttonWithTitle:LocalString(@"NO") titleColor:[UIColor blackColor]];
    _okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    
    [_rainyesButton setButtonStyle1];
    [_rainnoButton setButtonStyle1];
    [_boundaryyesButton setButtonStyle1];
    [_boundarynoButton setButtonStyle1];
    [_ultrasoundyesButton setButtonStyle1];
    [_ultrasoundnoButton setButtonStyle1];
    [_okButton setButtonStyle1];
    
    [_rainyesButton addTarget:self action:@selector(rainSetYes) forControlEvents:UIControlEventTouchUpInside];
    [_rainnoButton addTarget:self action:@selector(rainSetNo) forControlEvents:UIControlEventTouchUpInside];
    [_boundaryyesButton addTarget:self action:@selector(boundarySetYes) forControlEvents:UIControlEventTouchUpInside];
    [_boundarynoButton addTarget:self action:@selector(boundarySetNo) forControlEvents:UIControlEventTouchUpInside];
    [_ultrasoundyesButton addTarget:self action:@selector(ultrasoundSetYes) forControlEvents:UIControlEventTouchUpInside];
    [_ultrasoundnoButton addTarget:self action:@selector(ultrasoundSetNo) forControlEvents:UIControlEventTouchUpInside];
    [_okButton addTarget:self action:@selector(MowerSetting) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_rainLabel];
    [self.view addSubview:_boundaryLabel];
    [self.view addSubview:_ultrasoundLabel];
    [self.view addSubview:_rainyesButton];
    [self.view addSubview:_rainnoButton];
    [self.view addSubview:_boundaryyesButton];
    [self.view addSubview:_boundarynoButton];
    [self.view addSubview:_ultrasoundyesButton];
    [self.view addSubview:_ultrasoundnoButton];
    [self.view addSubview:_okButton];
    
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_rainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 64);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_rainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 64);
        }];
    }
    
    [_rainyesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.rainLabel.mas_bottom).offset(ScreenHeight * 0.02);
        make.right.equalTo(self.view.mas_centerX).offset(- ScreenWidth * 0.0507);
    }];
    [_rainnoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.left.equalTo(self.view.mas_centerX).offset(ScreenWidth * 0.0507);
        make.centerY.equalTo(self.rainyesButton.mas_centerY);
    }];
    [_boundaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.rainyesButton.mas_bottom).offset(ScreenHeight * 0.02 * 3);
    }];
    [_boundaryyesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.boundaryLabel.mas_bottom).offset(ScreenHeight * 0.02);
        make.left.equalTo(self.rainyesButton.mas_left);
    }];
    [_boundarynoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.centerY.equalTo(self.boundaryyesButton.mas_centerY);
        make.left.equalTo(self.rainnoButton.mas_left);
    }];
    
    [_ultrasoundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.boundaryyesButton.mas_bottom).offset(ScreenHeight * 0.02 * 3);
    }];
    
    [_ultrasoundyesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.ultrasoundLabel.mas_bottom).offset(ScreenHeight * 0.02);
        make.left.equalTo(self.rainyesButton.mas_left);
    }];
    [_ultrasoundnoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.centerY.equalTo(self.ultrasoundyesButton.mas_centerY);
        make.left.equalTo(self.boundarynoButton.mas_left);
    }];
    
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.ultrasoundyesButton.mas_bottom).offset(ScreenHeight * 0.02);
    }];

}

#pragma mark - inquire MowerSetting

- (void)inquireMowerSetting{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x19];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveMowerSetting:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *rain = dict[@"rain"];
    NSNumber *boundary = dict[@"boundary"];
    NSNumber *ultrasound = dict[@"ultrasound"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([rain intValue] == 0) {
            [self rainSetNo];
        }else{
            [self rainSetYes];
        }
        if ([boundary intValue] == 0) {
            [self boundarySetNo];
        }else{
            [self boundarySetYes];
        }
        if ([ultrasound intValue] == 0) {
            [self ultrasoundSetNo];
        }else{
            [self ultrasoundSetYes];
        }
        
    });
    
}


#pragma mark - button target
- (void)rainSetYes{
    isRain = 1;
    [self.rainyesButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    [self.rainnoButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
}

- (void)rainSetNo{
    isRain = 0;
    [self.rainyesButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.rainnoButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
}

- (void)boundarySetYes{
    isBoundary = 1;
    [self.boundaryyesButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    [self.boundarynoButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
}

- (void)boundarySetNo{
    isBoundary = 0;
    [self.boundaryyesButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.boundarynoButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
}

- (void)ultrasoundSetYes{
    isUltrasound = 1;
    [self.ultrasoundyesButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    [self.ultrasoundnoButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
}

- (void)ultrasoundSetNo{
    isUltrasound = 0;
    [self.ultrasoundyesButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.ultrasoundnoButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
}

- (void)MowerSetting{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:isRain]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:isBoundary]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:isUltrasound]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x09];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

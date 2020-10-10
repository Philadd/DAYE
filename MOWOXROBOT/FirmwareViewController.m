//
//  FirmwareViewController.m
//  MOWOX
//
//  Created by Mac on 2017/12/27.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "FirmwareViewController.h"
#import "ProgressView.h"
#import "ASProgressPopUpView.h"

@interface FirmwareViewController () <ASProgressPopUpViewDelegate,ASProgressPopUpViewDataSource,UIGestureRecognizerDelegate>
///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *okButton;
@property (strong, nonatomic)  ProgressView *progressView;
@property (strong, nonatomic)  UITextView *curVerTV;
@property (strong, nonatomic)  UILabel *tipLabel;
@property (strong, nonatomic)  UIImageView *tipImage;

@property (strong, nonatomic)  UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic)  ASProgressPopUpView *progressViewNew;

@property (nonatomic) int packgeNum_main;
@property (nonatomic) int packgeNum_motor;
@property (nonatomic) int packgeNum_right;
@property (nonatomic) int packgeNum_left;
@property (nonatomic) int packgeNum_All;
@end

@implementation FirmwareViewController
{
    NSString *dataName;
    NSString *dataMotor;
    NSString *dataMotorLeft;
    NSString *dataMotorRight;
    UIView *background;
    UIImageView *imgView;//创建显示图像的视图
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    //解决navigationitem标题右偏移
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@""
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    self.navigationItem.title = LocalString(@"Update Robot's Firmware");
    
    
    //ui设置
    [self viewLayoutSet];
    
    //设置从第1包开始
    [BluetoothDataManage shareInstance].progress_num = 0;
    
    [self.progressViewNew showPopUpViewAnimated:YES];
    
    // 单击
    UITapGestureRecognizer *SingleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetImage:)];
    SingleTapGesture.numberOfTapsRequired = 1;//tap次数
    [self.view addGestureRecognizer:SingleTapGesture];
    //如果处理的是图片，别忘了
    _tipImage.userInteractionEnabled = YES;
    _tipImage.multipleTouchEnabled = YES;
    oldFrame = _tipImage.frame;
    largeFrame = CGRectMake(ScreenWidth,ScreenHeight, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
    
    [self readFileBIN];

}

- (void)readFileBIN{
    //获取bin文件的总包数并记录
    dataName = @"DM00401";
    dataMotor = @"DY0M008";
    dataMotorLeft = @"DY0L008";
    dataMotorRight = @"DY0R008";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:dataName ofType:@"BIN"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    long size = [data length];
    _packgeNum_main = (int)size / firmwareData([BluetoothDataManage shareInstance].version1);
    self.bluetoothDataManage.updateFirmware_packageNum = _packgeNum_main;
    NSLog(@"固件包数%d",self.bluetoothDataManage.updateFirmware_packageNum);
    
    NSString *motorPath = [[NSBundle mainBundle] pathForResource:dataMotor ofType:@"BIN"];
    NSData *motor = [NSData dataWithContentsOfFile:motorPath];
    long motorSize = [motor length];
    _packgeNum_motor= (int)motorSize / firmwareData([BluetoothDataManage shareInstance].version1);
    
    self.bluetoothDataManage.updateFirmware_packageNum_Motor = _packgeNum_motor;
    
    NSString *dataMotor_left = [[NSBundle mainBundle] pathForResource:dataMotorLeft ofType:@"BIN"];
    NSData *motor_left = [NSData dataWithContentsOfFile:dataMotor_left];
    long motor_leftSize = [motor_left length];
    _packgeNum_left = (int)motor_leftSize / firmwareData([BluetoothDataManage shareInstance].version1);
    self.bluetoothDataManage.updateFirmware_packageNum_Left = _packgeNum_left;
    
    NSString *dataMotor_right = [[NSBundle mainBundle] pathForResource:dataMotorRight ofType:@"BIN"];
    NSData *motor_right = [NSData dataWithContentsOfFile:dataMotor_right];
    long motor_rightSize = [motor_right length];
    _packgeNum_right = (int)motor_rightSize / firmwareData([BluetoothDataManage shareInstance].version1);
    
    self.bluetoothDataManage.updateFirmware_packageNum_Right = _packgeNum_right;
    
    _packgeNum_All = ((float)self.packgeNum_main + (float)self.packgeNum_motor + (float)self.packgeNum_left + (float)self.packgeNum_right);
    NSLog(@"总包数 %f %f %f %f %f",(float)_packgeNum_All,(float)self.packgeNum_main,(float)self.packgeNum_motor,(float)self.packgeNum_left,(float)self.packgeNum_right);
}

//单击实现原来大小
- (void)resetImage:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController setNavigationBarHidden:YES animated:nil];
    //创建一个黑色背景
    //初始化一个用来当做背景的View。
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    background = bgView;
    [bgView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:bgView];
    self->imgView = [[UIImageView alloc] init];
    
    //根据设备类型显示相应图片
    if ([BluetoothDataManage shareInstance].deviceType == 0) {
        //要显示的图片，即要放大的图片
        [imgView setImage:[UIImage imageNamed:@"updateFirmwareTip0"]];
    }else{
        [imgView setImage:[UIImage imageNamed:@"updateFirmwareTip"]];
    }
    [bgView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenHeight,ScreenWidth));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    imgView.transform=CGAffineTransformMakeRotation(M_PI_2);
    imgView.userInteractionEnabled = YES;
    //添加点击手势（即点击图片后退出全屏）
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
    [imgView addGestureRecognizer:tapGesture];
    
    [self shakeToShow:bgView];//放大过程中的动画
    [self addGestureRecognizerToView:imgView];
}

-(void)closeView{
    [background removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO animated:nil];
}
//放大过程中出现的缓慢动画
- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BluetoothDataManage shareInstance].updateFirmware_j = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware:) name:@"shaogujian" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccese_main) name:@"updateSuccese_main" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccese_motor) name:@"updateSuccese_motor" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccese_left) name:@"updateSuccese_left" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccese_right) name:@"updateSuccese_right" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSucceseEnd) name:@"updateSucceseEnd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GETupdateSucceseEnd) name:@"GETupdateSucceseEnd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmwareWeak) name:@"recieveUpdateFirmware" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shaogujian" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSuccese_main" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSuccese_motor" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSuccese_left" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSuccese_right" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSucceseEnd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GETupdateSucceseEnd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveUpdateFirmware" object:nil];
    [BluetoothDataManage shareInstance].updateFirmware_j = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    /**
     **进度条设置
     **/
    _progressViewNew = [[ASProgressPopUpView alloc] init];
    _progressViewNew.backgroundColor = [UIColor lightGrayColor];
    _progressViewNew.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    _progressViewNew.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _progressViewNew.delegate = self;
    _progressViewNew.dataSource = self;
    [self.view addSubview:_progressViewNew];
    
    //curVerTextView
    _curVerTV = [[UITextView alloc] init];
    _curVerTV.text = [NSString stringWithFormat:@"%@\n V%@.%d.%d.%d\n%@\n V%@.2.7.3\n",LocalString(@"Your robot's firmware version:"),[BluetoothDataManage shareInstance].deviceType,[BluetoothDataManage shareInstance].version1,[BluetoothDataManage shareInstance].version2,[BluetoothDataManage shareInstance].version3,LocalString(@"Latest robot's firmware version:"),[BluetoothDataManage shareInstance].deviceType];
    _curVerTV.font = [UIFont fontWithName:@"Arial" size:17];
    _curVerTV.backgroundColor = [UIColor clearColor];
    _curVerTV.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _curVerTV.textAlignment = NSTextAlignmentCenter;
    [_curVerTV setEditable:NO];
    _curVerTV.scrollEnabled = NO;
    [self.view addSubview:_curVerTV];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.font = [UIFont systemFontOfSize:17.0];
    _tipLabel.text = LocalString(@"Please press Key \"2\"(Boot Mode,2-Update firmware) on the robot's keyboard to start.");
    _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tipLabel.numberOfLines = 0;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipLabel];
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"Update") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [_okButton addTarget:self action:@selector(showUpdateView) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_okButton];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicatorView.backgroundColor = [UIColor grayColor];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    //根据设备类型显示相应图片
    if ([BluetoothDataManage shareInstance].deviceType == 0) {
        _tipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updateFirmwareTip0"]];
    }else{
        _tipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updateFirmwareTip"]];
    }
    [self.view addSubview:_tipImage];
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_curVerTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.18));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 64);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_curVerTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.18));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 64);
        }];
    }
    [_tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.3));
        make.top.equalTo(self.curVerTV.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    //自动折行设置
    [_tipLabel setLineBreakMode:NSLineBreakByWordWrapping];
    _tipLabel.numberOfLines = 0;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    if (UI_IS_IPHONE5) {
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.20));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.tipImage.mas_bottom);
        }];
    }else{
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.15));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.tipImage.mas_bottom);
        }];
    }
    
    [_progressViewNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, 5.0));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(ScreenHeight * 0.1);
    }];
    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

#pragma mark - 实现点击图片缩放，移动等功能
// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

 //处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }

}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

#pragma mark - progress view
/**
 **进度条的文字设置函数
 **/
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if (progress < 0.2) {
        s = @"Just starting";
    } else if (progress > 0.4 && progress < 0.6) {
        s = @"About halfway";
    } else if (progress > 0.75 && progress < 1.0) {
        s = @"Nearly there";
    } else if (progress >= 1.0) {
        s = @"Complete";
    }
    return s;
}

- (NSArray *)allStringsForProgressView:(ASProgressPopUpView *)progressView;
{
    return @[@"Just starting", @"About halfway", @"Nearly there", @"Complete"];
}

#pragma mark - bluetooth control
/**
 **接收到割草机启动信号，唤醒发送固件数据主函数并使屏幕常亮
 **/
- (void)updateFirmwareWeak{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

/**
 **发送固件数据的主函数
 **/
- (void)updateFirmware:(NSNotification *)notification{
    
    NSDictionary *dict = [notification userInfo];
    NSString *result = dict[@"result"];
    if ([result isEqualToString:@"success"]) {
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d %@",[BluetoothDataManage shareInstance].progress_num,LocalString(@"success")]];
    }else if ([result isEqualToString:@"error"]){
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d %@",[BluetoothDataManage shareInstance].progress_num,LocalString(@"error,again")]];
    }
    
    self.progressViewNew.progress = self.bluetoothDataManage.progress_num / (float)_packgeNum_All;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch ([BluetoothDataManage shareInstance].updateSucceseFlag) {
            case 1: //固件更新
            {
                [self setMototData:0x23 numData:self.bluetoothDataManage.updateFirmware_packageNum pathName:self->dataName];
                NSLog(@"固件名称%@ %d",self->dataName,[BluetoothDataManage shareInstance].updateFirmware_packageNum);
            }
                break;
            case 2: //电机更新
            {
                [self setMototData:0x47 numData:self.bluetoothDataManage.updateFirmware_packageNum_Motor pathName:self->dataMotor];
            }
                break;
            case 3:  //左电机更新
            {
                [self setMototData:0x4C numData:self.bluetoothDataManage.updateFirmware_packageNum_Left pathName:self->dataMotorLeft];
                NSLog(@"更新左");
            }
                break;
            case 4: //右电机更新
            {
                [self setMototData:0x52 numData:self.bluetoothDataManage.updateFirmware_packageNum_Right pathName:self->dataMotorRight];
                NSLog(@"更新右");
            }
                break;
            default:
                break;
        }
    });
    
}
//更新
- (void)setMototData:(UInt8)HCode numData:(UInt16)PackageNum pathName:(NSString *)fileName{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"BIN"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UInt8 sendBuffer[6];
    sendBuffer[0] = [[NSNumber numberWithUnsignedInteger:HCode] unsignedCharValue];
    sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:PackageNum%256] unsignedCharValue];
    sendBuffer[2] = [[NSNumber numberWithUnsignedInteger:PackageNum/256] unsignedCharValue];
    sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:HCode] unsignedCharValue];
    sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:0x00] unsignedCharValue];
    sendBuffer[5] = [[NSNumber numberWithUnsignedInteger:firmwareData([BluetoothDataManage shareInstance].version1)/256] unsignedCharValue];
    
    int j = [BluetoothDataManage shareInstance].updateFirmware_j;
    
    if ((j + firmwareData([BluetoothDataManage shareInstance].version1)) < [data length]) {
        NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, firmwareData([BluetoothDataManage shareInstance].version1)];
        NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
        sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:PackageNum%256] unsignedCharValue];
        sendBuffer[2] = [[NSNumber numberWithUnsignedInteger:PackageNum/256] unsignedCharValue];
        
        NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:6];
        NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
        {
            [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        usleep(10 * 1000);
        
        for (int i = 0; i < [subPac length]; i += 20) {
            
            // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
            if ((i + 20) < [subPac length]) {
                NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
                NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                NSLog(@"发送一条蓝牙帧： %@",subData);
                if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                {
                    [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                }
                //根据接收模块的处理能力做相应延时
                usleep(10 * 1000);
            }
            else {
                NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
                NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                NSLog(@"发送一条蓝牙帧： %@",subData);
                if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                {
                    [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                }
                usleep(10 * 1000);
            }
        }
        
        uint8_t crc8 = [self crc8:subPac];
        NSLog(@"%d",crc8);
        UInt8 sendCRCbuff[1];
        sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
        NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
        NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
        {
            [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        
    }else if(j != [data length]){
        //不接收
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"shaogujian" object:nil];
        
        NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, (int)([data length] - j)];
        NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
        sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:0] unsignedCharValue];
        sendBuffer[2] = [[NSNumber numberWithUnsignedInteger:0] unsignedCharValue];
        
        sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) % 256] unsignedCharValue];
        sendBuffer[5] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) / 256] unsignedCharValue];
        NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:6];
        NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
        {
            [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        usleep(10 * 1000);
        
        for (int i = 0; i < [subPac length]; i += 20) {
            
            // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
            if ((i + 20) < [subPac length]) {
                NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
                NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                NSLog(@"发送一条蓝牙帧： %@",subData);
                if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                {
                    [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                }
                //根据接收模块的处理能力做相应延时
                usleep(10 * 1000);
            }
            else {
                NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
                NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                NSLog(@"发送一条蓝牙帧： %@",subData);
                if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                {
                    [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                }
                usleep(10 * 1000);
            }
        }
        
        uint8_t crc8 = [self crc8:subPac];
        NSLog(@"%d",crc8);
        UInt8 sendCRCbuff[1];
        sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
        NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
        NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
        if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
        {
            [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        
    }
    
}

/**
 **crc8检验
 **/
- (uint8_t)crc8:(NSData *)data
{
    uint8_t crc=0;
    crc = 0;
    
    uint8_t byteArray[[data length]];
    [data getBytes:&byteArray];
    
    for (int i = 0; i < [data length]; i++) {
        Byte byte = byteArray[i];
        crc ^= byte;
        for(int j = 0;j < 8;j++)
        {
            if(crc & 0x01)
            {
                crc = (crc >> 1) ^ 0x8C;
            }else crc >>= 1;
        }
    }
    return crc;
}

/**
 **更新固件成功
 **/
- (void)updateSuccese_main{
    //self.progressView.hidden = NO;
    //_tipLabel.text = LocalString(@"####Update Success####");
    //_tipLabel.textColor = [UIColor greenColor];
    //[NSObject showHudTipStr:LocalString(@"update succese")];
    //[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    //_progressViewNew.progress = 1.0;
    //[BluetoothDataManage shareInstance].progress_num = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UInt8 controlCode = 0x04;
        [[BluetoothDataManage shareInstance] formMotorData:controlCode];
    });
}

- (void)updateSuccese_motor{
    //self.progressView.hidden = NO;
    //_tipLabel.text = LocalString(@"####Update Success####");
    //_tipLabel.textColor = [UIColor greenColor];
    //[NSObject showHudTipStr:LocalString(@"update succese")];
    //[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    //_progressViewNew.progress = 1.0;
    //[BluetoothDataManage shareInstance].progress_num = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UInt8 controlCode = 0x01;
        [[BluetoothDataManage shareInstance] formMotorData:controlCode];
    });
    
}

- (void)updateSuccese_left{
    //self.progressView.hidden = NO;
    //_tipLabel.text = LocalString(@"####Update Success####");
    //_tipLabel.textColor = [UIColor greenColor];
    //[NSObject showHudTipStr:LocalString(@"update succese")];
    //[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    //_progressViewNew.progress = 1.0;
    //[BluetoothDataManage shareInstance].progress_num = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UInt8 controlCode = 0x02;
        [[BluetoothDataManage shareInstance] formMotorData:controlCode];
        [BluetoothDataManage shareInstance].updateSucceseFlag = 4;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[BluetoothDataManage shareInstance].updateSucceseFlag = 4;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveUpdateFirmware" object:nil userInfo:nil];
    });
    
}

- (void)updateSuccese_right{
    //self.progressView.hidden = NO;
    //_tipLabel.text = LocalString(@"####Update Success####");
    //_tipLabel.textColor = [UIColor greenColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UInt8 controlCode = 0x00;
        [[BluetoothDataManage shareInstance] formMotorData:controlCode];
    });
    
}

- (void)updateSucceseEnd{
    //取消查询
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    [NSObject showHudTipStr:LocalString(@"update succese")];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _progressViewNew.progress = 1.0;
    [BluetoothDataManage shareInstance].updateSucceseFlag = 1;
    [BluetoothDataManage shareInstance].progress_num = 0;
    
}

- (void)GETupdateSucceseEnd{
    UInt8 controlCode = 0x10;
    [[BluetoothDataManage shareInstance] formMotorData:controlCode];
    //查询计时器
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(GETupdateSucceseEnd) withObject:nil afterDelay:3.f];
    });
    sleep(3);
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

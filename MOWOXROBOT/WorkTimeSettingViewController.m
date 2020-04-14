//
//  WorkTimeSettingViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "WorkTimeSettingViewController.h"
#import "BluetoothDataManage.h"
#import "AppDelegate.h"
#import "WorktimeCell.h"


@interface WorkTimeSettingViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;
@property (nonatomic, strong) UITableView *myTableView;

@property (strong, nonatomic)  UIPickerView *workDatePickview;
@property (strong, nonatomic)  UIButton *okButton;

///@brife 工作时间设置
@property (nonatomic, strong) NSMutableArray  *dayArray;
@property (nonatomic, strong) NSMutableArray  *starHourArray;
@property (nonatomic, strong) NSMutableArray  *starMinuteArray;
@property (nonatomic, strong) NSMutableArray  *workingHoursArray;
@property (nonatomic, strong) NSMutableArray  *workingMinuteArray;

@property (nonatomic, strong) NSMutableArray  *selectrowArray;
@property (nonatomic) int flag;//0:不发送,1:可以发送

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation WorkTimeSettingViewController
{
    UIToolbar *inputAccessoryView;
    NSIndexPath *selectIndexPath;
    NSInteger rowWeek;
//    UITextField *selectMinuteTextField;
//    UITextField *selectHourTextField;
//    UITextField *selectWorkTimeHourTF;
//    UITextField *selectWorkTimeMinuteTF;
}

static CGFloat cellHeight = 45.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    self.navigationItem.title = LocalString(@"Working time setting");
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    [self viewLayoutSet];
    _flag = 0;//默认不发送数据
    _timer = [self timer];
    
//    UIButton *refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
//    [refreshButton setTitle:LocalString(@"Refresh") forState:UIControlStateNormal];
//    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
//    self.navigationItem.rightBarButtonItem= rightItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveWorkingTime:) name:@"recieveWorkingTime1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveWorkingTime:) name:@"recieveWorkingTime2" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveWorkingTime1" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveWorkingTime2" object:nil];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(inquireWorktimeSetting) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate date]];
    }
    return _timer;
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    self.starHourArray = [[NSMutableArray alloc] init];
    self.starMinuteArray = [[NSMutableArray alloc] init];
    self.workingHoursArray = [[NSMutableArray alloc] init];
    self.workingMinuteArray = [[NSMutableArray alloc] init];
    if (!_workDatePickview) {
        _workDatePickview = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 216, ScreenWidth, 216)];
        //设置开始时间与工作时间的PickerView
        for (int i = 0; i < 24; i++) {
            [self.starHourArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        for (int i = 0; i < 25; i++) {
            [self.workingHoursArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        for (int i = 0; i < 60; i++) {
            [self.starMinuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        for (int i = 0; i < 10; i++) {
            [self.workingMinuteArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        self.selectrowArray = [NSMutableArray array];
        for (int i = 0; i < 30; i++) {
            [_selectrowArray addObject:[NSNumber numberWithInt:0]];
        }
        self.workDatePickview.dataSource = self;
        self.workDatePickview.delegate = self;
        //在当前选择上显示一个透明窗口
        self.workDatePickview.showsSelectionIndicator = YES;
        //[self.workDatePickview selectRow:3 inComponent:0 animated:YES];
        //[self.workDatePickview selectRow:7 inComponent:1 animated:YES];
        //_workDatePickview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        UIView *backView = [[UIView alloc] init];
        backView.frame = CGRectMake(0,0 , ScreenWidth, 30/HScale);
        backView.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
        [self.workDatePickview addSubview:backView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(0,0,self.view.frame.size.width / 5 , 30/HScale);
        titleLabel.font = [UIFont systemFontOfSize:17.f];
        titleLabel.text = LocalString(@"Day");
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textColor = [UIColor blueColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:titleLabel];
        
        UILabel *startLabel = [[UILabel alloc] init];
        startLabel.frame = CGRectMake(self.view.frame.size.width / 5 , 0 ,self.view.frame.size.width / 5 , 30/HScale);
        startLabel.font = [UIFont systemFontOfSize:17.f];
        startLabel.text = LocalString(@"Start");
        startLabel.adjustsFontSizeToFitWidth = YES;
        startLabel.textColor = [UIColor blueColor];
        startLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:startLabel];
        
        UILabel *hourLabel = [[UILabel alloc] init];
        hourLabel.frame = CGRectMake(self.view.frame.size.width / 5 * 3 ,0 ,self.view.frame.size.width / 5 , 30/HScale);
        hourLabel.font = [UIFont systemFontOfSize:17.f];
        hourLabel.text = LocalString(@"Hours");
        hourLabel.adjustsFontSizeToFitWidth = YES;
        hourLabel.textColor = [UIColor blueColor];
        hourLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:hourLabel];
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight * 0.05 + 44, ScreenWidth, cellHeight * 7) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[WorktimeCell class] forCellReuseIdentifier:kCellIdentifier_WorkTime];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.scrollEnabled = NO;
        tableView;
    });
    
    self.dayArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"Mon", nil),NSLocalizedString(@"Tue", nil),NSLocalizedString(@"Wed", nil),NSLocalizedString(@"Thu", nil),NSLocalizedString(@"Fri", nil),NSLocalizedString(@"Sat", nil),NSLocalizedString(@"Sun", nil)]];
    
    self.okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [self.okButton addTarget:self action:@selector(goMowerTime) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_okButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, cellHeight * 7));
            make.top.equalTo(self.view.mas_top).offset(44 + ScreenHeight * 0.05 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, cellHeight * 7));
            make.top.equalTo(self.view.mas_top).offset(44 + ScreenHeight * 0.01 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.066));
        make.top.equalTo(self.myTableView.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 7;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorktimeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_WorkTime forIndexPath:indexPath];
    cell.contentView.userInteractionEnabled = YES;
    cell.weekLabel.text = _dayArray[indexPath.row];
    cell.startHourTF.delegate = self;
    cell.startMinutesTF.delegate = self;
    cell.worksHoursTF.delegate = self;
    cell.worksMinutesTF.delegate = self;
    //将键盘替换成pickView
    cell.startHourTF.inputView = _workDatePickview;
    cell.startMinutesTF.inputView = _workDatePickview;
    cell.worksHoursTF.inputView = _workDatePickview;
    cell.worksMinutesTF.inputView = _workDatePickview;
    if ([_selectrowArray[indexPath.row * 4] intValue] <= 24) {
        cell.startHourTF.text = [_starHourArray objectAtIndex:[_selectrowArray[indexPath.row * 4] intValue]];
    }
    if ([_selectrowArray[indexPath.row * 4 + 1] intValue] <= 60) {
        cell.startMinutesTF.text = [NSString stringWithFormat:@"%@%@",LocalString(@":"),[_starMinuteArray objectAtIndex:[_selectrowArray[indexPath.row * 4 + 1] intValue]]];
    }
    if ([_selectrowArray[indexPath.row * 4 + 2] intValue] <= 25) {
        cell.worksHoursTF.text = [NSString stringWithFormat:@"%@",[_workingHoursArray objectAtIndex:[_selectrowArray[indexPath.row * 4 + 2] intValue]]];
    }
    if ([_selectrowArray[indexPath.row * 4 + 3] intValue] <= 10) {
        cell.worksMinutesTF.text = [NSString stringWithFormat:@"%@%@ %@",LocalString(@"."),[_workingMinuteArray objectAtIndex:[_selectrowArray[indexPath.row * 4 + 3] intValue]],LocalString(@"Hours")];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIPickerViewDataSource

// 返回多少列

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED {
    
    return 40;
}

/*- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
 {
 if(component == 0)
 return ScreenWidth / 3 - 40;
 else if (component == 1)
 return ScreenWidth / 3 + 20;
 return ScreenWidth / 3 +20;
 }*/

// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView  numberOfRowsInComponent:(NSInteger)component
{
    return 16384;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    NSUInteger max = 16384;

    switch (component) {
        case 0:
        {
            NSUInteger base0 = (max / 2) - (max / 2) % _dayArray.count;
            [self.workDatePickview selectRow:[_workDatePickview selectedRowInComponent:component] % _dayArray.count + base0 inComponent:component animated:NO];
        }
            break;
        case 1:
        {
            NSUInteger base1 = (max / 2) - (max / 2) % _starHourArray.count;
            [self.workDatePickview selectRow:[_workDatePickview selectedRowInComponent:component] % _starHourArray.count + base1 inComponent:component animated:NO];
            //selectHourTextField.text = _starHourArray[row];
            //[_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 4 withObject:[NSNumber numberWithLong:row]];
        }
            break;
        case 2:
        {
            NSUInteger base2 = (max / 2) - (max / 2) % _starMinuteArray.count;
            [self.workDatePickview selectRow:[_workDatePickview selectedRowInComponent:component] % _starMinuteArray.count + base2 inComponent:component animated:NO];
            //selectMinuteTextField.text = [NSString stringWithFormat:@"%@%@",LocalString(@":"),_starMinuteArray[row]];
            //[_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 4 + 1 withObject:[NSNumber numberWithLong:row]];
        }
            break;
        case 3:
        {
            NSUInteger base3 = (max / 2) - (max / 2) % _workingHoursArray.count;
            [self.workDatePickview selectRow:[_workDatePickview selectedRowInComponent:component] % _workingHoursArray.count + base3 inComponent:component animated:NO];
            //selectWorkTimeHourTF.text = [NSString stringWithFormat:@"%@",_workingHoursArray[row]];
            //[_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 4 + 2 withObject:[NSNumber numberWithLong:row]];
        }
            break;
        case 4:
        {
            NSUInteger base4 = (max / 2) - (max / 2) % _workingMinuteArray.count;
            [self.workDatePickview selectRow:[_workDatePickview selectedRowInComponent:component] % _workingMinuteArray.count + base4 inComponent:component animated:NO];
            //selectWorkTimeMinuteTF.text = [NSString stringWithFormat:@"%@%@%@",LocalString(@"."),_workingMinuteArray[row],LocalString(@"Hours")];
            //[_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 4 + 3 withObject:[NSNumber numberWithLong:row]];
        }
            break;

        default:
            break;
    }
}

- (UIView *)inputAccessoryView{
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame = inputAccessoryView.frame;
        frame.size.height = 35.0f;
        inputAccessoryView.frame = frame;
        
        UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithTitle:LocalString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:[UIColor grayColor]];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
    return inputAccessoryView;
}

- (void)done:(id)sender {
    //定位pickView位置 取出
    rowWeek = [_workDatePickview selectedRowInComponent:0];
    NSInteger startHourRow = [_workDatePickview selectedRowInComponent:1];
    NSInteger startMinutesRow = [_workDatePickview selectedRowInComponent:2];
    NSInteger workHourRow = [_workDatePickview selectedRowInComponent:3];
    NSInteger wokrMinutesRow = [_workDatePickview selectedRowInComponent:4];
    //定位cell位置 取出
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowWeek %_dayArray.count inSection:0];
    WorktimeCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
    //显示对应数据
    cell.startHourTF.text = _starHourArray[startHourRow %_starHourArray.count];
    cell.startMinutesTF.text = [NSString stringWithFormat:@"%@%@",LocalString(@":"),_starMinuteArray[startMinutesRow %_starMinuteArray.count]];
    cell.worksHoursTF.text = [NSString stringWithFormat:@"%@",_workingHoursArray[workHourRow %_workingHoursArray.count]];
    cell.worksMinutesTF.text = [NSString stringWithFormat:@"%@%@ %@",LocalString(@"."),_workingMinuteArray[wokrMinutesRow % _workingMinuteArray.count],LocalString(@"Hours")];
    
    //数据保存到数组里 对应数据替换下标 更新数据
    [_selectrowArray replaceObjectAtIndex:rowWeek %_dayArray.count  * 4 withObject:[NSNumber numberWithLong:startHourRow % _starHourArray.count]];
    [_selectrowArray replaceObjectAtIndex:rowWeek %_dayArray.count * 4 + 1 withObject:[NSNumber numberWithLong:startMinutesRow %_starMinuteArray.count]];
    [_selectrowArray replaceObjectAtIndex:rowWeek %_dayArray.count * 4 + 2 withObject:[NSNumber numberWithLong:workHourRow %_workingHoursArray.count]];
    [_selectrowArray replaceObjectAtIndex:rowWeek %_dayArray.count * 4 + 3 withObject:[NSNumber numberWithLong:wokrMinutesRow % _workingMinuteArray.count]];
    NSLog(@"%ld %ld %ld %ld %ld",rowWeek %_dayArray.count,startHourRow % _starHourArray.count,startMinutesRow %_starMinuteArray.count,workHourRow %_workingHoursArray.count,wokrMinutesRow % _workingMinuteArray.count);
    
    //调用发送设置
    [self sentMowerTime];

}

#pragma mark - UIPickerViewDelegate

// 返回的是component列的行显示的内容

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return self.dayArray[row % _dayArray.count];
            break;
        case 1:
            return self.starHourArray[row % _starHourArray.count];
            break;
          
        case 2:
            return [NSString stringWithFormat:@"%@%@",LocalString(@":"),self.starMinuteArray[row % _starMinuteArray.count]];
            break;
        case 3:
            return self.workingHoursArray[row % _workingHoursArray.count];
            break;
        default:
            return [NSString stringWithFormat:@"%@%@",LocalString(@"."),self.workingMinuteArray[row % _workingMinuteArray.count]];
            break;
    }
    
}

#pragma mark - textFiled delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    selectIndexPath = [self.myTableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
//    selectHourTextField = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[1];
//    selectMinuteTextField = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[2];
//    selectWorkTimeHourTF = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[3];
//    selectWorkTimeMinuteTF = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[4];
//    selectHourTextField.textColor = [UIColor blueColor];
//    selectMinuteTextField.textColor = [UIColor blueColor];
//    selectWorkTimeHourTF.textColor = [UIColor blueColor];
//    selectWorkTimeMinuteTF.textColor = [UIColor blueColor];
    [_workDatePickview selectRow:selectIndexPath.row inComponent:0 animated:YES];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 4] intValue] inComponent:1 animated:YES];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 4 + 1] intValue] inComponent:2 animated:YES];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 4 + 2] intValue] inComponent:3 animated:YES];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 4 + 3] intValue] inComponent:4 animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    selectHourTextField.textColor = [UIColor blackColor];
//    selectMinuteTextField.textColor = [UIColor blackColor];
//    selectWorkTimeHourTF.textColor = [UIColor blackColor];
//    selectWorkTimeMinuteTF.textColor = [UIColor blackColor];
//    [selectHourTextField resignFirstResponder];
//    [selectMinuteTextField resignFirstResponder];
//    [selectWorkTimeHourTF resignFirstResponder];
//    [selectWorkTimeMinuteTF resignFirstResponder];
}

#pragma mark - resign keyboard control

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"done" object:nil userInfo:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - inquire WorkingtimeSetting

- (void)inquireWorktimeSetting{
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
    
    [self.bluetoothDataManage setDataType:0x14];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveWorkingTime:(NSNotification *)notification{
    _flag = 1;
    [SVProgressHUD dismiss];
    //停掉重发机制
    [_timer setFireDate:[NSDate distantFuture]];
    if ([notification.name isEqualToString:@"recieveWorkingTime1"]) {
        NSDictionary *dict = [notification userInfo];
        NSNumber *monHour = 0;
        NSNumber *tueHour = 0;
        NSNumber *wedHour = 0;
        NSNumber *thuHour = 0;
        NSNumber *friHour = 0;
        NSNumber *satHour = 0;
        NSNumber *sunHour = 0;
        NSNumber *monMinute = 0;
        NSNumber *tueMinute = 0;
        NSNumber *wedMinute = 0;
        NSNumber *thuMinute = 0;
        NSNumber *friMinute = 0;
        NSNumber *satMinute = 0;
        NSNumber *sunMinute = 0;
        if (dict[@"monHour"]) {
            monHour = dict[@"monHour"];
        }
        if (dict[@"tueHour"]) {
            tueHour = dict[@"tueHour"];
        }
        if (dict[@"wedHour"]) {
            wedHour = dict[@"wedHour"];
        }
        if (dict[@"thuHour"]) {
            thuHour = dict[@"thuHour"];
        }
        if (dict[@"friHour"]) {
            friHour = dict[@"friHour"];
        }
        if (dict[@"satHour"]) {
            satHour = dict[@"satHour"];
        }
        if (dict[@"sunHour"]) {
            sunHour = dict[@"sunHour"];
        }
        if (dict[@"monMinute"]) {
            monMinute = dict[@"monMinute"];
        }
        if (dict[@"tueMinute"]) {
            tueMinute = dict[@"tueMinute"];
        }
        if (dict[@"wedMinute"]) {
            wedMinute = dict[@"wedMinute"];
        }
        if (dict[@"thuMinute"]) {
            thuMinute = dict[@"thuMinute"];
        }
        if (dict[@"friMinute"]) {
            friMinute = dict[@"friMinute"];
        }
        if (dict[@"satMinute"]) {
            satMinute = dict[@"satMinute"];
        }
        if (dict[@"sunMinute"]) {
            sunMinute = dict[@"sunMinute"];
        }
        [_selectrowArray replaceObjectAtIndex:0 withObject:monHour];
        [_selectrowArray replaceObjectAtIndex:4 withObject:tueHour];
        [_selectrowArray replaceObjectAtIndex:8 withObject:wedHour];
        [_selectrowArray replaceObjectAtIndex:12 withObject:thuHour];
        [_selectrowArray replaceObjectAtIndex:16 withObject:friHour];
        [_selectrowArray replaceObjectAtIndex:20 withObject:satHour];
        [_selectrowArray replaceObjectAtIndex:24 withObject:sunHour];
        
        [_selectrowArray replaceObjectAtIndex:1 withObject:monMinute];
        [_selectrowArray replaceObjectAtIndex:5 withObject:tueMinute];
        [_selectrowArray replaceObjectAtIndex:9 withObject:wedMinute];
        [_selectrowArray replaceObjectAtIndex:13 withObject:thuMinute];
        [_selectrowArray replaceObjectAtIndex:17 withObject:friMinute];
        [_selectrowArray replaceObjectAtIndex:21 withObject:satMinute];
        [_selectrowArray replaceObjectAtIndex:25 withObject:sunMinute];
        
    }else{
        NSDictionary *dict = [notification userInfo];
        NSNumber *monWorkHour = 0;
        NSNumber *tueWorkHour = 0;
        NSNumber *wedWorkHour = 0;
        NSNumber *thuWorkHour = 0;
        NSNumber *friWorkHour = 0;
        NSNumber *satWorkHour = 0;
        NSNumber *sunWorkHour = 0;
        NSNumber *monWorkMinute = 0;
        NSNumber *tueWorkMinute = 0;
        NSNumber *wedWorkMinute = 0;
        NSNumber *thuWorkMinute = 0;
        NSNumber *friWorkMinute = 0;
        NSNumber *satWorkMinute = 0;
        NSNumber *sunWorkMinute = 0;
        

        if (dict[@"monWorkHour"]) {
            monWorkHour = dict[@"monWorkHour"];
        }
        if (dict[@"tueWorkHour"]) {
            tueWorkHour = dict[@"tueWorkHour"];
        }
        if (dict[@"wedWorkHour"]) {
            wedWorkHour = dict[@"wedWorkHour"];
        }
        if (dict[@"thuWorkHour"]) {
            thuWorkHour = dict[@"thuWorkHour"];
        }
        if (dict[@"friWorkHour"]) {
            friWorkHour = dict[@"friWorkHour"];
        }
        if (dict[@"satWorkHour"]) {
            satWorkHour = dict[@"satWorkHour"];
        }
        if (dict[@"sunWorkHour"]) {
            sunWorkHour = dict[@"sunWorkHour"];
        }
        
        if (dict[@"monWorkMinute"]) {
            monWorkMinute = dict[@"monWorkMinute"];
        }
        if (dict[@"tueWorkMinute"]) {
            tueWorkMinute = dict[@"tueWorkMinute"];
        }
        if (dict[@"wedWorkMinute"]) {
            wedWorkMinute = dict[@"wedWorkMinute"];
        }
        if (dict[@"thuWorkMinute"]) {
            thuWorkMinute = dict[@"thuWorkMinute"];
        }
        if (dict[@"friWorkMinute"]) {
            friWorkMinute = dict[@"friWorkMinute"];
        }
        if (dict[@"satWorkMinute"]) {
            satWorkMinute = dict[@"satWorkMinute"];
        }
        if (dict[@"sunWorkMinute"]) {
            sunWorkMinute = dict[@"sunWorkMinute"];
        }
        [_selectrowArray replaceObjectAtIndex:2 withObject:monWorkHour];
        [_selectrowArray replaceObjectAtIndex:6 withObject:tueWorkHour];
        [_selectrowArray replaceObjectAtIndex:10 withObject:wedWorkHour];
        [_selectrowArray replaceObjectAtIndex:14 withObject:thuWorkHour];
        [_selectrowArray replaceObjectAtIndex:18 withObject:friWorkHour];
        [_selectrowArray replaceObjectAtIndex:22 withObject:satWorkHour];
        [_selectrowArray replaceObjectAtIndex:26 withObject:sunWorkHour];
        
        [_selectrowArray replaceObjectAtIndex:3 withObject:monWorkMinute];
        [_selectrowArray replaceObjectAtIndex:7 withObject:tueWorkMinute];
        [_selectrowArray replaceObjectAtIndex:11 withObject:wedWorkMinute];
        [_selectrowArray replaceObjectAtIndex:15 withObject:thuWorkMinute];
        [_selectrowArray replaceObjectAtIndex:19 withObject:friWorkMinute];
        [_selectrowArray replaceObjectAtIndex:23 withObject:satWorkMinute];
        [_selectrowArray replaceObjectAtIndex:27 withObject:sunWorkMinute];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myTableView reloadData];
    });
    
}

#pragma mark - set mower work time

- (void)sentMowerTime{
    /*
     第一帧数据位：前七位为周一至周日的时间的小时位;
     后七位为周一至周日的时间的分钟位;
     第二帧数据位：
     数据内容共7个字节：
     表示周一至周日的进行工作时间;
     注：此帧将时间戳取消
     */
    NSMutableArray *dataStartTime1 = [[NSMutableArray alloc] init];
    NSMutableArray *dataStartTime2 = [[NSMutableArray alloc] init];
    NSMutableArray *dataWorkTime1 = [[NSMutableArray alloc] init];
    NSMutableArray *dataWorkTime2 = [[NSMutableArray alloc] init];
    if (dataStartTime1.count != 8) {
        for (int i = 0; i < 28; i= i+4) {
            [dataStartTime1 addObject:_selectrowArray[i]];
        }
    }
    if (dataStartTime2.count != 8) {
        for (int i = 1; i < 28; i= i+4) {
            [dataStartTime2 addObject:_selectrowArray[i]];
        }
    }
    NSArray *dataStartTime = [dataStartTime1 arrayByAddingObjectsFromArray:dataStartTime2];
    if (dataWorkTime1.count != 8) {
        for (int i = 2; i < 30; i= i+4) {
            [dataWorkTime1 addObject:_selectrowArray[i]];
        }
    }
    if (dataWorkTime2.count != 8) {
        for (int i = 3; i < 30; i= i+4) {
            [dataWorkTime2 addObject:_selectrowArray[i]];
        }
    }
    NSArray *dataWorkTime = [dataWorkTime1 arrayByAddingObjectsFromArray:dataWorkTime2];
    
    if ([_selectrowArray[0] intValue] *60 + [_selectrowArray[2] intValue] * 60 + [_selectrowArray[1] intValue] + [_selectrowArray[3] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Monday's time set wrong")];
    }else if ([_selectrowArray[4] intValue] *60 + [_selectrowArray[6] intValue] * 60 + [_selectrowArray[5] intValue] + [_selectrowArray[7] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Tuesday's time set wrong")];
    }else if ([_selectrowArray[8] intValue] *60 + [_selectrowArray[10] intValue] * 60 + [_selectrowArray[9] intValue] + [_selectrowArray[11] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Wednesday's time set wrong")];
    }else if ([_selectrowArray[12] intValue] *60 + [_selectrowArray[14] intValue] * 60 + [_selectrowArray[13] intValue] + [_selectrowArray[15] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Thursday's time set wrong")];
    }else if ([_selectrowArray[16] intValue] *60 + [_selectrowArray[18] intValue] * 60 + [_selectrowArray[17] intValue] + [_selectrowArray[19] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Friday's time set wrong")];
    }else if ([_selectrowArray[20] intValue] *60 + [_selectrowArray[22] intValue] * 60 + [_selectrowArray[21] intValue] + [_selectrowArray[23] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Saturday's time set wrong")];
    }else if ([_selectrowArray[24] intValue] *60 + [_selectrowArray[26] intValue] * 60 + [_selectrowArray[25] intValue] + [_selectrowArray[27] intValue] * 6 > 1440){
        [NSObject showHudTipStr:LocalString(@"Sunday's time set wrong")];
    }else{
        [NSObject showHudTipStr:LocalString(@"Data sent successfully")];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self.bluetoothDataManage setDataType:0x04];
            [self.bluetoothDataManage setDataContent: dataStartTime];
            [self.bluetoothDataManage sendWorktimeBluetoothFrame];
            usleep(1000 * 1000);
            [self.bluetoothDataManage setDataType:0x05];
            [self.bluetoothDataManage setDataContent: dataWorkTime];
            [self.bluetoothDataManage sendWorktimeBluetoothFrame];
            
        });
    }
}
//取消刷新功能
//- (void)refresh{
//    sleep(1.0f);
//    [self inquireWorktimeSetting];
//}

- (void)goMowerTime
{
    if (_flag == 1) {
        [self sentMowerTime];
    }else{
        //[NSObject showHudTipStr:LocalString(@"Data transmission failed")];
        //显示弹出框列表选择
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"Working hours are all 0") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"NO") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction* sureAction = [UIAlertAction actionWithTitle:LocalString(@"Yes") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            //响应事件
            self.flag = 1;
            [self sentMowerTime];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

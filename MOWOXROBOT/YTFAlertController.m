//
//  YTFAlertController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/12/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YTFAlertController.h"

@interface YTFAlertController ()

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation YTFAlertController
{
    UIToolbar *inputAccessoryView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.dismissBtn = [self dismissBtn];
    self.alertView = [self alertView];
}

- (UIView *)alertView{
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.frame = CGRectMake(52.5, 172, 270, 203);
        _alertView.center = self.view.center;
        _alertView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _alertView.layer.cornerRadius = 10.f;
        [self.view addSubview:_alertView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(44,20,182,21);
        _titleLabel.text = @"";
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        [_alertView addSubview:_titleLabel];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(30,57,210,32)];
        _textField.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
        _textField.font = [UIFont fontWithName:@"Arial" size:16.0f];
        _textField.textColor = [UIColor colorWithHexString:@"666666"];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
        _textField.adjustsFontSizeToFitWidth = YES;
        //设置自动缩小显示的最小字体大小
        _textField.minimumFontSize = 11.f;
        [self.alertView addSubview:_textField];
        _textField.layer.cornerRadius = 16.f;
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(15,129,114,44);
        [_leftBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        [_leftBtn setTitle:LocalString(@"") forState:UIControlStateNormal];
        [_leftBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_leftBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [_leftBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f];
        [_leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_leftBtn];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(141,129,114,44);
        [_rightBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [_rightBtn setTitle:LocalString(@"") forState:UIControlStateNormal];
        [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_rightBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [_rightBtn setButtonStyleWithColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] Width:1 cornerRadius:18.f];
        [_rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:_rightBtn];
    }
    return _alertView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 260/HScale);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}
- (UIView *)inputAccessoryView{
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame = inputAccessoryView.frame;
        frame.size.height = 30.0f;
        inputAccessoryView.frame = frame;
        
        UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithTitle:LocalString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:[UIColor grayColor]];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
    return inputAccessoryView;
}

- (void)done:(id)sender{
    [_textField resignFirstResponder];
}

#pragma mark - Actions
- (void)leftAction{
    if (self.lBlock) {
        self.lBlock();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)rightAction{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.rBlock) {
        self.rBlock(self.textField.text);
    }
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

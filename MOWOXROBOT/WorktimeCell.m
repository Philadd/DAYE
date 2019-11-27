//
//  WorktimeCell.m
//  MOWOX
//
//  Created by Mac on 2017/12/11.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "WorktimeCell.h"
#define viewWidth self.contentView.frame.size.width
#define viewHeight self.contentView.frame.size.height

@interface WorktimeCell () <UITextFieldDelegate>
@end

@implementation WorktimeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done) name:@"done" object:nil];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_weekLabel) {
            _weekLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:15.0] textColor:[UIColor blackColor]];
            _weekLabel.frame = CGRectMake(0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [self.contentView addSubview:self.weekLabel];
        }
        /*if (!_timeBtn) {
            _timeBtn = [UIButton buttonWithTitle:@"00:00" titleColor:[UIColor blackColor]];
            _timeBtn.frame = CGRectMake(ScreenWidth / 3.0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [_timeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [self.contentView addSubview:self.timeBtn];
        }
        if (!_hoursBtn) {
            _hoursBtn = [UIButton buttonWithTitle:@"22.0h" titleColor:[UIColor blackColor]];
            _hoursBtn.frame = CGRectMake(ScreenWidth / 3.0 * 2.0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [_hoursBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [self.contentView addSubview:self.hoursBtn];
        }*/
        if (!_startHourTF) {
            _startHourTF = [UITextField worktimeTextFieldWithPlaceholder:@"00:"];
            _startHourTF.frame = CGRectMake(ScreenWidth / 3.0 + 20 , 5, (ScreenWidth / 3.0)/2, viewHeight - 10);
            _startHourTF.font = [UIFont systemFontOfSize:15.0];
            [_startHourTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _startHourTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.startHourTF];
        }
        if (!_startMinutesTF) {
            _startMinutesTF = [UITextField worktimeTextFieldWithPlaceholder:@"00"];
            _startMinutesTF.frame = CGRectMake(ScreenWidth / 3.0 + 40, 5, (ScreenWidth / 3.0)/2 + 8, viewHeight - 10);
            _startMinutesTF.font = [UIFont systemFontOfSize:15.0];
            [_startMinutesTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _startMinutesTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.startMinutesTF];
        }
        
        if (!_worksHoursTF) {
            _worksHoursTF = [UITextField worktimeTextFieldWithPlaceholder:@"00."];
            _worksHoursTF.frame = CGRectMake(ScreenWidth / 3.0 * 1.5, 5, ScreenWidth / 3.0, viewHeight - 10);
            _worksHoursTF.font = [UIFont systemFontOfSize:15.0];
            [_worksHoursTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _worksHoursTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.worksHoursTF];
        }
        if (!_worksMinutesTF) {
            _worksMinutesTF = [UITextField worktimeTextFieldWithPlaceholder:@"0 Hours"];
            _worksMinutesTF.frame = CGRectMake(ScreenWidth / 3.0 * 1.5 + 40, 5, ScreenWidth / 3.0 + 15, viewHeight - 10);
            _worksMinutesTF.font = [UIFont systemFontOfSize:15.0];
            [_worksMinutesTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _worksMinutesTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.worksMinutesTF];
        }
    }
    return self;
}

- (void)done {
    [_startHourTF resignFirstResponder];
    [_startMinutesTF resignFirstResponder];
    [_worksHoursTF resignFirstResponder];
    [_worksMinutesTF resignFirstResponder];
}

- (void)pushTag{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

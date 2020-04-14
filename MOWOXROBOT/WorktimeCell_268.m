//
//  WorktimeCell_268.m
//  MOWOXROBOT
//
//  Created by 安建伟 on 2020/4/5.
//  Copyright © 2020 yusz. All rights reserved.
//

#import "WorktimeCell_268.h"

#define viewWidth self.contentView.frame.size.width
#define viewHeight self.contentView.frame.size.height

@implementation WorktimeCell_268

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
        
        if (!_timeTF) {
            _timeTF = [UITextField worktimeTextFieldWithPlaceholder:@"AM 0:00;"];
            _timeTF.frame = CGRectMake(ScreenWidth / 3.0, 5, ScreenWidth / 3.0, viewHeight - 10);
            _timeTF.font = [UIFont systemFontOfSize:15.0];
            [_timeTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _timeTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.timeTF];
        }
        if (!_hoursTF) {
            _hoursTF = [UITextField worktimeTextFieldWithPlaceholder:@"0 Hours"];
            _hoursTF.frame = CGRectMake(ScreenWidth / 3.0 * 2.0, 5, ScreenWidth / 3.0, viewHeight - 10);
            _hoursTF.font = [UIFont systemFontOfSize:15.0];
            [_hoursTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _hoursTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.hoursTF];
        }
    }
    return self;
}

- (void)done {
    [_hoursTF resignFirstResponder];
    [_timeTF resignFirstResponder];
}

- (void)pushTag{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

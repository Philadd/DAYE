//
//  YTFAlertController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/12/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFLeftBlock)(void);
typedef void(^TFRightBlock)(NSString * _Nullable text);

NS_ASSUME_NONNULL_BEGIN

@interface YTFAlertController : UIViewController

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic) TFLeftBlock lBlock;
@property (nonatomic) TFRightBlock rBlock;

@end

NS_ASSUME_NONNULL_END

//
//  BottomVertiButton.m
//  HuanLe
//
//  Created by ms on 2016/12/14.
//  Copyright © 2016年 shengu. All rights reserved.
//

#import "BottomVertiButton.h"
#import "Masonry.h"

@implementation BottomVertiButton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.verImageView = [[UIImageView alloc] init];
        [self addSubview:self.verImageView];
        self.verTitleLabel = [[UILabel alloc] init];
        [self addSubview:self.verTitleLabel];
        self.verTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.verTitleLabel.textColor = [UIColor redColor];
        self.verTitleLabel.font = [UIFont systemFontOfSize:15.f];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.verImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
//        make.width.height.equalTo(self).multipliedBy(0.5);
        make.width.mas_equalTo(88/2.0);
        make.height.mas_equalTo(76/2.0);
        make.centerX.equalTo(self);
    }];
    [self.verTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.verImageView.mas_bottom);
        make.centerX.equalTo(self);
    }];
}
@end

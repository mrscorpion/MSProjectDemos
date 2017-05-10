//
//  WaveViewController.m
//  ProgressViewDemo
//
//  Created by chuanglong02 on 16/12/27.
//  Copyright © 2016年 漫漫. All rights reserved.
//

#import "WaveViewController.h"
#import "LXWaveProgress.h"
#import "MAThermometer.h"

#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width

@interface WaveViewController ()
{
    LXWaveProgress *_waveProgress;
}
@property (nonatomic, strong) MAThermometer *thermometer1;
@end

@implementation WaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    
    
    CGFloat y = 100;
    CGFloat height = kMainScreenHeight - 150 - 30 - kMainScreenWidth / 4;
    CGFloat width = height * 0.3;
    CGFloat x = (kMainScreenWidth - width) / 2.0;
    
    
//    // Do any additional setup after loading the view.
//    _waveProgress = [[LXWaveProgress alloc] initWithFrame:CGRectMake(x, y, width, height)];
//    _waveProgress.center = self.view.center;
//    [self.view addSubview:_waveProgress];
//    _waveProgress.progress = 0.0f;
//
    [self.slider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    
    
    
    _thermometer1 = [[MAThermometer alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [_thermometer1 setMinValue:35.3];
    [_thermometer1 setMaxValue:41.0];
    _thermometer1.curValue = 36.5;
    [_thermometer1 setArrayColors:@[[UIColor colorWithRed:247/255. green:92/255. blue:96/255. alpha:1.0]]];
    [self.view addSubview:_thermometer1];
    
}
-(void)changeValue:(UISlider *)slider
{
    _waveProgress.progress = slider.value;
    
    // add
    self.thermometer1.wave.progress = slider.value;
}



@end

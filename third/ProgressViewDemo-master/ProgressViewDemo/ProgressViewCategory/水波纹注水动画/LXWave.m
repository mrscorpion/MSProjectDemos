//
//  LXWave.m
//  LXWaveProgressView
//
//  Created by chuanglong02 on 16/12/26.
//  Copyright © 2016年 漫漫. All rights reserved.
//
/**
 正弦曲线公式可表示为y=Asin(ωx+φ)+k：
 A，振幅，最高和最低的距离
 W，角速度，用于控制周期大小，单位x中的起伏个数
 K，偏距，曲线整体上下偏移量
 φ，初相，左右移动的值
 
 这个效果主要的思路是添加两条曲线 一条正玄曲线、一条余弦曲线 然后在曲线下添加深浅不同的背景颜色，从而达到波浪显示的效果
 */
#import "LXWave.h"
#define BackGroundColor [UIColor clearColor] //[UIColor colorWithRed:96/255.0f green:159/255.0f blue:150/255.0f alpha:1]
#define WaveColor1 [UIColor colorWithRed:247/255. green:92/255. blue:96/255. alpha:1.0] //[UIColor colorWithRed:136/255.0f green:199/255.0f blue:190/255.0f alpha:1]
#define WaveColor2 [UIColor colorWithRed:247/255. green:96/255. blue:100/255. alpha:0.5] //[UIColor colorWithRed:28/255.0 green:203/255.0 blue:174/255.0 alpha:1]
@interface LXWave()
{
    //前面的波浪
    CAShapeLayer *_waveLayer1;
    CAShapeLayer *_waveLayer2;
    
    CADisplayLink *_disPlayLink;
    
    /**
     曲线的振幅
     */
    CGFloat _waveAmplitude;
    /**
     曲线角速度
     */
    CGFloat _wavePalstance;
    /**
     曲线初相
     */
    CGFloat _waveX;
    /**
     曲线偏距
     */
    CGFloat _waveY;
    
    /**
     曲线移动速度
     */
    CGFloat _waveMoveSpeed;
}

@end

@implementation LXWave

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        [self setupUI];
        [self configData];
    }
    return self;
}
-(void)setupUI
{
    //初始化波浪
    //底层
    _waveLayer1 = [CAShapeLayer layer];
    _waveLayer1.fillColor = WaveColor1.CGColor;
    _waveLayer1.strokeColor = WaveColor1.CGColor;
    [self.layer addSublayer:_waveLayer1];
    
    //上层
    _waveLayer2 = [CAShapeLayer layer];
    _waveLayer2.fillColor = WaveColor2.CGColor;
    _waveLayer2.strokeColor = WaveColor2.CGColor;
    [self.layer addSublayer:_waveLayer2];
    
    //画了个圆
//    self.layer.cornerRadius = self.bounds.size.width/2.0f;
    self.layer.masksToBounds = true;
    self.backgroundColor = BackGroundColor;
    
}

-(void)configData
{
    //振幅
    _waveAmplitude = 10;
    //角速度
    _wavePalstance = M_PI/self.bounds.size.width;
    //偏距
    _waveY = self.bounds.size.height;
    //初相
    _waveX = 0;
    //x轴移动速度
    _waveMoveSpeed = _wavePalstance * 10;
    //以屏幕刷新速度为周期刷新曲线的位置
    _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWave:)];
    [_disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}
-(void)updateWave:(CADisplayLink *)link
{
    _waveX += _waveMoveSpeed;
    [self updateWaveY];//更新波浪的高度位置
    [self updateWave];
   
}
//更新偏距的大小 直到达到目标偏距 让wave有一个匀速增长的效果
-(void)updateWaveY
{
    CGFloat targetY = self.bounds.size.height - _progress * self.bounds.size.height;
    if (_waveY < targetY) {
        _waveY += 2;
    }
    if (_waveY > targetY ) {
        _waveY -= 2;
    }
}
-(void)updateWave
{
    //波浪宽度
    CGFloat waterWaveWidth = self.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    
    //设置起始位置
    CGPathMoveToPoint(maskPath, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = _waveY;
  
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * sin(_wavePalstance * x + _waveX) + _waveY;
       
        CGPathAddLineToPoint(path, nil, x, y);

    }
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * cos(_wavePalstance * x + _waveX) + _waveY;
       
        CGPathAddLineToPoint(maskPath, nil, x, y);
    }
    [self updateLayer:_waveLayer1 path:path];
    [self updateLayer:_waveLayer2 path:maskPath];

}
-(void)updateLayer:(CAShapeLayer *)layer path:(CGMutablePathRef )path
{
    //填充底部颜色
    CGFloat waterWaveWidth = self.bounds.size.width;
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    layer.path = path;
     CGPathRelease(path);
}
-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
}
-(void)stop
{
    if (_disPlayLink) {
        [_disPlayLink invalidate];
        _disPlayLink = nil;
    }
}
-(void)dealloc
{
    [self stop];
    if (_waveLayer1) {
        [_waveLayer1 removeFromSuperlayer];
        _waveLayer1 = nil;
    }
    if (_waveLayer2) {
        [_waveLayer2 removeFromSuperlayer];
        _waveLayer2 = nil;
    }
    
}
@end

// SHLineGraphView.m
//
// Copyright (c) 2014 Shan Ul Haq (http://grevolution.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "SHLineGraphView.h"
//#import "PopoverView.h"
#import "SHPlot.h"
#import <math.h>
#import <objc/runtime.h>
#import "CustomPopOverView.h"

#define BOTTOM_MARGIN_TO_LEAVE 16.0//30.0
#define TOP_MARGIN_TO_LEAVE 30.0
#define INTERVAL_COUNT 5  // 9
#define PLOT_WIDTH (self.bounds.size.width - _leftMarginToLeave)

#define kAssociatedPlotObject @"kAssociatedPlotObject"


@implementation SHLineGraphView
{
  float _leftMarginToLeave;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self loadDefaultTheme];
}

- (instancetype)init
{
  if((self = [super init])) {
    [self loadDefaultTheme];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
      [self loadDefaultTheme];
    }
    return self;
}

- (void)loadDefaultTheme
{
   _themeAttributes = @{
                           kXAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                           kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                           kYAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                           kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                           kYAxisLabelSideMarginsKey : @10,
                           kPlotBackgroundLineColorKye : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]
                           };
    _leftMarginToLeave = 0.0;
}

- (void)addPlot:(SHPlot *)newPlot;
{
  if(nil == newPlot) {
    return;
  }
  
  if(_plots == nil){
    _plots = [NSMutableArray array];
  }
  [_plots addObject:newPlot];
}

- (void)setupTheView
{
  for(SHPlot *plot in _plots) {
    [self drawPlotWithPlot:plot];
  }
}

#pragma mark - Actual Plot Drawing Methods
- (void)drawPlotWithPlot:(SHPlot *)plot
{
  //draw y-axis labels. this has to be done first, so that we can determine the left margin to leave according to the
  //y-axis lables.
  [self drawYLabels:plot];

  //draw x-labels
  [self drawXLabels:plot];
  
  //draw the grey lines
  [self drawLines:plot];
  
  /*
   actual plot drawing
   */
  [self drawPlot:plot];
}

- (int)getIndexForValue:(NSNumber *)value forPlot:(SHPlot *)plot
{
  for(int i=0; i< _xAxisValues.count; i++) {
    NSDictionary *d = [_xAxisValues objectAtIndex:i];
    __block BOOL foundValue = NO;
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSNumber *k = (NSNumber *)key;
      if([k doubleValue] == [value doubleValue]) {
        foundValue = YES;
        *stop = foundValue;
      }
    }];
    if(foundValue){
      return i;
    }
  }
  return -1;
}

- (void)drawPlot:(SHPlot *)plot
{
  NSDictionary *theme = plot.plotThemeAttributes;
  
  //
  CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
  backgroundLayer.frame = self.bounds;
  backgroundLayer.fillColor = ((UIColor *)theme[kPlotFillColorKey]).CGColor;
  backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
  [backgroundLayer setStrokeColor:[UIColor clearColor].CGColor];
  [backgroundLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
  CGMutablePathRef backgroundPath = CGPathCreateMutable();

  //
  CAShapeLayer *circleLayer = [CAShapeLayer layer];
  circleLayer.frame = self.bounds;
  circleLayer.fillColor = ((UIColor *)theme[kPlotPointFillColorKey]).CGColor;
  circleLayer.backgroundColor = [UIColor clearColor].CGColor;
  [circleLayer setStrokeColor:((UIColor *)theme[kPlotPointFillColorKey]).CGColor];
  [circleLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
  CGMutablePathRef circlePath = CGPathCreateMutable();

  //
  CAShapeLayer *graphLayer = [CAShapeLayer layer];
  graphLayer.frame = self.bounds;
  graphLayer.fillColor = [UIColor clearColor].CGColor;
  graphLayer.backgroundColor = [UIColor clearColor].CGColor;
  [graphLayer setStrokeColor:((UIColor *)theme[kPlotStrokeColorKey]).CGColor];
  [graphLayer setLineWidth:((NSNumber *)theme[kPlotStrokeWidthKey]).intValue];
  CGMutablePathRef graphPath = CGPathCreateMutable();
  
  double yRange = [_yAxisRange doubleValue]; // this value will be in dollars
  double yIntervalValue = yRange / INTERVAL_COUNT;
  
  //logic to fill the graph path, ciricle path, background path.
  [plot.plottingValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *dic = (NSDictionary *)obj;
    
    __block NSNumber *_key = nil;
    __block NSNumber *_value = nil;
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      _key = (NSNumber *)key;
      _value = (NSNumber *)obj;
    }];
    
    int xIndex = [self getIndexForValue:_key forPlot:plot];
    
    //x value
    double height = self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE;
    double y = height - ((height / ([_yAxisRange doubleValue] + yIntervalValue)) * [_value doubleValue]);
    (plot.xPoints[xIndex]).x = ceil((plot.xPoints[xIndex]).x);
    (plot.xPoints[xIndex]).y = ceil(y);
  }];
  
  //move to initial point for path and background.
  CGPathMoveToPoint(graphPath, NULL, _leftMarginToLeave, plot.xPoints[0].y);
  CGPathMoveToPoint(backgroundPath, NULL, _leftMarginToLeave, plot.xPoints[0].y);
  
  int count = _xAxisValues.count;
  for (int i=0; i< count; i++)
  {
    CGPoint point = plot.xPoints[i];
    CGPathAddLineToPoint(graphPath, NULL, point.x, point.y);
    CGPathAddLineToPoint(backgroundPath, NULL, point.x, point.y);
    CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(point.x - 5, point.y - 5, 10, 10));
  }
  
  //move to initial point for path and background.
  CGPathAddLineToPoint(graphPath, NULL, _leftMarginToLeave + PLOT_WIDTH, plot.xPoints[count -1].y);
  CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave + PLOT_WIDTH, plot.xPoints[count - 1].y);
  
  //additional points for background.
  CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave + PLOT_WIDTH, self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
  CGPathAddLineToPoint(backgroundPath, NULL, _leftMarginToLeave, self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
  CGPathCloseSubpath(backgroundPath);
  backgroundLayer.path = backgroundPath;
  graphLayer.path = graphPath;
  circleLayer.path = circlePath;
  
  //animation
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  animation.duration = 1;
  animation.fromValue = @(0.0);
  animation.toValue = @(1.0);
  [graphLayer addAnimation:animation forKey:@"strokeEnd"];
  
  backgroundLayer.zPosition = 0;
  graphLayer.zPosition = 1;
  circleLayer.zPosition = 2;
  
  [self.layer addSublayer:graphLayer];
  [self.layer addSublayer:circleLayer];
  [self.layer addSublayer:backgroundLayer];
	
	NSUInteger count2 = _xAxisValues.count;
	for (int i=0; i< count2; i++)
    {
		CGPoint point = plot.xPoints[i];
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.backgroundColor = [UIColor clearColor];
		btn.tag = i;
		btn.frame = CGRectMake(point.x - 20, point.y - 20, 40, 40);
		[btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
		objc_setAssociatedObject(btn, kAssociatedPlotObject, plot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:btn];
	}
}

- (void)drawXLabels:(SHPlot *)plot
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE, self.bounds.size.width, BOTTOM_MARGIN_TO_LEAVE)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
  int xIntervalCount = _xAxisValues.count;
  double xIntervalInPx = PLOT_WIDTH / _xAxisValues.count;
  
  //initialize actual x points values where the circle will be
  plot.xPoints = calloc(sizeof(CGPoint), xIntervalCount);
  
  for(int i=0; i < xIntervalCount; i++)
  {
//    CGPoint currentLabelPoint = CGPointMake((xIntervalInPx * i) + _leftMarginToLeave, self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE);
//    CGRect xLabelFrame = CGRectMake(currentLabelPoint.x , currentLabelPoint.y, xIntervalInPx, BOTTOM_MARGIN_TO_LEAVE);
    
      CGPoint currentLabelPoint = CGPointMake((xIntervalInPx * i) + _leftMarginToLeave, 0);
      CGRect xLabelFrame = CGRectMake(currentLabelPoint.x , currentLabelPoint.y, xIntervalInPx, BOTTOM_MARGIN_TO_LEAVE);
      
    plot.xPoints[i] = CGPointMake((int) xLabelFrame.origin.x + (xLabelFrame.size.width /2) , (int) 0);
    
    UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:xLabelFrame];
    xAxisLabel.backgroundColor = [UIColor clearColor];
    xAxisLabel.font = (UIFont *)_themeAttributes[kXAxisLabelFontKey];
    
    xAxisLabel.textColor = (UIColor *)_themeAttributes[kXAxisLabelColorKey];
    xAxisLabel.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *dic = [_xAxisValues objectAtIndex:i];
    __block NSString *xLabel = nil;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      xLabel = (NSString *)obj;
    }];
    
    xAxisLabel.text = [NSString stringWithFormat:@"%@", xLabel];
//    [self addSubview:xAxisLabel];
      [bottomView addSubview:xAxisLabel];
  }
}


/**
 绘制Y轴的label

 @param plot
 */
- (void)drawYLabels:(SHPlot *)plot
{
 // double yRange = [_yAxisRange doubleValue]; // this value will be in dollars
//  double yIntervalValue = yRange / INTERVAL_COUNT;
  double intervalInPx = (self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE ) / (INTERVAL_COUNT +1);
  
  NSMutableArray *labelArray = [NSMutableArray array];
  float maxWidth = 0;
  NSArray *yValues = @[@120, @100, @80, @60, @50];
    
    CGFloat labelW = 40;
  
//  for(int i= INTERVAL_COUNT + 1; i >= 0; i--){
    for (int i= INTERVAL_COUNT; i >= 0; i--)
    {
    CGPoint currentLinePoint = CGPointMake(_leftMarginToLeave, i * intervalInPx);
//      左侧
//    CGRect lableFrame = CGRectMake(0, currentLinePoint.y - (intervalInPx / 2), 100, intervalInPx);
// 右侧
//    CGRect lableFrame = CGRectMake(self.frame.size.width - labelW - 20, currentLinePoint.y + (intervalInPx / 4), labelW, intervalInPx);
//        CGRect lableFrame = CGRectMake(self.frame.size.width - labelW - 8, currentLinePoint.y + (intervalInPx / 4), labelW, 20);
        CGRect lableFrame = CGRectMake(self.frame.size.width - labelW - 8, currentLinePoint.y, labelW, 20);
    
    if(i != 0)
    {
      UILabel *yAxisLabel = [[UILabel alloc] initWithFrame:lableFrame];
        yAxisLabel.backgroundColor = [UIColor clearColor]; // [UIColor greenColor];
      yAxisLabel.font = (UIFont *)_themeAttributes[kYAxisLabelFontKey];
      yAxisLabel.textColor = (UIColor *)_themeAttributes[kYAxisLabelColorKey];
      yAxisLabel.textAlignment = NSTextAlignmentRight;
//      float val = (yIntervalValue * (10 - i));
//      if(val > 0){
//        yAxisLabel.text = [NSString stringWithFormat:@"%.1f%@", val, _yAxisSuffix];
//      } else {
//        yAxisLabel.text = [NSString stringWithFormat:@"%.0f", val];
//      }
        yAxisLabel.text = [NSString stringWithFormat:@"%@%@", yValues[i-1], _yAxisSuffix];
//      [yAxisLabel sizeToFit];
        
        
        /*
//      CGRect newLabelFrame = CGRectMake(0, currentLinePoint.y - (yAxisLabel.layer.frame.size.height / 2), yAxisLabel.frame.size.width, yAxisLabel.layer.frame.size.height);
        CGRect newLabelFrame = CGRectMake(self.frame.size.width - yAxisLabel.frame.size.width, currentLinePoint.y + (yAxisLabel.layer.frame.size.height / 4), yAxisLabel.frame.size.width, yAxisLabel.layer.frame.size.height);
//        CGRect newLabelFrame = CGRectMake(self.frame.size.width - yAxisLabel.frame.size.width, currentLinePoint.y + (yAxisLabel.layer.frame.size.height / 4), 40, yAxisLabel.layer.frame.size.height);
//        yAxisLabel.adjustsFontSizeToFitWidth = YES;
    
      yAxisLabel.frame = newLabelFrame;
      if (newLabelFrame.size.width > maxWidth) {
        maxWidth = newLabelFrame.size.width;
      }*/
      
      [labelArray addObject:yAxisLabel];
      [self addSubview:yAxisLabel];
    }
  }
  
//  _leftMarginToLeave = maxWidth + [_themeAttributes[kYAxisLabelSideMarginsKey] doubleValue];
//  for( UILabel *l in labelArray)
//  {
//    CGSize newSize = CGSizeMake(_leftMarginToLeave, l.frame.size.height);
//    CGRect newFrame = l.frame;
//    newFrame.size = newSize;
//    l.frame = newFrame;
//  }
}


/**
 画虚线

 @param plot
 */
- (void)drawLines:(SHPlot *)plot
{
  CAShapeLayer *linesLayer = [CAShapeLayer layer];
  linesLayer.frame = self.bounds;
  linesLayer.fillColor = [UIColor clearColor].CGColor;
  linesLayer.backgroundColor = [UIColor clearColor].CGColor;
  linesLayer.strokeColor = ((UIColor *)_themeAttributes[kPlotBackgroundLineColorKye]).CGColor;
  linesLayer.lineWidth = 1; // 宽度
    
    /**** 设置虚线(去掉变成实线) ****/
    //  设置虚线
    [linesLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
//    [linesLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:3], nil]];
    [linesLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:1], nil]];
    /**** 设置虚线 ****/
  
  CGMutablePathRef linesPath = CGPathCreateMutable();
  
  double intervalInPx = (self.bounds.size.height - BOTTOM_MARGIN_TO_LEAVE) / (INTERVAL_COUNT + 1);
  for(int i= INTERVAL_COUNT + 1; i > 0; i--){
//    CGPoint currentLinePoint = CGPointMake(_leftMarginToLeave, (i * intervalInPx));
      CGPoint currentLinePoint = CGPointMake(0, (i * intervalInPx));
    CGPathMoveToPoint(linesPath, NULL, currentLinePoint.x, currentLinePoint.y);
//    CGPathAddLineToPoint(linesPath, NULL, currentLinePoint.x + PLOT_WIDTH, currentLinePoint.y);
      CGPathAddLineToPoint(linesPath, NULL, currentLinePoint.x + self.frame.size.width, currentLinePoint.y);
  }
  linesLayer.path = linesPath;
  [self.layer addSublayer:linesLayer];
}

#pragma mark - UIButton event methods
- (void)clicked:(id)sender
{
	@try {
		UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
		lbl.backgroundColor = [UIColor clearColor];
    UIButton *btn = (UIButton *)sender;
		NSUInteger tag = btn.tag;
    
    SHPlot *_plot = objc_getAssociatedObject(btn, kAssociatedPlotObject);
		NSString *text = [_plot.plottingPointsLabels objectAtIndex:tag];
		lbl.text = text;
		lbl.textColor = [UIColor whiteColor];
		lbl.textAlignment = NSTextAlignmentCenter;
		lbl.font = (UIFont *)_plot.plotThemeAttributes[kPlotPointValueFontKey];
		[lbl sizeToFit];
		lbl.frame = CGRectMake(0, 0, lbl.frame.size.width + 5, lbl.frame.size.height);
		
		CGPoint point =((UIButton *)sender).center;
		point.y -= 15;
		
		dispatch_async(dispatch_get_main_queue(), ^{
//			[PopoverView showPopoverAtPoint:point
//                               inView:self
//                      withContentView:lbl
//                             delegate:nil];
            
            CustomPopOverView *view = [CustomPopOverView popOverView];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:text forState:UIControlStateNormal];
            btn.bounds = CGRectMake(0, 0, 30, 20);
            view.content = btn;
//            btn.backgroundColor = [UIColor redColor];
            [view showFrom:sender alignStyle:CPAlignStyleCenter];
            
//            UIViewController *vc = [[UIViewController alloc] init];
//            vc.view.backgroundColor = [UIColor yellowColor];
//            vc.view.frame = CGRectMake(0, 0, 20, 20);
//            UILabel *lab = [[UILabel alloc] initWithFrame:vc.view.bounds];
//            lab.center = vc.view.center;
//            lab.text = text;
//            [vc.view addSubview:lab];
//            CustomPopOverView *view = [CustomPopOverView popOverView];
//            view.contentViewController = vc;
//            [view showFrom:sender alignStyle:CPAlignStyleLeft];
		});
	}
	@catch (NSException *exception) {
		NSLog(@"plotting label is not available for this point");
	}
}

#pragma mark - Theme Key Extern Keys

NSString *const kXAxisLabelColorKey         = @"kXAxisLabelColorKey";
NSString *const kXAxisLabelFontKey          = @"kXAxisLabelFontKey";
NSString *const kYAxisLabelColorKey         = @"kYAxisLabelColorKey";
NSString *const kYAxisLabelFontKey          = @"kYAxisLabelFontKey";
NSString *const kYAxisLabelSideMarginsKey   = @"kYAxisLabelSideMarginsKey";
NSString *const kPlotBackgroundLineColorKye = @"kPlotBackgroundLineColorKye";

@end

//
//  MSSegmentView.m
//  CoolNaviDemo
//
//  Created by ms on 2017/4/21.
//  Copyright © 2017年 ian. All rights reserved.
//

#import "MSSegmentView.h"
#import "ZJTitleView.h"
#import "UIView+ZJFrame.h"

#define TitleMargin 20
@interface MSSegmentView ()<UIScrollViewDelegate> {
    CGFloat _currentWidth;
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
}
// 滚动条
@property (strong, nonatomic) UIView *scrollLine;
/** 滚动条的高度 */
@property (assign, nonatomic) CGFloat scrollLineHeight;

// 遮盖
@property (strong, nonatomic) UIView *coverLayer;
// 滚动scrollView
@property (strong, nonatomic) UIScrollView *scrollView;
// 用于懒加载计算文字的rgb差值, 用于颜色渐变的时候设置
@property (strong, nonatomic) NSArray *deltaRGB;
@property (strong, nonatomic) NSArray *selectedColorRgb;
@property (strong, nonatomic) NSArray *normalColorRgb;
/** 缓存所有标题label */
@property (nonatomic, strong) NSMutableArray *titleViews;
// 缓存计算出来的每个标题的宽度
@property (nonatomic, strong) NSMutableArray *titleWidths;
// 缓存计算出来的每个标题的实际宽度 - 用作scrollline的宽度
@property (nonatomic, strong) NSMutableArray *actureTitleWidths;
// 响应标题点击
@property (copy, nonatomic) TitleBtnOnClickBlock titleBtnOnClick;
@end

@implementation MSSegmentView
/*********************************************************
 Plain样式 -- section 跟随tableView滚动
 *********************************************************/
- (void)setFrame:(CGRect)frame
{
    CGRect sectionRect = [self.tableView rectForSection:self.section];
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(sectionRect), CGRectGetWidth(frame), CGRectGetHeight(frame));
    [super setFrame:newFrame];
}
/*********************************************************
 Plain样式 -- section 跟随tableView滚动
 *********************************************************/




/*********************************************************
 CONFIGURATION
 *********************************************************/
- (void)dealloc
{
#if DEBUG
    NSLog(@"%s", __func__);
#endif
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
//- (instancetype)initWithFrame:(CGRect )frame segmentStyle:(ZJSegmentStyle *)segmentStyle titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick
- (void)setFrame:(CGRect )frame titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick
{
    self.titles = titles;
    self.titleBtnOnClick = titleDidClick;
    _currentIndex = 0;
    _oldIndex = 0;
    _currentWidth = frame.size.width;
    self.bottomMargin = self.bottomMargin ? self.bottomMargin : 0;
    
    // 设置了frame之后可以直接设置其他的控件的frame了, 不需要在layoutsubView()里面设置
    [self setupSubviews];
    [self setupUI];
}
#pragma mark - private helper
#pragma mark - setupSubviews
- (void)setupSubviews
{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollLine];
    [self setupTitles];
}
- (void)setupTitles
{
    if (self.titles.count == 0)
    {
        return;
    }
    
    NSInteger index = 0;
    for (NSString *title in self.titles) {
        ZJTitleView *titleView = [[ZJTitleView alloc] initWithFrame:CGRectZero];
        titleView.tag = index;
        titleView.font = [UIFont systemFontOfSize:18.f];
        titleView.text = title;
        titleView.textColor = self.normalTitleColor;
        titleView.backgroundColor = [UIColor purpleColor];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelOnClick:)];
        [titleView addGestureRecognizer:tapGes];
        CGFloat titleViewWidth = [titleView titleViewWidth];
        
        CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(self.frame.size.width /3.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size.width;
        
        [self.actureTitleWidths addObject:@(titleWidth)];
        [self.titleWidths addObject:@(titleViewWidth)];
        
        [self.titleViews addObject:titleView];
        [self.scrollView addSubview:titleView];
        index++;
    }
}
#pragma mark - setupUI
- (void)setupUI
{
    if (self.titles.count == 0) {
        return;
    }
    [self setupScrollView];
    [self setUpTitleViewsPosition];
    [self setupScrollLineAndCover];
    //    if (self.segmentStyle.isScrollTitle) { // 设置滚动区域
    //        ZJTitleView *lastTitleView = (ZJTitleView *)self.titleViews.lastObject;
    //        if (lastTitleView) {
    //            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTitleView.frame) + contentSizeXOff, 0.0);
    //        }
    //    }
}
- (void)setupScrollView
{
    CGFloat scrollW = _currentWidth;
    self.scrollView.frame = CGRectMake(0.0, 0.0, scrollW, self.zj_height);
}
- (void)setUpTitleViewsPosition
{
    self.scrollLineHeight = 4.0;
    CGFloat titleX = 0.0;
    CGFloat titleY = 0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.frame.size.height - self.scrollLineHeight - self.bottomMargin;
    
    titleW = self.scrollView.bounds.size.width / self.titles.count;
    NSInteger index = 0;
    for (ZJTitleView *titleView in self.titleViews) {
        titleX = index * titleW;
        titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
        index++;
    }
    
    ZJTitleView *currentTitleView = (ZJTitleView *)self.titleViews[_currentIndex];
    currentTitleView.currentTransformSx = 1.0;
    if (currentTitleView) {
        // 设置初始状态文字的颜色
        currentTitleView.textColor = self.selectedTitleColor;
    }
}

- (void)setupScrollLineAndCover
{
    ZJTitleView *firstLabel = (ZJTitleView *)self.titleViews[0];
    CGFloat coverX = firstLabel.zj_x;
    CGFloat coverW = firstLabel.zj_width;
    coverW = [self.actureTitleWidths[_currentIndex] floatValue];
    coverX = ([self.titleWidths[_currentIndex] floatValue] - [self.actureTitleWidths[_currentIndex] floatValue]) * 0.5;
    self.scrollLine.frame = CGRectMake(coverX , self.frame.size.height - self.scrollLineHeight - self.bottomMargin, coverW , self.scrollLineHeight);
}





/*********************************************************
 ACTIONS
 *********************************************************/
#pragma mark - button action
- (void)titleLabelOnClick:(UITapGestureRecognizer *)tapGes
{
    ZJTitleView *currentLabel = (ZJTitleView *)tapGes.view;
    if (!currentLabel) {
        return;
    }
    _currentIndex = currentLabel.tag;
    [self adjustUIWhenBtnOnClickWithAnimate:true taped:YES];
}

#pragma mark - public helper
// 点击按钮调用
- (void)adjustUIWhenBtnOnClickWithAnimate:(BOOL)animated taped:(BOOL)taped
{
    if (_currentIndex == _oldIndex && taped) { return; }
    
    ZJTitleView *oldTitleView = (ZJTitleView *)self.titleViews[_oldIndex];
    ZJTitleView *currentTitleView = (ZJTitleView *)self.titleViews[_currentIndex];
    CGFloat animatedTime = animated ? 0.30 : 0.0;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animatedTime animations:^{
        oldTitleView.textColor = weakSelf.normalTitleColor;
        currentTitleView.textColor = weakSelf.selectedTitleColor;
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        
        if (weakSelf.scrollLine)
        {
            _oldIndex = _currentIndex;
            ZJTitleView *oldTitleView = (ZJTitleView *)self.titleViews[_oldIndex];
            CGFloat oldTitleWidth = [self.actureTitleWidths[_oldIndex] floatValue];
            weakSelf.scrollLine.zj_x = oldTitleView.zj_x + (oldTitleView.zj_width / 2.0 - oldTitleWidth / 2.0);
            weakSelf.scrollLine.zj_width = oldTitleWidth;
        }
        
        if (weakSelf.coverLayer) {
            CGFloat coverW = [self.titleWidths[_currentIndex] floatValue] + 0;
            CGFloat coverX = currentTitleView.zj_x + (currentTitleView.zj_width - coverW) * 0.5;
            weakSelf.coverLayer.zj_x = coverX;
            weakSelf.coverLayer.zj_width = coverW;
        }
        
    } completion:^(BOOL finished) {
        [weakSelf adjustTitleOffSetToCurrentIndex:_currentIndex];
    }];
    
    _oldIndex = _currentIndex;
    if (self.titleBtnOnClick) {
        self.titleBtnOnClick(currentTitleView, _currentIndex);
    }
}
// 滚动调用
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex
{
    if (oldIndex < 0 ||
        oldIndex >= self.titles.count ||
        currentIndex < 0 ||
        currentIndex >= self.titles.count
        ) {
        return;
    }
    _oldIndex = currentIndex;
    ZJTitleView *oldTitleView = (ZJTitleView *)self.titleViews[oldIndex];
    ZJTitleView *currentTitleView = (ZJTitleView *)self.titleViews[currentIndex];
    CGFloat oldTitleWidth = [self.actureTitleWidths[oldIndex] floatValue];
    CGFloat currentTitleWidth = [self.actureTitleWidths[currentIndex] floatValue];
    CGFloat xDistance = currentTitleView.zj_x - oldTitleView.zj_x;
    CGFloat wDistance = currentTitleView.zj_width - oldTitleView.zj_width;
    
    if (self.scrollLine)
    {
        CGFloat oldScrollLineW = oldTitleWidth;
        CGFloat currentScrollLineW = currentTitleWidth;
        
        wDistance = currentScrollLineW - oldScrollLineW;
        CGFloat oldScrollLineX = oldTitleView.zj_x + (oldTitleView.zj_width - oldScrollLineW) * 0.5;
        CGFloat currentScrollLineX = currentTitleView.zj_x + (currentTitleView.zj_width - currentScrollLineW) * 0.5;
        xDistance = currentScrollLineX - oldScrollLineX;
        self.scrollLine.zj_x = oldScrollLineX + xDistance * progress;
        self.scrollLine.zj_width = oldScrollLineW + wDistance * progress;
    }
    
    if (self.coverLayer) {
        CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue];
        CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue];
        wDistance = currentCoverW - oldCoverW;
        CGFloat oldCoverX = oldTitleView.zj_x + (oldTitleView.zj_width - oldCoverW) * 0.5;
        CGFloat currentCoverX = currentTitleView.zj_x + (currentTitleView.zj_width - currentCoverW) * 0.5;
        xDistance = currentCoverX - oldCoverX;
        self.coverLayer.zj_x = oldCoverX + xDistance * progress;
        self.coverLayer.zj_width = oldCoverW + wDistance * progress;
    }
    
    // 渐变
    if (self.isGradualChangeTitleColor) {
        oldTitleView.textColor = [UIColor colorWithRed:[self.selectedColorRgb[0] floatValue] + [self.deltaRGB[0] floatValue] * progress green:[self.selectedColorRgb[1] floatValue] + [self.deltaRGB[1] floatValue] * progress blue:[self.selectedColorRgb[2] floatValue] + [self.deltaRGB[2] floatValue] * progress alpha:1.0];
        currentTitleView.textColor = [UIColor colorWithRed:[self.normalColorRgb[0] floatValue] - [self.deltaRGB[0] floatValue] * progress green:[self.normalColorRgb[1] floatValue] - [self.deltaRGB[1] floatValue] * progress blue:[self.normalColorRgb[2] floatValue] - [self.deltaRGB[2] floatValue] * progress alpha:1.0];
    }
}
// 点击按钮调用 + 滚动调用
- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex
{
    _oldIndex = currentIndex;
    // 重置渐变/缩放效果附近其他item的缩放和颜色
    int index = 0;
    for (ZJTitleView *titleView in _titleViews) {
        if (index != currentIndex) {
            titleView.textColor = self.normalTitleColor;
            titleView.currentTransformSx = 1.0;
            titleView.selected = NO;
            
        }
        else {
            titleView.textColor = self.selectedTitleColor;
            titleView.selected = YES;
        }
        index++;
    }
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width) {// 需要滚动
        ZJTitleView *currentTitleView = (ZJTitleView *)_titleViews[currentIndex];
        CGFloat offSetx = currentTitleView.center.x - _currentWidth * 0.5;
        if (offSetx < 0) {
            offSetx = 0;
            
        }
        CGFloat extraBtnW = 0.0;
        CGFloat maxOffSetX = self.scrollView.contentSize.width - (_currentWidth - extraBtnW);
        
        if (maxOffSetX < 0) {
            maxOffSetX = 0;
        }
        
        if (offSetx > maxOffSetX) {
            offSetx = maxOffSetX;
        }
        [self.scrollView setContentOffset:CGPointMake(offSetx, 0.0) animated:YES];
    }
}

/*********************************************************
 OPTION 可选方法 == 暂未使用
 *********************************************************/
/**
 设置选中
 
 @param index 选中下标
 @param animated 动画
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    NSAssert(index >= 0 && index < self.titles.count, @"设置的下标不合法!!");
    if (index < 0 || index >= self.titles.count) {
        return;
    }
    _currentIndex = index;
    [self adjustUIWhenBtnOnClickWithAnimate:animated taped:NO];
}
/**
 重置
 
 @param titles 标题
 */
- (void)reloadTitlesWithNewTitles:(NSArray *)titles
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _currentIndex = 0;
    _oldIndex = 0;
    self.titleWidths = nil;
    self.actureTitleWidths = nil;
    self.titleViews = nil;
    self.titles = nil;
    self.titles = [titles copy];
    if (self.titles.count == 0) return;
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    [self setupSubviews];
    [self setupUI];
    [self setSelectedIndex:0 animated:YES];
}
/*********************************************************
 OPTION 可选方法 == 暂未使用
 *********************************************************/






/*********************************************************
 SETTER AND GETTER
 *********************************************************/
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.bounces = self.isSegmentViewBounces;
        scrollView.pagingEnabled = NO;
        scrollView.delegate = self;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)scrollLine
{
    if (!_scrollLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor redColor]; // 设置下划线为红色
        _scrollLine = lineView;
    }
    return _scrollLine;
}

- (NSMutableArray *)titleViews
{
    if (_titleViews == nil) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}
- (NSMutableArray *)actureTitleWidths
{
    if (!_actureTitleWidths) {
        _actureTitleWidths = [NSMutableArray array];
    }
    return _actureTitleWidths;
}

- (NSArray *)deltaRGB {
    if (_deltaRGB == nil) {
        NSArray *normalColorRgb = self.normalColorRgb;
        NSArray *selectedColorRgb = self.selectedColorRgb;
        
        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), nil];
            _deltaRGB = delta;
            
        }
    }
    return _deltaRGB;
}

- (NSArray *)normalColorRgb {
    if (!_normalColorRgb) {
        NSArray *normalColorRgb = [self getColorRgb:self.normalTitleColor];
        NSAssert(normalColorRgb, @"设置普通状态的文字颜色时 请使用RGB空间的颜色值");
        _normalColorRgb = normalColorRgb;
        
    }
    return  _normalColorRgb;
}

- (NSArray *)selectedColorRgb {
    if (!_selectedColorRgb) {
        NSArray *selectedColorRgb = [self getColorRgb:self.selectedTitleColor];
        NSAssert(selectedColorRgb, @"设置选中状态的文字颜色时 请使用RGB空间的颜色值");
        _selectedColorRgb = selectedColorRgb;
        
    }
    return  _selectedColorRgb;
}

- (NSArray *)getColorRgb:(UIColor *)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    return rgbComponents;
    
}
@end

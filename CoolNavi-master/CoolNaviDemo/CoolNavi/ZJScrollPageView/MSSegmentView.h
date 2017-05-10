//
//  MSSegmentView.h
//  CoolNaviDemo
//
//  Created by ms on 2017/4/21.
//  Copyright © 2017年 ian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJTitleView;

typedef void(^TitleBtnOnClickBlock)(ZJTitleView *titleView, NSInteger index);


@interface MSSegmentView : UIView
// Plain样式 -- section 跟随tableView滚动
@property NSUInteger section;
@property (nonatomic, weak) UITableView *tableView;
/** 标题一般状态的颜色 */
@property (strong, nonatomic) UIColor *normalTitleColor;
/** 标题选中状态的颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/** segmentView是否有弹性 默认为YES*/
@property (assign, nonatomic, getter=isSegmentViewBounces) BOOL segmentViewBounces;
/** contentView是否有弹性 默认为YES*/
@property (assign, nonatomic, getter=isContentViewBounces) BOOL contentViewBounces;
/** 是否颜色渐变 默认为NO*/
@property (assign, nonatomic, getter=isGradualChangeTitleColor) BOOL gradualChangeTitleColor;
/** 下划线与底部的空白间隙 */
@property (assign, nonatomic) CGFloat bottomMargin;

// 所有的标题
@property (strong, nonatomic) NSArray *titles;
//- (instancetype)initWithFrame:(CGRect )frame titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick;
- (void)setFrame:(CGRect )frame titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick;
@end

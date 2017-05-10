//
//  ViewController.m
//  CoolNavi
//
//  Created by ian on 15/1/19.
//  Copyright (c) 2015年 ian. All rights reserved.
//

#import "ViewController.h"
#import "CoolNavi.h"
#import "BottomVertiButton.h"
#import "MSSegmentView.h"

// 图片浏览器
#import "XLPhotoBrowser.h"
#import "SDImageCache.h"


static CGFloat const kWindowHeight = 300;//205.0f;
static NSUInteger const kCellNum = 4;//40;
static NSUInteger const kRowHeight = 44;
static CGFloat const bottomHeight = 80;
static CGFloat const segmentViewHeight = 55.0;


static NSString * const kCellIdentify = @"cell";

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
XLPhotoBrowserDelegate,
XLPhotoBrowserDatasource
>
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *titles;

@property (strong, nonatomic) MSSegmentView *segmentView;
@property (nonatomic, copy) NSString *urlStrings;
@end

@implementation ViewController
#pragma mark - life sytle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//    CoolNavi *headerView = [[CoolNavi alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kWindowHeight) backGroudImage:@"background" headerImageURL:@"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg" title:@"妹子!" subTitle:@"个性签名, 啦啦啦!"];
    
    
    __weak typeof(self) weakSelf = self;
    self.urlStrings = @"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg";
    CoolNavi *headerView = [[CoolNavi alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kWindowHeight) backGroudImage:@"new-bg.png" headerImageURL:self.urlStrings title:@"妹子!" subTitle:@"个性签名, 啦啦啦!"];
    headerView.scrollView = self.tableView;
    headerView.imgActionBlock = ^(){
        NSLog(@"headerImageAction");
        // 快速创建并进入浏览模式
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:0 imageCount:1 datasource:self];
        // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
        [browser setActionSheetWithTitle:@"这是一个类似微信/微博的图片浏览器组件" delegate:self cancelButtonTitle:nil deleteButtonTitle:nil otherButtonTitles:@"发送给朋友",@"保存图片",@"收藏",@"投诉",nil];
        
        // 自定义一些属性
        browser.pageDotColor = [UIColor purpleColor]; ///< 此属性针对动画样式的pagecontrol无效
        browser.currentPageDotColor = [UIColor whiteColor];
        browser.pageControlStyle = XLPhotoBrowserPageControlStyleAnimated;///< 修改底部pagecontrol的样式为系统样式,默认是弹性动画的样式
    };
    [self.view addSubview:headerView];
    
    // 添加跳过按钮：使用自定义方式
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reportButton.showsTouchWhenHighlighted = YES;
    [reportButton setTitle:@"举报" forState:UIControlStateNormal];
    [reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    reportButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    reportButton.frame = CGRectMake(self.view.frame.size.width - 44, 20, 44, 44);
    [reportButton addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reportButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - bottomHeight, CGRectGetWidth(self.view.frame), bottomHeight)];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [UIColor redColor];
    [self.view bringSubviewToFront:bottomView];
    
    
    CGFloat buttonW = self.view.frame.size.width * 0.5;
    CGFloat buttonH = bottomHeight;
    
    // 会话按钮
    BottomVertiButton *chatButton = [BottomVertiButton buttonWithType:UIButtonTypeCustom];
    chatButton.frame = CGRectMake(0, 0, buttonW, buttonH);
    [bottomView addSubview:chatButton];
    chatButton.verTitleLabel.text = @"会话";
    chatButton.verTitleLabel.textAlignment = NSTextAlignmentCenter;
    chatButton.verTitleLabel.font = [UIFont systemFontOfSize:16];
    chatButton.verTitleLabel.textColor = [UIColor redColor];
    chatButton.verImageView.image = [UIImage imageNamed:@"huihua"];
    //    self.searchButton = searchButton;
    //    [self.searchButton addActionHandler:^(NSInteger tag) {
    //        // 隐藏掉showbutton
    //        weakSelf.showButton.hidden = YES;
    //        // 开始搜索设备
    //        [weakSelf startSearchDevice];
    //    }];
    
    // 会话按钮
    BottomVertiButton *addButton = [BottomVertiButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(buttonW, 0, buttonW, buttonH);
    [bottomView addSubview:addButton];
    addButton.verTitleLabel.text = @"加好友";
    addButton.verTitleLabel.textAlignment = NSTextAlignmentCenter;
    addButton.verTitleLabel.font = [UIFont systemFontOfSize:16];
    addButton.verTitleLabel.textColor = [UIColor redColor];
    addButton.verImageView.image = [UIImage imageNamed:@"jiahaoyou"];
}


#pragma mark    -   XLPhotoBrowserDatasource
/**
 *  返回这个位置的占位图片 , 也可以是原图(如果不实现此方法,会默认使用placeholderImage)
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 占位图片
 */
/*- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.images[index];
}*/
/**
 *  返回指定位置的高清图片URL
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.urlStrings];
}

#pragma mark    -   XLPhotoBrowserDelegate
- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    // do something yourself
    switch (actionSheetindex) {
        case 1: // 保存
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
            [browser saveCurrentShowImage];
        }
            break;
        default:
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
        }
            break;
    }
}






- (void)reportAction
{
    NSLog(@"举报");
}
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - getter and setter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentify];
        [self.view addSubview:_tableView];
        //_tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 44;
        _tableView.sectionHeaderHeight = segmentViewHeight;
    }
    return _tableView;
}

#pragma mark - tableView Delegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kCellNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"test %ld",(long)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.segmentView.section = section;
    self.segmentView.tableView = tableView;
    return self.segmentView;
}

#pragma mark- setter getter
- (MSSegmentView *)segmentView
{
    if (!_segmentView) {
        MSSegmentView *segment = [[MSSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, segmentViewHeight)];
        _segmentView = segment;
        // 颜色渐变
        segment.gradualChangeTitleColor = YES;
        //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
        segment.normalTitleColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.0];
        //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
        segment.selectedTitleColor = [UIColor redColor];
        // 与底部的间隙距离
        segment.bottomMargin = 5;
        segment.segmentViewBounces = YES;
        segment.contentViewBounces = YES;
        self.titles = @[
                        @"TA的资料",
                        @"TA的相册",
                        @"TA的圈子"
                        ];
        segment.backgroundColor = [UIColor orangeColor];
        // 注意: 一定要避免循环引用!!
        __weak typeof(self) weakSelf = self;
        [segment setFrame:CGRectMake(0, 64, self.view.bounds.size.width, segmentViewHeight) titles:self.titles titleDidClick:^(ZJTitleView *titleView, NSInteger index)
                                        {
                                            //            [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
                                            NSLog(@"index => %ld", (long)index);
                                        }];
    }
    return _segmentView;
}

//- (ZJScrollSegmentView *)segmentView
//{
//    if (_segmentView == nil)
//    {
//        //        //必要的设置, 如果没有设置可能导致内容显示不正常
//        //        self.automaticallyAdjustsScrollViewInsets = NO;
//        ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
//        //显示滚动条
//        style.showLine = YES;
//        // 颜色渐变
//        style.gradualChangeTitleColor = YES;
//        //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
//        style.normalTitleColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.0];
//        //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
//        style.selectedTitleColor = [UIColor redColor];
//        style.segmentViewBounces = YES;
//        style.contentViewBounces = YES;
//        
//        self.titles = @[
//                        @"TA的资料",
//                        @"TA的相册",
//                        @"TA的圈子"
//                        ];
//        // 初始化
//        // 注意: 一定要避免循环引用!!
//        __weak typeof(self) weakSelf = self;
//        ZJScrollSegmentView *segment = [[ZJScrollSegmentView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, segmentViewHeight) segmentStyle:style titles:self.titles titleDidClick:^(ZJTitleView *titleView, NSInteger index)
//        {
////            [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
//            NSLog(@"index => %ld", (long)index);
//        }];
//        segment.backgroundColor = [UIColor whiteColor];
//        _segmentView = segment;
//    }
//    return _segmentView;
//}

//- (ZJContentView *)contentView
//{
//    if (_contentView == nil) {
//        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - bottomHeight);
//        ZJContentView *content = [[ZJContentView alloc] initWithFrame:frame segmentView:self.segmentView parentViewController:self delegate:self];
//        _contentView = content;
//    }
//    return _contentView;
//}
//#pragma mark - ZJScrollSegmentViewDelegate
//- (NSInteger)numberOfChildViewControllers
//{
//    return 3;
//}
//- (UIViewController *)childViewController:(UIViewController *)reuseViewController forIndex:(NSInteger)index
//{
//    NSLog(@"index => %ld", index);
//    UIViewController *childVc = reuseViewController;
//    if (!childVc) {
//        if (index==0) {
//            childVc = [[UIViewController alloc] init];
//            UIViewController *vc = (UIViewController *)childVc;
//            vc.view.backgroundColor = [UIColor orangeColor];
//        }
//        else {
//            childVc = [[UIViewController alloc] init];
//            UIViewController *vc = (UIViewController *)childVc;
//            vc.view.backgroundColor = [UIColor blueColor];
//        }
//    }
//    return childVc;
//}
@end

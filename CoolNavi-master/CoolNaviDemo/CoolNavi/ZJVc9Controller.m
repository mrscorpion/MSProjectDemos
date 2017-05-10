//
//  ZJVcController.m
//  ZJScrollPageView
//
//  Created by ZeroJ on 16/8/31.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJVc9Controller.h"
#import "ZJScrollPageView.h"
#import "MJRefresh.h"
#import "CoolNavi.h"
#import "BottomVertiButton.h"

#import "ZJPageTableViewController.h"
#import "ZJPageCollectionViewController.h"
#import "ZJPageViewController.h"

static CGFloat const segmentViewHeight = 50.0;
static CGFloat const naviBarHeight = 64.0;
static CGFloat const headViewHeight = 0.0;//200.0;
static CGFloat const bottomHeight = 80;

//NSString *const ZJParentTableViewDidLeaveFromTopNotification = @"ZJParentTableViewDidLeaveFromTopNotification";

//@interface ZJCustomGestureTableView : UITableView
//@end
//
//@implementation ZJCustomGestureTableView
/////// 返回YES同时识别多个手势
////- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
////{
////    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
////}
////- (void)dealloc
////{
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZJParentTableViewDidLeaveFromTopNotification object:nil];
////    
////}
//@end

@interface ZJVc9Controller ()
<
ZJScrollPageViewDelegate,
ZJPageViewControllerDelegate,
UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource
>

@property (strong, nonatomic) NSArray<NSString *> *titles;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) ZJScrollSegmentView *segmentView;
@property (strong, nonatomic) ZJContentView *contentView;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UIScrollView *childScrollView;
@property (strong, nonatomic) UITableView *tableView;
@end

static CGFloat const kWindowHeight = 300;//205.0f;
static NSString * const cellID = @"cellID";

@implementation ZJVc9Controller
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"微博个人页面";
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tableView];
    [self configurationUI];
    
    
    
//    __weak typeof(self) weakself = self;
//    /// 下拉刷新
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            typeof(weakself) strongSelf = weakself;
//            [strongSelf.tableView.mj_header endRefreshing];
//        });
//    }];
}
- (void)configurationUI
{
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    //    CoolNavi *headerView = [[CoolNavi alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kWindowHeight) backGroudImage:@"background" headerImageURL:@"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg" title:@"妹子!" subTitle:@"个性签名, 啦啦啦!"];
    
    CoolNavi *headerView = [[CoolNavi alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kWindowHeight) backGroudImage:@"new-bg.png" headerImageURL:@"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg" title:@"妹子!" subTitle:@"个性签名, 啦啦啦!"];
    headerView.scrollView = self.tableView;
    headerView.imgActionBlock = ^(){
        NSLog(@"headerImageAction");
    };
    [self.view addSubview:headerView];
    
    // 添加跳过按钮：使用自定义方式
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.showsTouchWhenHighlighted = YES;
    [skipButton setTitle:@"举报" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    skipButton.frame = CGRectMake(self.view.frame.size.width - 44, 20, 44, 44);
    [skipButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:skipButton];
    
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
- (void)backAction
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZJParentTableViewDidLeaveFromTopNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma ZJScrollPageViewDelegate 代理方法
- (NSInteger)numberOfChildViewControllers
{
    return self.titles.count;
}
- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index
{
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    if (!childVc) {
        if (index%2==0) {
            childVc = [[ZJPageTableViewController alloc] init];
            ZJPageTableViewController *vc = (ZJPageTableViewController *)childVc;
            vc.delegate = self;
        }
        else {
            childVc = [[ZJPageCollectionViewController alloc] init];
            ZJPageCollectionViewController *vc = (ZJPageCollectionViewController *)childVc;
            vc.delegate = self;
        }
    }
    return childVc;
}


#pragma mark- ZJPageViewControllerDelegate
- (void)scrollViewIsScrolling:(UIScrollView *)scrollView
{
    _childScrollView = scrollView;
    if (self.tableView.contentOffset.y < headViewHeight) {
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator = NO;
    }
    else {
        self.tableView.contentOffset = CGPointMake(0.0f, headViewHeight);
        scrollView.showsVerticalScrollIndicator = YES;
    }
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.childScrollView && _childScrollView.contentOffset.y > 0) {
        self.tableView.contentOffset = CGPointMake(0.0f, headViewHeight);
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY < headViewHeight) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:ZJParentTableViewDidLeaveFromTopNotification object:nil];
    }
}

#pragma mark- UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:self.contentView];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.segmentView.section = section;
    self.segmentView.tableView = tableView;
    return self.segmentView;
}

#pragma mark- setter getter
- (ZJScrollSegmentView *)segmentView
{
    if (_segmentView == nil)
    {
//        //必要的设置, 如果没有设置可能导致内容显示不正常
//        self.automaticallyAdjustsScrollViewInsets = NO;
        
        ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
        //显示滚动条
        style.showLine = YES;
        // 颜色渐变
        style.gradualChangeTitleColor = YES;
        //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
        style.normalTitleColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.0];
        //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
        style.selectedTitleColor = [UIColor redColor];
        style.segmentViewBounces = YES;
        style.contentViewBounces = YES;
        
        self.titles = @[@"TA的资料",
                        @"TA的相册",
                        @"TA的圈子"
                        ];
//        // 初始化
//        // 注意: 一定要避免循环引用!!
//        __weak typeof(self) weakSelf = self;
//        ZJScrollSegmentView *segment = [[ZJScrollSegmentView alloc] initWithFrame:CGRectMake(0, naviBarHeight + headViewHeight, self.view.bounds.size.width, segmentViewHeight) segmentStyle:style delegate:self titles:self.titles titleDidClick:^(ZJTitleView *titleView, NSInteger index) {
//                [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
//        }];
//        segment.backgroundColor = [UIColor whiteColor];
//        _segmentView = segment;
    }
    return _segmentView;
}

- (ZJContentView *)contentView {
    if (_contentView == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - bottomHeight);
//        ZJContentView *content = [[ZJContentView alloc] initWithFrame:self.view.bounds segmentView:self.segmentView parentViewController:self delegate:self];
        ZJContentView *content = [[ZJContentView alloc] initWithFrame:frame segmentView:self.segmentView parentViewController:self delegate:self];
        _contentView = content;
    }
    return _contentView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
//        CGRect frame = CGRectMake(0.0f, 300, self.view.bounds.size.width, self.view.bounds.size.height - 300 - bottomHeight);
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kWindowHeight - bottomHeight);
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
//        ZJCustomGestureTableView *tableView = [[ZJCustomGestureTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        // 设置tableView的headView
//        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        tableView.tableFooterView = [UIView new];
        // 设置cell行高为contentView的高度
        tableView.rowHeight = self.contentView.bounds.size.height;
        tableView.delegate = self;
        tableView.dataSource = self;
        // 设置tableView的sectionHeadHeight为segmentViewHeight
        tableView.sectionHeaderHeight = segmentViewHeight;
        tableView.showsVerticalScrollIndicator = false;
        _tableView = tableView;
        tableView.backgroundColor = [UIColor lightTextColor];
    }
    return _tableView;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}
@end

//
//  ZJPageTableViewController.m
//  ZJScrollPageView
//
//  Created by ZeroJ on 16/8/31.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJPageTableViewController.h"
@interface ZJPageTableViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(strong, nonatomic)UITableView *tableView;
@property(assign, nonatomic)NSInteger index;
@end

static NSString * const cellId = @"cellID";

@implementation ZJPageTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)zj_viewDidLoadForIndex:(NSInteger)index
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    // IOS自带的分割线是距离左边有15的距离，如果不想要这个距离，可以设置
//    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    // 设置系统自带分割线距离左边60距离
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)]; // UIEdgeInsetsMake(0, 60, 0, 0)
    self.data = [NSArray array];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor lightTextColor];
    self.tableView.tableFooterView = [UIView new];
}

- (void)zj_viewDidAppearForIndex:(NSInteger)index
{
    self.index = index;
    NSLog(@"已经出现   标题: --- %@  index: -- %ld", self.title, index);
    if (index%2==0) {
        self.view.backgroundColor = [UIColor lightTextColor];
    }
    else {
        self.view.backgroundColor = [UIColor lightTextColor];
    }
    // 加载数据
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.data = @[@"兴趣爱好",@"情感状态",@"当前位置"];
        [self.tableView reloadData];
//    });
}

//- (void)zj_viewDidDisappearForIndex:(NSInteger)index {
//    NSLog(@"已经消失   标题: --- %@  index: -- %ld", self.title, index);
//    
//}

#pragma mark- ZJScrollPageViewChildVcDelegate
#pragma mark- UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"测试---- %@", self.data[indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", self.index];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"点击了%ld行----", indexPath.row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

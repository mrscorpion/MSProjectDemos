//
//  UINavigationController+Category.m
//  MSNavTransition
//
//  Created by ms on 2017/3/31.
//  Copyright © 2017年 mrscorpion. All rights reserved.
//

#import "UINavigationController+Category.h"
#import <objc/runtime.h>
#import "UIViewController+Category.h"  // Q1：相互引用，会引起循环引用吗？

@implementation UINavigationController (Category)
// 设置导航栏背景透明度
- (void)setNeedsNavigationBackground:(CGFloat)alpha
{
    // 导航栏背景透明度设置
    UIView *barBgView = [[self.navigationBar subviews] objectAtIndex:0];    // _UIBarBackground
    UIImageView *bgImageView = [[barBgView subviews] objectAtIndex:0];      // UIImageView
    if (self.navigationBar.isTranslucent) {
        if (!bgImageView && !bgImageView.image) {
            barBgView.alpha = alpha;
        }
        else {
            UIView *bgEffectView = [[barBgView subviews] objectAtIndex:1];  // UIVisualEffectView
            if (!bgEffectView) {
                bgEffectView.alpha = alpha;
            }
        }
    }
    else {
        barBgView.alpha = alpha;
    }
    
    // 对导航栏下面那条线做处理
    self.navigationBar.clipsToBounds = alpha == 0.0;
}


+ (void)initialize
{
    if (self == [UINavigationController self]) {
        // 交换方法
        SEL oriSelector = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL swiSelector = NSSelectorFromString(@"EXUpdateInteractiveTransition:");
        Method oriMethod = class_getInstanceMethod([self class], oriSelector);
        Method swiMethod = class_getInstanceMethod([self class], swiSelector);
        method_exchangeImplementations(oriMethod, swiMethod);
    }
}
// 交换的方法，监控滑动手势
- (void)EXUpdateInteractiveTransition:(CGFloat)percentComplete
{
    [self EXUpdateInteractiveTransition:(percentComplete)];
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator) {
            // 随着滑动的过程设置导航栏透明度渐变
            CGFloat fromAlpha = [[coordinator viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            CGFloat toAlpha = [[coordinator viewControllerForKey:UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
            NSLog(@"from:%f, to:%f, now:%f",fromAlpha, toAlpha, nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator) {
            [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self dealInteractionChanges:context];
            }];
        }
    }
}
- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context
{
    if ([context isCancelled]) {// 自动取消了返回手势
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            NSLog(@"自动取消返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    }
    else {// 自动完成了返回手势
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:
                                 UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            NSLog(@"自动完成返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    }
}

#pragma mark - UINavigationBar Delegate
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    if (self.viewControllers.count >= navigationBar.items.count) {// 点击返回按钮
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - 1];
        [self setNeedsNavigationBackground:[popToVC.navBarBgAlpha floatValue]];
        //        [self popViewControllerAnimated:YES];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item
{
    // push到一个新界面
    [self setNeedsNavigationBackground:[self.topViewController.navBarBgAlpha floatValue]];
}

////定义常量 必须是C语言字符串
//static char *AlphaKey = "AlphaKey";
//- (void)setDiscription:(NSString *)discription
//{
//    /*
//     OBJC_ASSOCIATION_ASSIGN;            //assign策略
//     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
//     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
//     
//     OBJC_ASSOCIATION_RETAIN;
//     OBJC_ASSOCIATION_COPY;
//     */
//    /*
//     * id object 给哪个对象的属性赋值
//     const void *key 属性对应的key
//     id value  设置属性值为value
//     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
//     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
//     */
//    objc_setAssociatedObject(self, AlphaKey, discription, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//- (NSString *)discription
//{
//    return objc_getAssociatedObject(self, AlphaKey);
//}
@end

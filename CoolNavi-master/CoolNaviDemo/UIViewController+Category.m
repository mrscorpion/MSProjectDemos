//
//  UIViewController+Category.m
//  MSNavTransition
//
//  Created by ms on 2017/3/31.
//  Copyright © 2017年 mrscorpion. All rights reserved.
//

#import "UIViewController+Category.h"
#import <objc/runtime.h>
#import "UINavigationController+Category.h"

@implementation UIViewController (Category)
static char*AlphaKey = "AlphaKey";
- (void)setNavBarBgAlpha:(NSString *)navBarBgAlpha
{
    /*
     OBJC_ASSOCIATION_ASSIGN;            //assign策略
     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
     
     OBJC_ASSOCIATION_RETAIN;
     OBJC_ASSOCIATION_COPY;
     */
    /*
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     */
    objc_setAssociatedObject(self, AlphaKey, navBarBgAlpha, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // 设置导航栏透明度（利用Category自己添加的方法）
    [self.navigationController setNeedsNavigationBackground:[navBarBgAlpha floatValue]];
}

- (NSString *)navBarBgAlpha
{
    return objc_getAssociatedObject(self, AlphaKey);
}
@end
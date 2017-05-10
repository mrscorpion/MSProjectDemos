//
//  UINavigationController+Category.h
//  MSNavTransition
//
//  Created by ms on 2017/3/31.
//  Copyright © 2017年 mrscorpion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Category)
<
UINavigationBarDelegate,
UINavigationControllerDelegate
>
//@property (nonatomic, copy) NSString *discription;

- (void)setNeedsNavigationBackground:(CGFloat)alpha;
@end

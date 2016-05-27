//
//  CustomCell.m
//  相册浏览器
//
//  Created by lxj on 16/5/25.
//  Copyright © 2016年 lxj. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //手写代码创建控件
        self.photoView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.photoView];
    }
    return self;
}

@end

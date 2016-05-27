//
//  XJPhotoViewController.h
//  相册浏览器
//
//  Created by lxj on 16/5/26.
//  Copyright © 2016年 lxj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJPhotoSearch : UIViewController

//定义一个block
typedef void(^SelectPhoto)(UIImage *photo);



-(instancetype)initWithBlock:(SelectPhoto)block;

@end

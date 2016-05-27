//
//  PhotoViewController.h
//  相册浏览器
//
//  Created by lxj on 16/5/26.
//  Copyright © 2016年 lxj. All rights reserved.
//

#import <UIKit/UIKit.h>

//包含图片库
#import <Photos/Photos.h>
@interface PhotoViewController : UIViewController

@property(nonatomic ,strong) PHAsset *photoAsset;

//定义一个block
typedef void(^SelectPhoto)(UIImage *photo);

@property(nonatomic ,copy) SelectPhoto photoBlock;
@end

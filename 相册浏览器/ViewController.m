//
//  ViewController.m
//  相册浏览器
//
//  Created by lxj on 16/5/25.
//  Copyright © 2016年 lxj. All rights reserved.
//

#import "ViewController.h"
#import "XJPhotoSearch.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)pushToAlbum:(UIButton *)sender {
    XJPhotoSearch *vc = [[XJPhotoSearch alloc] initWithBlock:^(UIImage *photo) {
        self.photoView.image = photo;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

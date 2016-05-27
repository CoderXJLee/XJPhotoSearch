//
//  PhotoViewController.m
//  相册浏览器
//
//  Created by lxj on 16/5/26.
//  Copyright © 2016年 lxj. All rights reserved.
//

#import "PhotoViewController.h"


@interface PhotoViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic ,strong) UIImage *photo;
@property(nonatomic ,strong) UIImageView *imageView;
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@property(nonatomic ,assign) float lastScale;
@property(nonatomic ,assign) float lastRotation;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - 64 ,ScreenWidth , ScreenHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tap];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestImageForAsset:_photoAsset targetSize:CGSizeMake(_photoAsset.pixelWidth,_photoAsset.pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.photo = result;
        imageView.image = result;
    }];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem = rightBtn;
  
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:pinchRecognizer];
}


-(void)rightClick{
    self.photoBlock(self.photo);
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)imageClick{
    if (self.navigationController.isNavigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
        self.imageView.frame = CGRectMake(0, - 64 ,ScreenWidth , ScreenHeight);
    }else{
        self.navigationController.navigationBarHidden = YES;
        self.imageView.frame = CGRectMake(0, 0 ,ScreenWidth , ScreenHeight);
    }
}
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"删除");
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *  action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"取消");
    }];
    NSArray *actions = @[action1,action2];
    return actions;
}



// 缩放
-(void)scale:(id)sender {
    //当手指离开屏幕时,将lastscale设置为1.0
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [[(UIPinchGestureRecognizer*)sender view]setTransform:newTransform];
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}


@end

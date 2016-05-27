//
//  ViewController.m
//  相册浏览器
//
//  Created by lxj on 16/5/25.
//  Copyright © 2016年 lxj. All rights reserved.
//


#import "XJPhotoSearch.h"
#import "CustomCell.h"
//包含图片库
#import <Photos/Photos.h>
#import "PhotoViewController.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface XJPhotoSearch ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>
//collectionview
@property(nonatomic,strong)UICollectionView *cv;

//相簿array
@property(nonatomic ,strong) NSMutableArray *albumArr;
//用来切换相簿
@property (strong, nonatomic) UIButton *albumBtn;
//确认被选中的相册
@property(nonatomic ,assign) int indexSelect;
//照片对象array
@property(nonatomic ,strong) NSMutableArray *photoArr;
//粗略照片array
@property(nonatomic ,strong) NSMutableArray *roughPhotoArr;
//原图照片array
@property(nonatomic ,strong) NSMutableArray *originalPhotoArr;
//tableview用换切换相簿
@property(nonatomic ,strong) UITableView *tableView;
//蒙板
@property(nonatomic ,strong) UIView *mbView;

//当前点击的cell
@property(nonatomic, strong) CustomCell *selectedCell;

@property(nonatomic ,copy) SelectPhoto photoBlock;

@end

@implementation XJPhotoSearch   

//懒加载
-(NSMutableArray *)albumArr{
    if (_albumArr == nil) {
        _albumArr = [NSMutableArray new];
    }
    return _albumArr;
}
//懒加载
-(NSMutableArray *)photoArr{
    if (_photoArr == nil) {
        _photoArr = [NSMutableArray new];
    }
    return _photoArr;
}

//懒加载
-(NSMutableArray *)roughPhotoArr{
    if (_roughPhotoArr == nil) {
        _roughPhotoArr = [NSMutableArray new];
    }
    return _roughPhotoArr;
}
//懒加载
-(NSMutableArray *)originalPhotoArr{
    if (_originalPhotoArr == nil) {
        _originalPhotoArr = [NSMutableArray new];
    }
    return _originalPhotoArr;
}

-(instancetype)initWithBlock:(SelectPhoto)block
{
    if (self = [super init]) {
        self.photoBlock = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.titleView = self.albumBtn;
    //创建顶部button
    [self createBtn];
    //创建collectview
    [self createCollectionView];
    //创建tableView
    [self createtableView];
    //默认第一个被选择
    self.indexSelect = 0;
    //获得所有相簿
    [self getAllCollection];
    //如果有相册的话，获取第一个相册里的图片
    if (self.albumArr) {
        [self getPhotoObject];
    }
    // 重要
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
    
}
///创建顶部button
-(void)createBtn{
    self.albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self.albumBtn addTarget:self action:@selector(albumClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.albumBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.albumBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.navigationItem.titleView = self.albumBtn;
}
///创建collectview
-(void)createCollectionView{
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ScreenWidth / 4, ScreenWidth / 4);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _cv=[[UICollectionView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight - 64) collectionViewLayout:layout];
    _cv.dataSource = self;
    _cv.delegate = self;
    _cv.contentSize = self.view.bounds.size;
    _cv.showsVerticalScrollIndicator = NO;
    [_cv registerClass:[CustomCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_cv];
}
///创建tableView
-(void)createtableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth/3, 0, ScreenWidth/3, 200) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    self.mbView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.mbView.backgroundColor = [UIColor colorWithRed:200.0/225 green:200.0/225 blue:200.0/225 alpha:0.5];
    self.mbView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mbClick)];
    self.mbView.userInteractionEnabled = YES;
    [self.mbView addGestureRecognizer:tap];
    
    [self.view addSubview:self.mbView];
    [self.view addSubview:self.tableView];
}

///获得所有相簿
-(void)getAllCollection{
    // 获得所有的自定义相簿
//    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 所有智能相册
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self.albumArr addObject:assetCollection];
    }
    //在这里给button赋值
    if (self.albumArr.count) {//如果存在相簿
        [self.albumBtn setTitle:[self.albumArr[0] localizedTitle] forState:UIControlStateNormal];
    }
}
///获得指定相簿里的照片对象
-(void)getPhotoObject{
    // 获得某个相簿中的所有PHAsset对象
    if (self.albumArr.count) {//如果存在相簿
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.albumArr[self.indexSelect] options:nil];
        //先清空
        [self.photoArr removeAllObjects];
        for (PHAsset *asset in assets) {
            [self.photoArr addObject:asset];
        }
        [self.cv reloadData];
    }
}
///点击切换相簿
- (void)albumClick:(UIButton *)sender {
    self.mbView.hidden = NO;
    self.tableView.hidden = NO;
}
///点击萌版
-(void)mbClick{
    self.mbView.hidden = YES;
    self.tableView.hidden = YES;
}

#pragma mark - uicollectionview datesource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.photoView.frame = cell.contentView.bounds;
  
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestImageForAsset:self.photoArr[indexPath.row] targetSize:CGSizeZero contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.photoView.image = result;
    }];
    
    return cell;
}
#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((ScreenWidth-3)/4 ,(ScreenWidth-3)/4);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0,0,0,0);
}

//定义每个UICollectionView 的纵向间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoViewController *pvc = [[PhotoViewController alloc] init];
    pvc.photoAsset = self.photoArr[indexPath.row];
    pvc.photoBlock = ^(UIImage *photo){
        self.photoBlock(photo);
    };
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"table"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"table"];
        cell.selectionStyle = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.textLabel.text =[self.albumArr[indexPath.row] localizedTitle];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //被选中行
    self.indexSelect = (int)indexPath.row;
    //重新获取相簿内图片
    [self getPhotoObject];
    //改变相簿名字
    if (self.albumArr.count) {//如果存在相簿
        [self.albumBtn setTitle:[self.albumArr[indexPath.row] localizedTitle] forState:UIControlStateNormal];
    }
    
    [self mbClick];
}
#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if (!self.mbView.hidden) {
        return nil;
    }
    
    self.selectedCell = [self searchCellWithPoint:location];
    previewingContext.sourceRect = self.selectedCell.frame;
    
    NSIndexPath *indexPath = [self.cv indexPathForCell:self.selectedCell];
    
    PhotoViewController *pvc = [[PhotoViewController alloc] init];
    pvc.photoAsset = self.photoArr[indexPath.row];
    return pvc;
}

///完全按压
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self collectionView:self.cv didSelectItemAtIndexPath:[self.cv indexPathForCell:self.selectedCell]];
}

// 根据一个点寻找对应cell并返回cell
- (CustomCell *)searchCellWithPoint:(CGPoint)point {
    CGPoint p = CGPointMake(point.x, point.y + self.cv.contentOffset.y);
    NSIndexPath *indexPath = [self.cv indexPathForItemAtPoint:p];
    CustomCell *cell = (CustomCell *)[self.cv cellForItemAtIndexPath:indexPath];
    return cell;
}
@end

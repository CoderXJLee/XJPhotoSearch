# XJPhotoSearch
#1.导入头文件
 import "XJPhotoSearch.h"
#2.创建并设置回调操作
  `XJPhotoSearch *vc = [[XJPhotoSearch alloc] initWithBlock:^(UIImage *photo) {       
      self.photoView.image = photo;
  }];`
#3.push新视图
  `[self.navigationController pushViewController:vc animated:YES];`

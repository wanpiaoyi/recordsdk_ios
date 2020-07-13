//
//  AssetForOneGroupViewController.m
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import "ALAsset+isEqual.h"
#import "AssetForOneGroupViewController.h"
#import "AssetForOneGroupViewControllerCell.h"
#import "AssetForOneGroupViewControllerCellFooter.h"
#import "AssetPickerController.h"
#import "ClipPubThings.h"

@interface AssetForOneGroupViewController ()

@end

@implementation AssetForOneGroupViewController

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] ==
        NSNotFound) {
        SaveSelectPicBlock block = _saveSelectPicBlock;
        if (block && _selectAssetsArray != nil && _selectAssetsArray.count != 0) {
            block(_selectAssetsArray);
        }
    }
    [super viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNavigation];
    [self initParameter];
    [self initUI];
    [self setupAssets];
    if(self.bottom != nil){
        self.bottom.constant = clipPubthings.deleteBottom;
    }
    self.selectSend.backgroundColor = clipPubthings.color;
    self.automaticallyAdjustsScrollViewInsets = NO;

}

- (void)initParameter {
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];

    if (_selectAssetsArray != nil && _selectAssetsArray.count == 0) {
        _selectAssetsArray = nil;
    }
}

- (void)setupAssets {
    // 供下面的回调使用
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset,
                                                          NSUInteger index,
                                                          BOOL *stop) {
      if (asset) {
          NSString *type = [asset valueForProperty:ALAssetPropertyType];
          if ([type isEqual:ALAssetTypeVideo]) {
              [self.assets addObject:asset];
          }
          if ([type isEqual:ALAssetTypePhoto]) {
              [self.assets addObject:asset];
          }
      } else if (self.assets.count > 0) {
          [self.collectRecommend reloadData];
          [self.collectRecommend
              scrollToItemAtIndexPath:
                  [NSIndexPath indexPathForRow:(self.assets.count - 1) inSection:0]
                     atScrollPosition:UICollectionViewScrollPositionTop
                             animated:YES];
      }
    };

    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (void)initUI {
    if (_selectAssetsArray == nil || _selectAssetsArray.count == 0) {
        [_preview setTitleColor:RGB(184, 184, 184) forState:UIControlStateNormal];
//        [_selectSend setTitleColor:RGB(193, 193, 193)
//                          forState:UIControlStateNormal];
        //    [_selectSend setBackgroundColor:RGB(230, 230, 230)];
        [_selectSend
            setTitle:[NSString stringWithFormat:@"确定 (0)"]
            forState:UIControlStateNormal];

    } else {
        [_preview setTitleColor:[UIColor colorWithRed:255.0 / 255 green:87.0 / 255 blue:18.0 / 255 alpha:1.0]
                       forState:UIControlStateNormal];
//        [_selectSend setTitleColor:[UIColor colorWithRed:255.0 / 255 green:87.0 / 255 blue:18.0 / 255 alpha:1.0]
//                          forState:UIControlStateNormal];
        [_selectSend
            setTitle:[NSString stringWithFormat:@"确定 (%d)",
                                                (int)_selectAssetsArray.count]
            forState:UIControlStateNormal];
    }
    //  _selectSend.layer.cornerRadius = 4;
    //  _selectSend.layer.masksToBounds = YES;

    if (_collectRecommend == nil) {
        // 用来填补空白
        UIView *blackView = [[UIView alloc] init];
        [blackView setFrame:CGRectMake(0, 0, 100, 100)];
        [blackView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:blackView];

        UICollectionViewFlowLayout *layout =
            [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        // footer
        layout.footerReferenceSize = CGSizeMake(kScreen_Width, 44);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置其边界
        int width = (clipPubthings.allWidth - 22 )/ 4;
        [layout setItemSize:CGSizeMake(width,width)]; //设置cell的尺寸
        _collectRecommend = [[UICollectionView alloc]
                   initWithFrame:CGRectMake(3, 64, kScreen_Width - 6,
                                            kScreen_Height - 64 - 50 - clipPubthings.deleteBottom)
            collectionViewLayout:layout];
        _collectRecommend.dataSource = self;
        
        _collectRecommend.delegate = self;
        _collectRecommend.scrollEnabled = YES;
        [_collectRecommend setShowsVerticalScrollIndicator:NO];
        [_collectRecommend setShowsHorizontalScrollIndicator:NO];
        [_collectRecommend registerNib:[UINib
                                           nibWithNibName:
                                               @"AssetForOneGroupViewControllerCell"
                                                   bundle:[clipPubthings clipBundle]]
            forCellWithReuseIdentifier:@"recommendCell"];
        [_collectRecommend setBackgroundColor:[UIColor whiteColor]];

        // footer
        [_collectRecommend registerNib:[UINib
                                           nibWithNibName:@"AssetForOneGroupViewControllerCellFooter"
                                                   bundle:[clipPubthings clipBundle]]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:@"footer"];
        [self.view addSubview:_collectRecommend];
    }
}

#pragma mark - 推荐版块 水平滚动 <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.assetsGroup != nil) {
        return self.assets.count;
    }
    return 0;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 0, 5, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)
                                                 collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)
                                            collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

////设置每个item的尺寸
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    int height = (clipPubthings.allWidth - 16 )/ 4;
//    return CGSizeMake(height, height);
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"recommendCell";
    AssetForOneGroupViewControllerCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                  forIndexPath:indexPath];
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    

    // 获取原图
    // 获取资源文件的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
//    ALAssetRepresentation *representation = [asset defaultRepresentation];
//    AVURLAsset * urlasset = [AVURLAsset assetWithURL:representation.url];
//    CMTime   time = [urlasset duration];
//    int seconds = ceil(time.value/time.timescale);
//
    NSString *type = [asset valueForProperty:ALAssetPropertyType];

    if ([type isEqual:ALAssetTypeVideo]) {
        NSString *nsALAssetPropertyDuration = [ asset valueForProperty:ALAssetPropertyDuration ] ;

        cell.lbl_time.text = [self timeToString:[nsALAssetPropertyDuration floatValue]];
        cell.lbl_time.hidden = NO;
    }
    if ([type isEqual:ALAssetTypePhoto]) {
        cell.lbl_time.hidden = YES;

    }
    // 获取资源文件的 fullScreenImage
    //  UIImage *contentImage = [UIImage imageWithCGImage:[representation
    //  fullScreenImage]];
    //  cell.image.image = contentImage;
    cell.image.image = [UIImage imageWithCGImage:asset.thumbnail];
    [cell.btn_smallClick setSelected:NO];
    for (ALAsset *test in _selectAssetsArray) {
        if ([test isEqual:asset]) {
            [cell.btn_smallClick setSelected:YES];
            continue;
        }
    }

    cell.index = indexPath;
    WS(weakSelf);
//    [cell setCellClickBlock:^(NSIndexPath *index) {
//      // 这里点击的是大图
//      ALAssetRepresentation *representation = [asset defaultRepresentation];
//      UIImage *contentImage =
//          [UIImage imageWithCGImage:[representation fullScreenImage]];
//    }];
    [cell setSmallClickBlock:^(NSIndexPath *index, BOOL isSelected) {
        // 这里点击的是小按钮，选中图标
        ALAsset *asset = [weakSelf.assets objectAtIndex:indexPath.row];
        if (weakSelf.selectAssetsArray == nil) {
            weakSelf.selectAssetsArray = [[NSMutableArray alloc] init];
        }
        NSInteger allselect = 9;
        AssetPickerController *picker =
        (AssetPickerController *)self.navigationController;
        if(picker.selectAllcount>0){
            allselect = picker.selectAllcount;
        }
        
        if (isSelected && weakSelf.selectAssetsArray.count >= allselect) {
            [pgToast setText:[NSString stringWithFormat:@"抱歉，您最多可以选择%ld个文件",allselect]];
            [[(AssetForOneGroupViewControllerCell *)[weakSelf.collectRecommend
                                                     cellForItemAtIndexPath:index] btn_smallClick] setSelected:NO];
            return;
        }
        NSString *type = [asset valueForProperty:ALAssetPropertyType];

        if(weakSelf.selectAssetsArray.count > 0){
            ALAsset *firstAsset = [weakSelf.selectAssetsArray firstObject];
            NSString *assetType = [firstAsset valueForProperty:ALAssetPropertyType];
            if (![type isEqualToString:assetType]) {
                [pgToast setText:[NSString stringWithFormat:@"不能同时选择视频和图片"]];
                [[(AssetForOneGroupViewControllerCell *)[weakSelf.collectRecommend
                                                         cellForItemAtIndexPath:index] btn_smallClick] setSelected:NO];
                return;
            }
        }
        
//        if ([type isEqual:ALAssetTypeVideo]) {
//            fileState = selectFromPhotoVideo;
//        }
//        if ([type isEqual:ALAssetTypePhoto]) {
//            fileState = selectFromPhotoImg;
//        }
            
        
        isSelected ? [weakSelf.selectAssetsArray addObject:asset]
        : [weakSelf.selectAssetsArray removeObject:asset];
        [weakSelf initUI];
    }];
    return cell;
}

//显示header和footer的回调方法
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionFooter) {
        AssetForOneGroupViewControllerCellFooter *footerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                               withReuseIdentifier:@"footer"
                                                      forIndexPath:indexPath];
        footerView.photoNumber.text =
            [NSString stringWithFormat:NSLocalizedString(@"共%ld个文件", nil),
                                       (long)self.assets.count];
        return footerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)initNavigation {
    self.title = self.name;
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(finishPickingAssets:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0],NSForegroundColorAttributeName,[UIFont systemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[clipPubthings imageNamed:@"nav_bar_back_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];

//    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0],NSForegroundColorAttributeName,[UIFont systemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];

}


-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)finishPickingAssets:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)preview:(UIButton *)sender {
    // 这里预览已经选择的文件
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (ALAsset *asset in _selectAssetsArray) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        UIImage *contentImage =
            [UIImage imageWithCGImage:[representation fullScreenImage]];
        [returnArray addObject:contentImage];
    }
    if (returnArray.count == 0) {
        returnArray = nil;
    }

}

- (IBAction)selectSend:(UIButton *)sender {

    // 这个发送已经选择的文件
    // 文件在数组 selectAssetsArray 里面
    // 获取原图
    // 获取资源文件的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
    //  ALAssetRepresentation *representation = [asset defaultRepresentation];
    // 获取资源文件的 fullScreenImage
    //  UIImage *contentImage = [UIImage imageWithCGImage:[representation
    //  fullScreenImage]];


    if(_selectAssetsArray == nil || _selectAssetsArray.count == 0){
        [pgToast setText:@"请选择一个文件"];
        return;
    }
    AssetPickerController *picker =
        (AssetPickerController *)self.navigationController;
    if (picker.picDelegate &&
        [picker.picDelegate
            respondsToSelector:@selector(returnSelectedPicFromLibrary:)]) {
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            for (ALAsset *asset in _selectAssetsArray) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                UIImage *contentImage =
                [UIImage imageWithCGImage:[representation fullScreenImage]];
                if(contentImage != nil){
                    [returnArray addObject:contentImage];
                }
            }
            if (returnArray.count == 0) {
                returnArray = nil;
            }
            [picker.picDelegate returnSelectedPicFromLibrary:returnArray];
    }
    if (picker.picDelegate &&
        [picker.picDelegate
            respondsToSelector:@selector(returnSelectedAssetFromLibrary:)]) {
        [picker.picDelegate returnSelectedAssetFromLibrary:_selectAssetsArray];
    }
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSString*)timeToString:(NSInteger)time{
    NSInteger second = time % 60;
    NSInteger min = time/60%60;
    NSInteger hour = time/3600;
    
    NSString *str_second = [NSString stringWithFormat:@"%ld",second];
    if(second<10){
        str_second = [NSString stringWithFormat:@"0%ld",second];
    }
    NSString *str_min = [NSString stringWithFormat:@"%ld",min];
    if(min<10){
        str_min = [NSString stringWithFormat:@"0%ld",min];
    }
    NSString *str_hour = [NSString stringWithFormat:@"%ld",hour];
    if(hour<10){
        str_hour = [NSString stringWithFormat:@"0%ld",hour];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_min,str_second];
}

@end

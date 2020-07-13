//
//  AssetForOneGroupViewController.h
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^SaveSelectPicBlock)(NSMutableArray *selectAssetsArray);

#define kScreen_Height ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width ([UIScreen mainScreen].bounds.size.width)
#define RGB(r, g, b)                                                           \
  [UIColor colorWithRed:((r) / 255.0)                                          \
                  green:((g) / 255.0)                                          \
                   blue:((b) / 255.0)                                          \
                  alpha:1.0]
#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;
@interface AssetForOneGroupViewController
    : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout>
// 其他页面传参
@property(nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic, strong) NSMutableArray *selectAssetsArray;
@property(strong, nonatomic) SaveSelectPicBlock saveSelectPicBlock;
@property(nonatomic, copy) NSString *name;

// 自己页面参数
@property(strong, nonatomic) UICollectionView *collectRecommend;
@property(nonatomic, strong) NSMutableArray *assets;

// Xib元素
@property(weak, nonatomic) IBOutlet UIButton *preview;
@property(weak, nonatomic) IBOutlet UIButton *selectSend;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

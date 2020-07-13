//
//  AssetGroupViewController.h
//  视频选择器的组列表，看到的是相机组
//
//  Created by Yangfan on 15/2/4.
//  Copyright (c) 2015年 4gread. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#define kScreen_Height ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width ([UIScreen mainScreen].bounds.size.width)

@interface AssetGroupViewController
    : UIViewController <UITableViewDelegate, UITableViewDataSource> {
}

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property(nonatomic, strong) NSMutableArray *groups;

@property(nonatomic, strong) NSMutableArray *selectAssetsArray;
@end

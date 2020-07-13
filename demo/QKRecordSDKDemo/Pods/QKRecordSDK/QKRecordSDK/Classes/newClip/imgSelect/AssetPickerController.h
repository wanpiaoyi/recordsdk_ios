//
//  AssetPickerController.h
//
//  自定义的视频选择器，继承UINavigationController
//
//  Created by Yangfan on 15/2/4.
//  Copyright (c) 2015年 4gread. All rights reserved.
//

/*
 使用方法
 _picker = [[AssetPickerController alloc] init];
 _picker.assetsFilter = [ALAssetsFilter allPhotos];
 _picker.showEmptyGroups = NO;
 _picker.vc = self;
 [self presentViewController:_picker animated:YES completion:NULL];
 */

#import "AssetGroupViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>


@protocol SelectPicFromLibraryDelegate;

@interface AssetPickerController : UINavigationController

@property (nonatomic, weak) id<SelectPicFromLibraryDelegate> picDelegate;

@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, copy) NSArray *indexPathsForSelectedItems;
@property (nonatomic, assign) BOOL showEmptyGroups;
@property (nonatomic, assign) BOOL showImages; //是否显示图片
@property (nonatomic, assign) BOOL showVideo; //是否显示视频
@property (nonatomic, strong) UIViewController *vc;
@property NSInteger selectAllcount;
@end

@protocol SelectPicFromLibraryDelegate <NSObject>
@optional
- (void)returnSelectedPicFromLibrary:(NSMutableArray *)picArray;
- (void)returnSelectedAssetFromLibrary:(NSMutableArray *)AssetArray;
// 使用说明
/*
 NSMutableArray *returnArray = [[NSMutableArray alloc] init];
 for (ALAsset *asset in _selectAssetsArray) {
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    UIImage *contentImage =
        [UIImage imageWithCGImage:[representation fullScreenImage]];
    [returnArray addObject:contentImage];
 }
 */
@end

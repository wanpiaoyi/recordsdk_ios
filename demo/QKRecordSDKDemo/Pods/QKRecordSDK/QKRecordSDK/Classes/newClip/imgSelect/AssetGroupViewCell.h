//
//  AssetGroupViewCell.h
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface AssetGroupViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupNumber;

@property(nonatomic, strong) ALAssetsGroup *assetsGroup;
- (void)bind:(ALAssetsGroup *)assetsGroup isVideo:(BOOL)isVideo;
@end

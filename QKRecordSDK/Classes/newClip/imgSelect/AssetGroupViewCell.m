//
//  AssetGroupViewCell.m
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import "AssetGroupViewCell.h"

@implementation AssetGroupViewCell

- (void)awakeFromNib {
  // Initialization code
}

- (void)bind:(ALAssetsGroup *)assetsGroup isVideo:(BOOL)isVideo{
  self.assetsGroup = assetsGroup;

  CGImageRef posterImage = assetsGroup.posterImage;
  _image.image = [UIImage imageWithCGImage:posterImage];

    if(isVideo){
        _groupName.text = @"视频";
    }else{
        _groupName.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
  
  _groupNumber.text =
      [NSString stringWithFormat:@"(%ld)", (long)[assetsGroup numberOfAssets]];
}

- (NSString *)accessibilityLabel {
  NSString *label =
      [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
  return
      [label stringByAppendingFormat:@"%ld 张视频",
                                     (long)[self.assetsGroup numberOfAssets]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end

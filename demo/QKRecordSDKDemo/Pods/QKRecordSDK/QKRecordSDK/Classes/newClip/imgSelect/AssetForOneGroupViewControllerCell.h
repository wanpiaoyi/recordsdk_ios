//
//  AssetForOneGroupViewControllerCell.h
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CellClickBlock)(NSIndexPath *index);
typedef void (^SmallClickBlock)(NSIndexPath *index, BOOL isSelected);

@interface AssetForOneGroupViewControllerCell : UICollectionViewCell

@property(strong, nonatomic) CellClickBlock cellClickBlock;
@property(strong, nonatomic) SmallClickBlock smallClickBlock;
@property(strong, nonatomic) NSIndexPath *index;

@property(weak, nonatomic) IBOutlet UIImageView *image;
@property(weak, nonatomic) IBOutlet UIButton *btn_cellClick;
@property(weak, nonatomic) IBOutlet UIButton *btn_smallClick;
@property(weak, nonatomic) IBOutlet UILabel *lbl_time;
@end

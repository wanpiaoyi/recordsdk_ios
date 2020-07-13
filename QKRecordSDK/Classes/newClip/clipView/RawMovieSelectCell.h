//
//  RawMovieSelectCell.h
//  QukanTool
//
//  Created by yang on 17/6/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RawMovieSelectCell : UICollectionViewCell

@property(strong,nonatomic) IBOutlet UIImageView *img_name;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
@property(strong,nonatomic) IBOutlet UILabel *lbl_border;
@property(strong,nonatomic) IBOutlet UILabel *lbl_showSelect;

@end

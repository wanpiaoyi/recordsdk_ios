//
//  MoviePartCell.h
//  QukanTool
//
//  Created by yang on 2017/12/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^choosePartTransfer)(NSInteger index);

@interface MoviePartCell : UICollectionViewCell
@property(strong,nonatomic) IBOutlet UIView *v_main;
@property(strong,nonatomic) IBOutlet UIImageView *img_name;

@property(strong,nonatomic) IBOutlet UIView *v_time;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
@property(strong,nonatomic) IBOutlet UILabel *lbl_border;
@property(strong,nonatomic) IBOutlet UILabel *lbl_showSelect;
@property(strong,nonatomic) IBOutlet UIButton *btn_zc;

@property(copy,nonatomic) choosePartTransfer choose;

@end

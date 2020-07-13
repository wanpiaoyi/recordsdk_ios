//
//  DraftsCell.h
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKMoviePartDrafts.h"
typedef void (^deleteDrafts)(QKMoviePartDrafts *drafts);
@interface DraftsCell : UITableViewCell

@property(strong,nonatomic) IBOutlet UILabel *lbl_broken;
@property(strong,nonatomic) IBOutlet UIView *edict;
@property(strong,nonatomic) IBOutlet UIImageView *img_background;

@property(strong,nonatomic) IBOutlet UILabel *lbl_name;
@property(strong,nonatomic) IBOutlet UILabel *lbl_createTime;
@property(strong,nonatomic) IBOutlet UILabel *lbl_during;

@property(strong,nonatomic) IBOutlet UIButton *btn_delete;

@property(strong,nonatomic) QKMoviePartDrafts *drafts;
@property(copy,nonatomic) deleteDrafts deleteDra;

-(void)checkBroken;

@end

//
//  SelectVideoCell.h
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^openEdictView)(NSInteger tag);

@interface SelectVideoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *show_button;
@property (nonatomic, strong) IBOutlet UILabel *time_label;
@property (strong, nonatomic) IBOutlet UILabel *size_label;
@property (nonatomic, assign) NSObject *delegate;
@property (nonatomic, strong) IBOutlet UIImageView *img_pic;
@property (nonatomic, strong) IBOutlet UIImageView *headerImage;
@property (nonatomic, strong) IBOutlet UILabel *startTime;
@property (nonatomic, strong) IBOutlet UIView *v_time;
@property (nonatomic, strong) IBOutlet UIView *v_size;

@property (strong, nonatomic) IBOutlet UILabel *lbl_upload;


@property (nonatomic, copy) openEdictView open;

@end

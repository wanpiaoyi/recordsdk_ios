//
//  PGToastView.h
//  qukan4
//
//  Created by chenyu on 14/12/22.
//  Copyright (c) 2014年 ReNew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGToastView : UIView

@property(strong,nonatomic) UILabel *lbl_toast;
@property(strong,nonatomic) UILabel *lbl_hentoast;

@property(strong,nonatomic) UIView *v_finish;
@property(strong,nonatomic) UILabel *lbl_finishToast;

@property (nonatomic, strong) NSTimer* logoTimer;
@property float hidtimer;

@property BOOL istrans;     //是否横屏

+(PGToastView *)getPgtoast;
-(void)setText:(NSString *)str;
-(void)setHenText:(NSString *)str;
-(void)setFinishText:(NSString *)str;


@end

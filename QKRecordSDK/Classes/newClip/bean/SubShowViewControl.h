//
//  SubShowViewControl.h
//  QukanTool
//
//  Created by yang on 17/6/18.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubTitleShowview.h"
#import "QKTextChangeBean.h"

#define titleImgMaxwidth 96.0
#define titleImgMaxheight 54.0
#define showSubTitleWidth 375.0
#define showSubTitleHeight 210.0
#import "BaseAnimation.h"
#import "MovieView.h"


typedef void (^subcontrolChange)(NSInteger deleteOradd);
typedef void (^changeEndTime)(id change);

@interface SubShowViewControl : NSObject
@property(strong,nonatomic) NSMutableArray *array_showviews;
@property(strong,nonatomic) BaseAnimation *animation;
@property CGPoint pointCreen; //横屏时候
@property CGPoint pointVer; //竖屏时候
@property BOOL isTitle; //是否是片头
@property double endTime;
@property double startTime;


//正式画面展示
@property CGRect rect_showView;
@property(strong,nonatomic) MovieView *v_AllShowview;
@property(strong,nonatomic) UIView *v_showview;
@property(strong,nonatomic) UIButton *btn_close;
@property(copy,nonatomic) subcontrolChange subChange;
@property(copy,nonatomic) changeEndTime changeEnd;


+(SubShowViewControl*)getSubShowViewControl:(NSDictionary*)dict;
+(SubShowViewControl*)copySubControl:(SubShowViewControl*)subcontrol;

+(SubShowViewControl*)createTitleShowView:(NSString*)imgName;
//片尾
+(SubShowViewControl*)createPwShow:(NSDictionary*)dict_pw;

//获取展示的页面
-(UIView*)getShowView:(CGSize)superSize;


-(void)showOrHidShowView:(BOOL)isHidden isPause:(BOOL)isPause animationTime:(double)animationTime;
-(NSString*)getAnimationTime:(double)animationTime;

//获取截图以及位置
-(UIImage*)getViewToImage:(float)scale animationTime:(double)animationTime;
-(CGRect)getViewImageRect:(double)animationTime;


-(NSDictionary*)getDictionaryByBean;
+(SubShowViewControl *)getSubControlByBean:(NSDictionary *)dict;

@end

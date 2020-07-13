//
//  QKShowMovieSuntitle.h
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubtitlePreview.h"
#import "SubTitleShowview.h"
#import "SubShowViewControl.h"

@interface QKShowMovieSuntitle : NSObject
@property long subTitleId;
@property (strong,nonatomic) UIImageView *img_insert;

@property (strong,nonatomic) NSNumber* moviePartId;
@property (nonatomic) double speed;
@property (nonatomic) double startTime;
@property (nonatomic) double endTime;

@property double softStartTime;
@property NSInteger isTitle; //是否是片头 片头 1，片尾：2
@property (strong,nonatomic) SubShowViewControl* subControl;



//预览画面展示
@property(strong,nonatomic) UIView *v_AllPreview;
@property(strong,nonatomic) NSMutableArray *array_previews;

-(void)checkShowTime:(double)nowTime isPause:(BOOL)isPause;

+(QKShowMovieSuntitle*)getShowMovieSuntitle:(NSDictionary*)dict;
+(QKShowMovieSuntitle*)copySubtitle:(QKShowMovieSuntitle*)qk;

-(UIView*)getShowView:(CGSize)superSize;

//获取截图
-(UIImage*)getViewToImage:(float)scale nowTime:(double)time;
-(UIView*)getPreView;


+(CGRect)getCreenScreenRect:(CGRect)subViewRect scale:(double)scale;
+(CGRect)getNotCreenScreenRect:(CGRect)subViewRect;


//把对象转成dictionary，保存到数据库中
-(NSDictionary*)getDictionaryByBean;
+(QKShowMovieSuntitle*)getShowMovieSub:(NSDictionary*)dict;

-(UIImageView *)getImg;

@end

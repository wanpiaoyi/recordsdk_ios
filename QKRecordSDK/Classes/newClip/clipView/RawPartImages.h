//
//  RawPartImages.h
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QKLiveAndRecord/QKMovieClipController.h>

typedef void (^SelectTime)(double selectTime,BOOL isEnd);
//用于显示从视频中获取出来的视频截图

@interface RawPartImages : UIView
@property(copy,nonatomic) SelectTime selTime;                   //返回选择的时间
@property BOOL canChangeStartTime;
@property double minTime;

-(void)getImageFromAvAsset:(QKMovieClipController *)movieClip startTime:(double)startTime endTime:(double)endTime;

-(void)setNowPlayTime:(double)playtime;
//外部来修改这里面裁剪的开始时间
-(BOOL)changeStartTime:(double)timeChange;
//外部来修改这里面裁剪的结束时间
-(BOOL)changeEndTime:(double)timeChange;
//隐藏当前白色进度条
-(void)hidNowTime;

-(double)getClipStartTime;
-(double)getClipEndTime;
-(double)getPlayStartTime;
-(double)getPlayEndTime;


-(void)clearGetImages;
+(NSInteger)getAllImageWidth;
//计算个数
+(NSInteger)getImageCounts;
+(NSInteger)getMarginLeft;
-(void)changeSpeed:(double)speed;

@end

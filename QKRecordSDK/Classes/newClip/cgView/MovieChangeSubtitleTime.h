//
//  MovieChangeSubtitleTime.h
//  QukanTool
//
//  Created by yang on 2018/1/2.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviesPartImgs.h"
@class AudioRecorderView;
#define imgHeight  50

@interface MovieChangeSubtitleTime : UIView
@property(copy,nonatomic) ChangeNowTime changeTime;

-(instancetype)initWithFrame:(CGRect)frame;
-(void)changeMovies:(NSArray*)arrayMovies;

-(void)setStartTime:(double )startTime during:(double)endTime;

-(void)setEndTime:(double)endTime;//设置字幕结束时间
-(double)getEndTime;

-(void)setText:(NSString*)text;
//-(double)getStartTime;

//-(double)getDuringTime;
//-(double)getAllTime;
@end

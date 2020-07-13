//
//  MoviesPartImgs.h
//  QukanTool
//
//  Created by yang on 2017/12/18.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define audioRecorderView_imgHeight  46
#define audioRecorderView_frameHeight  50
@class AudioRecordedView;

typedef void (^ChangeNowTime)(double time);
typedef void (^SelectRecordViewCallBack)(AudioRecordedView *view);


@interface MoviesPartImgs : UIView

@property(copy,nonatomic) ChangeNowTime changeTime;
@property(copy,nonatomic) SelectRecordViewCallBack selectRecordViewCall;//选中了一个录音的片段

-(instancetype)initWithFrame:(CGRect)frame backGroundImage:(UIImage*)img;
-(void)changeMovies:(NSArray*)arrayMovies;
-(void)changeRecordedView:(NSArray*)arrayMovies;

-(void)setRecordStartTime:(double )startTime;
-(void)endRecord;
-(void)setNowPlayTime:(double)playtime;//设置当前播放时间

-(double)getNowTime;

-(int)getOrgLeft:(double)time;

@end

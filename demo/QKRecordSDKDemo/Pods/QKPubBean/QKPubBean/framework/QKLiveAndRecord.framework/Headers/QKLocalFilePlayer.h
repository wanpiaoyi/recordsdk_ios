//
//  QKLocalFilePlayer.h
//  IJKMediaPlayer
//
//  Created by yang on 17/3/27.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QKLocalFilePlayer : NSObject
-(id)init:(CGRect)frame;
@property(weak,nonatomic) UIView *view;
-(void)setLocalFiles:(NSArray *)array;//设置播放的视频
-(void)setChangeMovieTransfer:(NSArray *)array;//修改视频的转场效果
-(void)changeSpeed:(double)speed;
//0 不旋转 1 90，2 180，3 270
-(void)changeUseOrientation:(int) useOrientation;

-(void)startPlayer;  //开始
//从指定时间开始
-(void)startPlayerWithTime:(double)time;
-(void)pause:(bool)isPause; //暂停
-(bool)getPauseState;//获取当前暂停状态
-(void)stopPlayer; //停止
- (void)seekToTime:(double)startTime; //调整时间
- (void)seekToTimeSync:(double)startTime; //调整时间
-(float)getCurrentTime; //获取播放时间
-(BOOL)isPlayerEnd; //获取播放器是否播放到末尾的状态

//修改原始声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setOrgSoundValue:(float)value;
//修改背景声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setBackSoundValue:(float)value;
//修改配音声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setRecordValue:(float)value;
//设置背景音地址
-(void)setBackgroundAudio:(NSString*)path;
//关闭背景音
-(void)closeBackgroundAudio;
//设置配音地址
-(void)setRecordAudio:(NSString*)path;
//取消配音地址
-(void)closeRecordAudio;
//获取视频当前截图
- (UIImage *)thumbnailImageAtCurrentTime;


-(void)changeFilter:(int)filterType;

-(void)changeBrightness:(CGFloat)brightness; //亮度-1~1 0是正常色
-(void)changeContrast:(CGFloat)contrast;    //对比度 0.0 to 4.0 1.0是正常色
-(void)changeSaturation:(CGFloat)saturation;    //饱和度  0.0  to 2.0 1是正常色
-(void)changeSharpness:(CGFloat)sharpness;    //锐度 -4.0 to 4.0, with 0.0 是正常色
-(void)changeExposure:(CGFloat)exposure;    //曝光 -10.0 to 10.0, with 0.0 是正常色
-(void)changeHue:(CGFloat)hue;    //设置色调 0 ~ 360 0.0 是正常色


@end

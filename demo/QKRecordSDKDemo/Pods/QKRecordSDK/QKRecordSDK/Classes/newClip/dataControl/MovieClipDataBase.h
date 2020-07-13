//
//  MovieClipDataBase.h
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKColorFilterGroup.h"
#import "RecordInfoController.h"


#define movieEidctHeight 292
#define clipData ((MovieClipDataBase*)[MovieClipDataBase sharePubThings])

typedef enum DrawType {
//    DrawTypeNone = 0,
    DrawType16x9 = 0,
    DrawType4x3 = 1,
    DrawType1x1 = 2,
    DrawType3x4 = 3,
    DrawType9x16 = 4,
    
} DrawType;


@class QKMoviePart,MovieTransfer;

@interface MovieClipDataBase : NSObject

@property BOOL isPreView; //预览还是单个视频选择
@property double allLength; //当前播放的视频的总长度
@property(strong,nonatomic) RecordInfoController *recordInfo;//音乐数据管理类
@property(strong,nonatomic) QKColorFilterGroup *group;



+(MovieClipDataBase *)sharePubThings;
-(void)resetThings:(BOOL)deleteNowPath;

-(void)changeAllTransfer:(MovieTransfer *)transfer;
-(void)changeTransfers;
//获取视频列表文件
-(NSMutableArray*)getMovies;
-(void)changeArrayMovies:(NSMutableArray*)array;
/*
 **添加一个视频
 */
-(void)addOnePart:(QKMoviePart*)part;
/*
 添加片头
 */
-(void)addCover:(QKMoviePart *)part;
/*
 **分割一个视频
 */
-(QKMoviePart*)setCutPart:(QKMoviePart*)part softTime:(double)softTime;
/*
 **删除一个视频
 */
-(void)removeNowPart;
-(void)createAllPlayer;
-(void)showOnePart:(QKMoviePart *)moviePart;

//获取播放器的界面 superFrame:播放器将要放入的界面的frame
-(UIView*)getPlayerView:(CGSize)superBoundSize drawType:(DrawType)type;

-(CGRect)getPlayerViewFrame;
-(CGRect)changeDrawType:(CGSize)superBoundSize drawType:(DrawType)type;


//播放器的操作
//开始播放
-(void)playIosPlayer;
//暂停
-(void)pauseIosPlayer;
-(double)getCurrentTime;
-(BOOL)isPlayerEnd;
//从指定时间开始
-(void)startPlayerWithTime:(double)time;
-(bool)getPauseState;//获取当前暂停状态
- (void)seekToTime:(double)time; //调整时间
- (void)seekToTimeSync:(double)time; //调整时间
-(void)pause:(bool)isPause;


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

-(void)changeColorFilterGroup:(QKColorFilterGroup *)group;
-(void)changeBrightness:(CGFloat)brightness; //亮度-1~1 0是正常色
-(void)changeContrast:(CGFloat)contrast;    //对比度 0.0 to 4.0 1.0是正常色
-(void)changeSaturation:(CGFloat)saturation;    //饱和度  0.0  to 2.0 1是正常色
-(void)changeSharpness:(CGFloat)sharpness;    //锐度 -4.0 to 4.0, with 0.0 是正常色
-(void)changeExposure:(CGFloat)exposure;    //曝光 -10.0 to 10.0, with 0.0 是正常色
-(void)changeHue:(CGFloat)hue;    //设置色调 0 ~ 360 0.0 是正常色




-(void)changeFilter:(int) type;
-(void)changeSpeed:(double)speed;
//0 不旋转 1 90，2 180，3 270
-(void)changeUseOrientation:(int)useOrientation;
-(void)stopPlayer;

@end

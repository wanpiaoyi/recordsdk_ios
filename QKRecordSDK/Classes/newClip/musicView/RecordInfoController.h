//
//  RecordInfoController.h
//  QukanTool
//
//  Created by yang on 2017/12/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKAudioBean.h"

typedef NS_ENUM(NSUInteger, RecordCall){
    RecordCallRecording = 1,  //正在录音时间
    RecordCallRecordEnd = 2  //录音停止
    
};

typedef void (^recordRecordStateCall)(RecordCall state,double time);

@class QKMoviePart;
@interface RecordInfoController : NSObject

@property BOOL audioStartRecord;
/*录像文件保存的地址
 recordCall:录音超过总时长的时候，会自动结束
 */
@property (copy,nonatomic) recordRecordStateCall recordCall;

-(id)init:(NSArray*)arrayMovies path:(NSString*)audioPath  isOld:(BOOL)isOld;
/*
 当视频片段发生改变，不管是增加了还是裁剪还是删除了，请调用这个方法
 */
-(void)changeMovies:(NSArray*)arrayMovies;
/*
 当视频新增一个分割的片段调用该方法
 */
-(void)changeCutPart:(NSNumber *)oldPartId newPart:(QKMoviePart *)newPart  movies:(NSArray *)arrayMovies;


//设置保存背景音地址
-(void)setMusicPath:(NSString*)musicPath;
//获取背景音地址
-(NSString*)getMusicPath;

//获取所有的视频，这里的视频地址包含了音频片段与视频绑定的信息。
-(NSArray*)getArray_movies;
//获取配音地址
-(NSString*)getRecordPath;
//获取音乐有关的所有对象
-(QKAudioBean*)getAudioBean;
//保存原始声音音量
-(void)setOrgValue:(double)value;
//保存背景声音音量
-(void)setBackValue:(double)value;
//保存配音声音音量
-(void)setRecordValue:(double)value;

//清空所有配音
-(void)clearAllAudios;


-(BOOL)canStartRecord;
-(void)startRecord:(double)startTime;
-(void)startBegin;
-(void)pauseRecord;
-(void)endRecord;


//把pcm写入文件中
-(int)writePcm:(char*)pcm length:(int)length;
//计算音频的时间
-(void)setAudioRecordTime:(double)startTime  endTime:(double)endTime;
-(void)removeFile:(double)startTime endTime:(double)endTime;
//删除一个片段
-(void)removePart:(double)startTime endTime:(double)endTime;

//获取录音结束的时间
-(double)getEndTime;
//获取全部时间
-(double)getAllMovieTime;

-(void)changeRecordPath:(NSString*)recordPath;
-(void)deleteFile;
-(void)deleteOldFile;
+(RecordInfoController*)copyInfo:(RecordInfoController*)old;
@end

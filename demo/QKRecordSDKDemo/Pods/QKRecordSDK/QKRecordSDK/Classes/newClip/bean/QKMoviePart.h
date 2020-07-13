//
//  QKMoviePart.h
//  QukanTool
//
//  Created by yang on 17/6/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordData.h"
#import "PartAudioRecord.h"
#import "MovieTransfer.h"
#define lineCounts 17

@interface QKMoviePart : NSObject
@property (strong,nonatomic) NSNumber* moviePartId;

@property double movieStartTime;
@property double movieEndTime;
@property double allDuring; //视频总时长

@property double beginTime;//在总视频的时间轴重的开始时间
@property BOOL isClip;
@property BOOL isTitle;
@property BOOL isImage;

@property int speedType;
@property int filterType;//0 原始  1怀旧 2、素描 3清新 4恋橙 5稚颜 6青柠 7film 8微风 9萤火虫
@property int orientation;

@property(strong,nonatomic) MovieTransfer *transfer; //转场动画：0 没有动画  1:左侧划入 2右侧划入 3:淡出 4:闪白 5闪黑
@property float width;
@property float height;
@property (strong,nonatomic) RecordData *data;
@property(copy,nonatomic) NSString *fileAddress;

@property(strong,nonatomic) NSMutableArray *audioArray; //音频的时间轴

@property BOOL deleteEndEdict; //短视频编辑后就删除

+(QKMoviePart*)startWithRecord:(RecordData*)data;
+(QKMoviePart*)copyMoviePart:(QKMoviePart*)data;

-(NSString*)getOrgPath;
-(NSString*)filePath;
-(NSDictionary*)getDictionaryByBean;
+(QKMoviePart*)getMoviePartByBean:(NSDictionary*)dict;

//添加一个新的录音文件时间
-(void)setNewRecordPart:(double)partStartTime endTime:(double)partEndTime;

-(void)saveImage;
-(NSString*)getImagePath;
-(void)removeTemp;
-(double)speed;

-(double)movieDuringTime;
+(NSNumber*)getNewMoviePartId;
@end


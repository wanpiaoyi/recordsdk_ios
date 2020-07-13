//
//  MovieClipDataBase.m
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "MovieClipDataBase.h"
#import <QKLiveAndRecord/QKLocalFilePlayer.h>
#import <QKLiveAndRecord/QKPlayerFileInfo.h>
#import "ClipReckon.h"
#import "QKMoviePart.h"
#import "RecordInfoController.h"
#import "ClipPubThings.h"

@interface MovieClipDataBase()

@property(strong,nonatomic) UIView *playView;
@property(strong,nonatomic) QKLocalFilePlayer *iosplay;
//裁剪的视频文件组
@property(strong,nonatomic) NSMutableArray *array_movies;
@property(nonatomic) DrawType drawType;
@property(nonatomic) CGSize superBoundSize;

@property(strong,nonatomic) QKMoviePart *nowMoviePart;

@property (strong,nonatomic) NSMutableDictionary *usePath;


@property (strong,nonatomic) NSMutableDictionary *insertPath;


@end


@implementation MovieClipDataBase

+(MovieClipDataBase *)sharePubThings{
    static dispatch_once_t once;
    static MovieClipDataBase *sharedView;
    dispatch_once(&once, ^ {
        
        sharedView = [[MovieClipDataBase alloc] init];
        
    });
    return sharedView;
}

-(id)init{
    self = [super init];
    if(self){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict = [userDefaults objectForKey:@"insertPathNeedDeletpath"];
        if(dict != nil){
            NSFileManager *defauleManager = [NSFileManager defaultManager];
            
            NSArray *allKeys = [dict allKeys];
            for(NSString *key in allKeys){
                NSString *value = dict[key];
                   BOOL remove = [defauleManager removeItemAtPath:[NSString stringWithFormat:@"%@%@",clipPubthings.pressfixPath,value] error:nil];
//                    NSLog(@"remove:%d removeFile:%@",remove,[NSString stringWithFormat:@"%@%@",clipPubthings.pressfixPath,value]);
            }
            [userDefaults removeObjectForKey:@"insertPathNeedDeletpath"];
            [userDefaults synchronize];
        }
        
        self.usePath = [[NSMutableDictionary alloc] init];
        self.insertPath = [[NSMutableDictionary alloc] init];
        [self resetThings:NO];
    }
    return self;
}


-(NSMutableArray*)getMovies{
    return _array_movies;
}
-(void)changeArrayMovies:(NSMutableArray*)nowArray{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(nowArray.count > 0){
        for(id data in nowArray){
            if([data isKindOfClass:[RecordData class]]){
                QKMoviePart *part = [QKMoviePart startWithRecord:data];
                NSInteger count = 1;
                if(!part.deleteEndEdict){
                    count = 9999;
                }
                
                [self addPath:part.filePath count:count];

                [array addObject:part];
            }else{
                QKMoviePart *part = [QKMoviePart copyMoviePart:data];
                NSInteger count = 1;
                if(!part.deleteEndEdict){
                    count = 9999;
                }
                [self addPath:part.filePath count:count];
                part.audioArray = nil;
                [array addObject:part];
            }
            
        }
    }
    _array_movies = array;
}

#pragma mark -改变转场效果
-(void)changeAllTransfer:(MovieTransfer *)transfer{
    int count = 0;
    for(QKMoviePart *part in self.array_movies){
        if(count == 0){
            part.transfer = [MovieTransfer getDefaultTransfer];
        }else{
            part.transfer = transfer;
        }
        count++;
    }
    [self changeTransfers];
}
-(void)changeTransfers{
    if(self.iosplay != nil&&self.isPreView){
        NSArray *array = self.array_movies;
        NSMutableArray *array_playInfos = [[NSMutableArray alloc] init];
        double startTime = 0;
        for(int i =0;i<array.count;i++){
            QKMoviePart *moviePart = array[i];
            QKPlayerFileInfo *qk = [[QKPlayerFileInfo alloc] init];
         
            qk.softStartTime = moviePart.movieStartTime;
            qk.softEndTime = moviePart.movieEndTime;

            qk.startTime = startTime;
            qk.endTime = startTime + qk.softEndTime - qk.softStartTime;
            startTime = qk.endTime;
            const char *part = (char*)[moviePart.filePath UTF8String];
            qk.length = strlen(part);
            qk.pcFilePath = part;
            qk.strFilePath = moviePart.filePath;
            qk.type = moviePart.transfer.type;
            [array_playInfos addObject:qk];
        }
        [self.iosplay setChangeMovieTransfer:array_playInfos];
    }
}

#pragma mark - 获取视频界面并展示
//获取视频界面
-(UIView*)getPlayerView:(CGSize)superBoundSize drawType:(DrawType)type{
    if(CGSizeEqualToSize(superBoundSize, self.superBoundSize)&&self.drawType == type&&self.playView){
        return self.playView;
    }
    _superBoundSize = superBoundSize;
    _drawType = type;
    CGRect rect = [ClipReckon reckonRect:superBoundSize drawType:type];
    self.playView.frame = rect;
    if(self.iosplay != nil){
        self.iosplay.view.frame = self.playView.bounds;
    }
    return self.playView;
}

-(CGRect)changeDrawType:(CGSize)superBoundSize drawType:(DrawType)type{
    if(CGSizeEqualToSize(superBoundSize, self.superBoundSize)&&self.drawType == type&&self.playView){
        return self.playView.frame;
    }
    _superBoundSize = superBoundSize;
    _drawType = type;
    CGRect rect = [ClipReckon reckonRect:superBoundSize drawType:type];
    self.playView.frame = rect;
    if(self.iosplay != nil){
        self.iosplay.view.frame = self.playView.bounds;
    }
    return rect;
}

-(CGRect)getPlayerViewFrame{
    if(self.playView == nil || self.playView.frame.size.width == 0 || self.playView.frame.size.height == 0){
        return CGRectMake(0, 0, 200, 200);
    }
    return self.playView.frame;
}
-(void)addOnePart:(QKMoviePart *)part{
    NSInteger count = 1;
    if(!part.deleteEndEdict){
        count = 9999;
    }
    [self addPath:part.filePath count:count];
    [self.array_movies addObject:part];
}


/*
 添加片头
 */
-(void)addCover:(QKMoviePart *)part{
    NSInteger count = 1;
      if(!part.deleteEndEdict){
          count = 9999;
      }
    [self addPath:part.filePath count:count];
    [self.array_movies insertObject:part atIndex:0];
}

/*
 **分割一个视频
 */
-(QKMoviePart*)setCutPart:(QKMoviePart*)part softTime:(double)softTime{
    QKMoviePart *partCut = [QKMoviePart copyMoviePart:part];
    partCut.moviePartId = [QKMoviePart getNewMoviePartId];
    partCut.movieStartTime = softTime;
    
    part.movieEndTime = softTime;
    
    for(int i = 0;i < self.array_movies.count;i++){
        QKMoviePart *nowPart = self.array_movies[i];
        if(nowPart == part){
            [self.array_movies insertObject:partCut atIndex:i+1];
            break;
        }
    }
    return partCut;
}

-(void)removeNowPart{
    if(!self.nowMoviePart){
        return;
    }
    [self removeOnePart:self.nowMoviePart];
    self.nowMoviePart = nil;
}

-(void)removeOnePart:(QKMoviePart *)part{
    [self removePath:part.filePath];
    [self.array_movies removeObject:part];
}

-(void)createAllPlayer{
    self.isPreView = YES;
    [self createPlayer:_array_movies type:1];
    self.nowMoviePart = nil;
    [self addAllAudio];
}


-(void)showOnePart:(QKMoviePart *)moviePart{
    NSArray *array = [NSArray arrayWithObjects:moviePart, nil];
    self.isPreView = NO;
    self.nowMoviePart = moviePart;
    [self createPlayer:array type:0];
}

//type: 0 显示单个完整的视频,1 显示裁剪后的视频
-(void)createPlayer:(NSArray*)array type:(NSInteger)type{
    [self stopPlayer];
    double seekToTime = 0;
    NSMutableArray *array_playInfos = [[NSMutableArray alloc] init];
    double startTime = 0;
    for(int i =0;i<array.count;i++){
        QKMoviePart *moviePart = array[i];
        QKPlayerFileInfo *qk = [[QKPlayerFileInfo alloc] init];
        if(type == 0 && array.count == 1){
            qk.softStartTime = 0;
            qk.softEndTime = moviePart.allDuring;
            seekToTime = moviePart.movieStartTime;
        }else{
            qk.softStartTime = moviePart.movieStartTime;
            qk.softEndTime = moviePart.movieEndTime;
        }
        qk.speed = moviePart.speed;
        qk.filterType = moviePart.filterType;
        qk.useOrientation = moviePart.orientation;

        qk.startTime = startTime;
        qk.endTime = startTime + (qk.softEndTime - qk.softStartTime)/moviePart.speed;
        startTime = qk.endTime;
        const char *part = (char*)[moviePart.filePath UTF8String];
        qk.length = strlen(part);
        qk.pcFilePath = part;
        qk.strFilePath = moviePart.filePath;
        qk.type = moviePart.transfer.type;
        qk.isImage = moviePart.isImage;
        qk.width = moviePart.width;
        qk.height = moviePart.height;
        [array_playInfos addObject:qk];
    }
    double scale = 1;
    QKMoviePart *moviePart = array[0];
    
    if(moviePart.isImage){
        scale = moviePart.width/moviePart.height;
    }else{
        scale = [moviePart.data getMovieScale];
    }
    
    self.iosplay = [[QKLocalFilePlayer alloc] init:self.playView.bounds];
    [self.playView insertSubview:self.iosplay.view atIndex:0];
    
    [self.iosplay setLocalFiles:array_playInfos];
    [self.iosplay startPlayerWithTime:seekToTime];
    self.allLength = startTime;
    [self addGroupInfo];
}

//结束并释放播放器
-(void)stopPlayer{
    if(self.iosplay != nil){
        QKLocalFilePlayer *iosplay = self.iosplay;
        [self.iosplay.view removeFromSuperview];
        self.iosplay = nil;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [iosplay stopPlayer];
        });

    }
}

#pragma mark - 音频
//添加音频
-(void)addAllAudio{
    if(self.recordInfo != nil){
        //设置背景音乐等
        QKAudioBean *audio = [self.recordInfo getAudioBean];
        [self.iosplay setOrgSoundValue:audio.orgVale];
        [self.iosplay setBackSoundValue:audio.backVale];
        [self.iosplay setRecordValue:audio.recordVale];
        
        [self.iosplay setBackgroundAudio:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,audio.backMusic]];
        [self.iosplay setRecordAudio:audio.recordPath];
    }
}

#pragma mark - 播放器的操作
-(void)pauseIosPlayer{
    [self.iosplay pause:YES];
}
//开始播放
-(void)playIosPlayer{
    BOOL pauseState = [self getPauseState];
    if(pauseState){
        [self.iosplay pause:NO];
    }
}
-(double)getCurrentTime{
    return [self.iosplay getCurrentTime];
}
-(BOOL)isPlayerEnd{
    return self.iosplay.isPlayerEnd;
}
//从指定时间开始
-(void)startPlayerWithTime:(double)time{
    [self.iosplay startPlayerWithTime:time];
}
//获取当前暂停状态
-(bool)getPauseState{
    return [self.iosplay getPauseState];
}
//调整时间
- (void)seekToTime:(double)time{
    [self.iosplay seekToTime:time];
}
- (void)seekToTimeSync:(double)time{
    [self.iosplay seekToTimeSync:time];
}
-(void)pause:(bool)isPause{
    [self.iosplay pause:isPause];
}

//修改原始声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setOrgSoundValue:(float)value{
    [self.iosplay setOrgSoundValue:value];
}
//修改背景声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setBackSoundValue:(float)value{
    [self.iosplay setBackSoundValue:value];
}
//修改配音声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setRecordValue:(float)value{
    [self.iosplay setRecordValue:value];
}
//设置背景音地址
-(void)setBackgroundAudio:(NSString*)path{
    [self.iosplay setBackgroundAudio:path];
}
//关闭背景音
-(void)closeBackgroundAudio{
    [self.iosplay closeBackgroundAudio];
}
//设置配音地址
-(void)setRecordAudio:(NSString*)path{
    [self.iosplay setRecordAudio:path];
}
//取消配音地址
-(void)closeRecordAudio{
    [self.iosplay closeRecordAudio];
}


-(void)changeFilter:(int) type{
    if(type < 0){
        return;
    }
    if(self.nowMoviePart != nil){
        self.nowMoviePart.filterType = type;
    }
    if(!self.isPreView){
        [self.iosplay changeFilter:type];
    }
}
-(void)changeSpeed:(double)speed{
    [self.iosplay changeSpeed:speed];
}
//0 不旋转 1 90，2 180，3 270
-(void)changeUseOrientation:(int)useOrientation{
    [self.iosplay changeUseOrientation:useOrientation];
}


-(void)changeColorFilterGroup:(QKColorFilterGroup *)group{
    _group = group;
    [self addGroupInfo];
}
-(void)addGroupInfo{
    if(_group != nil){
        [self changeBrightness:_group.brightness];
        [self changeSaturation:_group.saturation];
        [self changeSharpness:_group.sharpness];
        [self changeContrast:_group.contrast];
        [self changeHue:_group.hue];
    }
}
//亮度-1~1 0是正常色
-(void)changeBrightness:(CGFloat)brightness
{
    [self.iosplay changeBrightness:brightness];
}
//对比度 0.0 to 4.0 1.0是正常色
-(void)changeContrast:(CGFloat)contrast
{
    [self.iosplay changeContrast:contrast];
}
//饱和度  0.0  to 2.0 1是正常色
-(void)changeSaturation:(CGFloat)saturation
{
    [self.iosplay changeSaturation:saturation];
    
}
//锐度 -4.0 to 4.0, with 0.0 是正常色
-(void)changeSharpness:(CGFloat)sharpness
{
    [self.iosplay changeSharpness:sharpness];
}

//设置色调 0 ~ 360 0.0 是正常色
-(void)changeHue:(CGFloat)hue
{
    [self.iosplay changeHue:hue];
}
#pragma mark - 清空数据
-(void)resetThings:(BOOL)deleteNowPath{
    [self stopPlayer];
    self.superBoundSize = CGSizeMake(0, 0);
    self.drawType = DrawType9x16;
    if(!self.playView){
        self.playView = [[UIView alloc] init];
        self.playView.backgroundColor = [UIColor clearColor];
    }
    [self.playView removeFromSuperview];
    if(deleteNowPath){
        //结束的时候删除文件缓存
        for(int i = 0;i < self.array_movies.count;i++){
            QKMoviePart *data = self.array_movies[i];
            [self removePath:data.filePath];
        }
        [self.recordInfo deleteFile];
    }
    [self removeAllUnUsePath];

    self.usePath = [[NSMutableDictionary alloc] init];
    self.insertPath = [[NSMutableDictionary alloc] init];
    self.group = nil;
    self.nowMoviePart = nil;
    self.recordInfo = nil;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"insertPathNeedDeletpath"];
    [userDefaults synchronize];
}

-(void)removeAllUnUsePath{
    
    NSFileManager *defauleManager = [NSFileManager defaultManager];
    
    NSArray *allKeys = [self.usePath allKeys];
    for(NSString *key in allKeys){
        
        NSNumber *num = [self.usePath objectForKey:key];
        if([num integerValue] == 0){
           BOOL remove = [defauleManager removeItemAtPath:key error:nil];
//            NSLog(@"remove:%d removeFile:%@",remove,key);
        }
    }
}

-(void)addPath:(NSString*)path{
    [self addPath:path count:1];
}
-(void)addPath:(NSString*)path count:(NSInteger)count{
    if(path == nil){
        return;
    }
    NSNumber *num = [self.usePath objectForKey:path];
    if(num == nil){
        num = @(0);
    }
    NSInteger nowCount = [num integerValue] + count;
    [self.usePath setObject:@(nowCount) forKey:path];
    if(count == 1){
        [self.insertPath setObject:[path stringByReplacingOccurrencesOfString:clipPubthings.pressfixPath withString:@""] forKey:path];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.insertPath forKey:@"insertPathNeedDeletpath"];
        [userDefaults synchronize];
    }
}

-(void)removePath:(NSString*)path{
    if(path == nil){
        return;
    }
    NSNumber *num = [self.usePath objectForKey:path];
    if(num == nil){
        num = @(0);
    }
    NSInteger nowCount = [num integerValue] - 1;
    [self.usePath setObject:@(nowCount) forKey:path];
}


@end

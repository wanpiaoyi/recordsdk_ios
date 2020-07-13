//
//  RecordInfoController.m
//  QukanTool
//
//  Created by yang on 2017/12/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "RecordInfoController.h"
#import "QKMoviePart.h"
#import "RecordAudio.h"
#import "QKGetPCMAudio.h"
#import "ClipPubThings.h"

@interface RecordInfoController()


@property(strong,nonatomic) NSMutableArray *array_movies;
//是否在录制
@property FILE *file;
@property double allTime;
@property double startTime;
@property BOOL recordBegin;
@property int readLength;

//数据保存的
@property(copy,nonatomic) NSString *recordPath;
@property(strong,nonatomic) NSString *musicPath;
@property (nonatomic) double orgValue;
@property (nonatomic) double backValue;
@property (nonatomic) double recordValue;
@property(copy,nonatomic) NSString *oldPath;

@property BOOL canRecord;
@property BOOL stopCreatePcm;

@end


@implementation RecordInfoController

-(void)dealloc{
    [self endRecord];
}

-(id)init:(NSArray*)arrayMovies path:(NSString*)recordAddress isOld:(BOOL)isOld{
    NSFileManager * manager = [NSFileManager defaultManager];
    NSLog(@"recordAddress:%@ isOld:%d",recordAddress,isOld);
    if(isOld&&[manager fileExistsAtPath:recordAddress]){
        self.oldPath = recordAddress;
        self.recordPath = recordAddress;
        recordAddress = [self getTempAddress];
    }else{
        isOld = NO;
    }

    
    self.orgValue = 1;
    self.backValue = 1;
    self.recordValue = 1;
    
    self.recordPath = recordAddress;
    self.audioStartRecord = NO;
    self.array_movies = [[NSMutableArray alloc] init];
    
    if(recordAddress == nil||[recordAddress isKindOfClass:[NSNull class]]||recordAddress.length == 0){
        NSLog(@"error:录音地址不能为空");
        return nil;
    }else{
        NSLog(@"recordAddress:%@",recordAddress);
        self.recordPath = recordAddress;
    }
    
    double allTime = 0;
    
    for(QKMoviePart *part in arrayMovies){
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
        [self.array_movies addObject:[QKMoviePart copyMoviePart:part]];
    }
    self.allTime = allTime;
    self.canRecord = NO;
    self.stopCreatePcm = NO;
    //创建新文件并且写入
    long length = [self getSize:allTime];
    
    WS(weakSelf);
    if(!isOld){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            FILE *file = fopen([recordAddress UTF8String], "w+");
            
            long writeInt = 0;
            char *buffer = (char *)malloc(1024*1024);
            memset(buffer, 0, 1024*1024);
            while (writeInt < length && !weakSelf.stopCreatePcm) {
                long writeSize = length - writeInt;
                if(writeSize > 1024*1024){
                    writeSize = 1024*1024;
                }
                fwrite(buffer, writeSize, 1, file);
                writeInt += writeSize;
            }
            free(buffer);
            fclose(file);
            weakSelf.canRecord = YES;
        });
    }else{
        FILE *copyFile = fopen([self.recordPath UTF8String], "w+");
        FILE *readFile = fopen([self.oldPath UTF8String], "r+");
        char *buffer = (char *)malloc(1024*1024);
        long nowRead = 0;
        while (feof(readFile) == 0){
            long readSize = 1024*1024;
            nowRead = fread(buffer, 1, readSize, readFile);
            fwrite(buffer, 1, nowRead, copyFile);
        }
        free(buffer);
        self.canRecord = YES;
    }

    
    return self;
}



//修改视频文件的顺序
-(void)changeMovies:(NSArray*)arrayMovies{
    if(arrayMovies == nil){
        NSLog(@"ERROR:arrayMovies is nil");
        return;
    }
    if(self.audioStartRecord){
        NSLog(@"error:正在录音不能修改视频片段");
        return;
    }

    
    double allTime = 0;
    Boolean movieChanges = NO;
    if(arrayMovies.count != self.array_movies.count){
        movieChanges = YES;
    }
    for(int i = 0; i < arrayMovies.count;i++){
        QKMoviePart *part = arrayMovies[i];
        if(!movieChanges && i < self.array_movies.count){
            QKMoviePart *oldPart = self.array_movies[i];
            NSLog(@"oldPart.moviePartId:%@",oldPart.moviePartId);
            NSLog(@"part.moviePartId:%@",part.moviePartId);
            if(!([oldPart.moviePartId isEqualToNumber:part.moviePartId]&&oldPart.movieStartTime == part.movieStartTime && oldPart.movieEndTime == part.movieEndTime&&oldPart.speedType == part.speedType)){
                movieChanges = YES;
            }
        }else{
            movieChanges = YES;
        }
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
       
    }
    self.allTime = allTime;
    if(!movieChanges){
        NSLog(@"录音文件没有发生改变");
        return;
    }
    //创建一个临时音频文件，用于缓存数据
    
    NSString *path = [self getTempAddress];
    NSFileManager * manager = [NSFileManager defaultManager];
    [manager moveItemAtPath:self.recordPath toPath:path error:nil];
    
    
    
    
    FILE *copyFile = fopen([self.recordPath UTF8String], "w+");
    {
        //创建新文件并且写入
        long length = [self getSize:allTime];
        if(length % 2 == 1){
            length = length+1;
        }
        long writeInt = 0;
        char *buffer = (char *)malloc(1024*1024);
        memset(buffer, 0, 1024*1024);
        while (writeInt < length) {
            long writeSize = length - writeInt;
            if(writeSize > 1024*1024){
                writeSize = 1024*1024;
            }
            fwrite(buffer, writeSize, 1, copyFile);
            writeInt += writeSize;
        }
        free(buffer);
    }
    FILE *file = fopen([path UTF8String], "r");
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(QKMoviePart *part in arrayMovies){
        QKMoviePart *nowPart = [QKMoviePart copyMoviePart:part];
        
        QKMoviePart *oldPart = [self getOldMoviePart:part.moviePartId];
        
        if(oldPart != nil&&oldPart.audioArray != nil && oldPart.audioArray.count > 0 && oldPart.speedType == part.speedType){
            double speed = part.speed;
            for(PartAudioRecord *partAudio in oldPart.audioArray){
                //这个录音与新的片段存在重合部分，那么久复制这个文件
                if(partAudio.movieStartTime < part.movieEndTime && partAudio.movieEndTime > part.movieStartTime){
                    
                    
                    double startTime = partAudio.audioStartTime + (MAX(partAudio.movieStartTime, part.movieStartTime) -partAudio.movieStartTime)/speed;
                    
                    double endTime = partAudio.audioEndTime + (MIN(partAudio.movieEndTime, part.movieEndTime) -partAudio.movieEndTime)/speed;
                    long readStartOffset =  [self getSize:startTime];
                    
                    fseek(file, readStartOffset, SEEK_SET);
                    if(partAudio.movieStartTime > part.movieStartTime){
                        long writeStartOffset =  [self getSize:part.beginTime + (partAudio.movieStartTime -part.movieStartTime)/speed];
                        
                        fseek(copyFile, writeStartOffset, SEEK_SET);
                        [nowPart setNewRecordPart:part.beginTime + (partAudio.movieStartTime -part.movieStartTime)/speed endTime:endTime - startTime + part.beginTime + (partAudio.movieStartTime -part.movieStartTime)/speed];
                        
                    }else{
                        long writeStartOffset =  [self getSize:part.beginTime];
                        
                        fseek(copyFile, writeStartOffset, SEEK_SET);
                        [nowPart setNewRecordPart:part.beginTime endTime:endTime - startTime + part.beginTime];
                        
                    }
                    
                    
                    long length = [self getSize:endTime - startTime] ;
                    
                    long nowRead = 0;
                    char *buffer = (char *)malloc(1024*1024);
                    
                    while (nowRead < length) {
                        long readSize = length - nowRead;
                        if(readSize > 1024*1024){
                            readSize = 1024*1024;
                        }
                        fread(buffer, 1, readSize, file);
                        fwrite(buffer, 1, readSize, copyFile);
                        nowRead+=readSize;
                    }
                    free(buffer);
                }
            }
        }
        [array addObject:nowPart];
    }
    fclose(file);
    fclose(copyFile);
    [manager removeItemAtPath:path error:nil];
    self.array_movies = array;
    
}

/*
 当视频新增一个分割的片段调用该方法
 */
-(void)changeCutPart:(NSNumber *)oldPartId newPart:(QKMoviePart *)newPart  movies:(NSArray *)arrayMovies{
    double softStartTime = newPart.movieStartTime;
    NSMutableArray *arrayCutAudios = [[NSMutableArray alloc] init];
    for(int i = 0;i < self.array_movies.count;i++){
        QKMoviePart *oldAudioPart = self.array_movies[i];
        //如果这次录音跨越了这个片段的时候
        if([oldAudioPart.moviePartId isEqualToNumber:oldPartId]){

            double speed = oldAudioPart.speed;
            for(PartAudioRecord *partAudio in oldAudioPart.audioArray){
                if(partAudio.movieStartTime > softStartTime){
                    [arrayCutAudios addObject:partAudio];
                }else if(partAudio.movieEndTime > softStartTime){
                    PartAudioRecord *newCutAudio = [PartAudioRecord copyPart:partAudio];
                    
                    partAudio.movieEndTime = softStartTime;
                    partAudio.audioEndTime = partAudio.audioStartTime + (partAudio.movieEndTime - partAudio.movieStartTime)/speed;
                    
                    newCutAudio.movieStartTime = softStartTime;
                    newCutAudio.audioStartTime = partAudio.audioEndTime;
                    [arrayCutAudios addObject:newCutAudio];
                }
            }
            //给音频列表中增加裁剪片段，模拟一开始这个片段就存在的
            QKMoviePart *newCutPart = [QKMoviePart copyMoviePart:oldAudioPart];
            newCutPart.moviePartId = newPart.moviePartId;
            newCutPart.movieStartTime = softStartTime;
            newCutPart.audioArray = arrayCutAudios;
            for(PartAudioRecord *partAudio in arrayCutAudios){
                [oldAudioPart.audioArray removeObject:partAudio];
            }

            oldAudioPart.movieEndTime = softStartTime;
            [self.array_movies insertObject:newCutPart atIndex:i+1];
            
            break;
        }
    }
}

-(NSString*)getTempAddress{
    if(self.recordPath == nil){
        return @"";
    }
    NSArray *array = [self.recordPath componentsSeparatedByString:@"/"];
    NSString *name = array[array.count-1];
    NSString *replaceName = [NSString stringWithFormat:@"temp_%@.pcm",[self ret32bitString]];
    NSString *newPath = [self.recordPath stringByReplacingOccurrencesOfString:name withString:replaceName];
    return newPath;
}
-(BOOL)canStartRecord{
    return self.canRecord;
}
-(void)startRecord:(double)startTime{
    self.file = fopen([self.recordPath UTF8String], "r+");

    self.startTime = startTime;
    long startOffset = [self getSize:startTime];
    fseek(self.file, startOffset, SEEK_SET);
    self.audioStartRecord = YES;
    self.recordBegin = NO;
    self.readLength = 0;

}
-(void)startBegin{
    self.recordBegin = YES;
}
-(void)pauseRecord{
    self.recordBegin = NO;
    self.audioStartRecord = NO;
    fclose(self.file);
    self.file = NULL;
}
-(void)endRecord{
    if(self.file != NULL){
        fclose(self.file);
        self.file = NULL;
    }
}

//把pcm写入文件中
-(int)writePcm:(char*)pcm length:(int)length{
    if(self.file == NULL){
        return 0;
    }
    int writeSize = 0;
    if(self.audioStartRecord&&self.recordBegin){
        double endTime = self.readLength/(AudioBits*AudioChannels*AudioSampleRate/8.0) + self.startTime;
        if(endTime < self.allTime){
            fwrite(pcm, length, 1, self.file);
            self.readLength += length;
            writeSize = length;
        }
        
        if(self.recordCall){
            if(endTime >= self.allTime){
                self.recordCall(RecordCallRecordEnd,self.allTime);
            }else{
                self.recordCall(RecordCallRecording,endTime);
            }
        }
    }
    return writeSize;
}

-(double)getEndTime{
    return self.readLength/(AudioBits*AudioChannels*AudioSampleRate/8.0) + self.startTime;
}
-(double)getAllMovieTime{
    return self.allTime;
}
//计算音频的时间
-(void)setAudioRecordTime:(double)startTime  endTime:(double)endTime{
    for(int i = 0 ;i < self.array_movies.count;i++){
        QKMoviePart *part = self.array_movies[i];
        //如果这次录音跨越了这个片段的时候
        double partBeginTime = part.beginTime;
        double partEndtime = part.beginTime + part.movieDuringTime;
        if(partBeginTime < endTime && partEndtime > startTime){
            double partRecordStartTime = 0;
            double partRecordEndTime = 0;
            if(partBeginTime > startTime){
                partRecordStartTime = partBeginTime;
            }else{
                partRecordStartTime = startTime;
            }
            
            if(partEndtime < endTime){
                partRecordEndTime = partEndtime;
            }else{
                partRecordEndTime = endTime;
            }
            [part setNewRecordPart:partRecordStartTime endTime:partRecordEndTime];
        }
    }
}

//清空所有配音
-(void)clearAllAudios{
    for(int i = 0 ;i < self.array_movies.count;i++){
        QKMoviePart *part = self.array_movies[i];
        NSMutableArray *audioArray = part.audioArray;
        if(audioArray != nil && audioArray.count > 0){
            for(PartAudioRecord *part in audioArray){
                [self removeFile:part.audioStartTime endTime:part.audioEndTime];
            }
        }
        part.audioArray = nil;
    }
}
//删除一个片段
-(void)removePart:(double)startTime endTime:(double)endTime{
    [self removeFile:startTime endTime:endTime];
    for(QKMoviePart *part in self.array_movies){
        if(part.beginTime < endTime && part.beginTime + part.movieDuringTime > startTime){
            if(part.audioArray != nil && part.audioArray.count > 0){
                for(PartAudioRecord *partAudio in part.audioArray){
                    if(partAudio.audioStartTime == startTime || partAudio.audioEndTime == endTime){
                        [part.audioArray removeObject:partAudio];
                        NSLog(@"removeObject:partAudio");
                        return;
                    }
                }
            }
        }
    }
}

//删除文件中的内容
-(void)removeFile:(double)startTime endTime:(double)endTime{
    self.file = fopen([self.recordPath UTF8String], "r+");

    long offset = [self getSize:startTime] ;
    long allLength = [self getSize:endTime - startTime]+ 2;
    int size = fseek(self.file, offset, SEEK_SET);
    
    long nowWrite = 0;
    char *buffer = (char *)malloc(1024*1024);
    
    while (nowWrite < allLength) {
        long readSize = allLength - nowWrite;
        if(readSize > 1024*1024){
            readSize = 1024*1024;
        }
        fwrite(buffer, readSize, 1, self.file);
        nowWrite+=readSize;
    }
    free(buffer);
    fclose(self.file);
    self.file = NULL;
}



-(QKAudioBean*)getAudioBean{
    QKAudioBean *audioBean = [[QKAudioBean alloc] init];
    audioBean.orgVale = self.orgValue;
    audioBean.backVale = self.backValue;
    audioBean.recordVale = self.recordValue;
    audioBean.recordPath = self.recordPath;
    audioBean.backMusic = _musicPath;
    return audioBean;
}

-(void)setMusicPath:(NSString *)musicPath{
    _musicPath = musicPath;
}
-(NSString*)getMusicPath{
    return _musicPath;
}
-(void)setOrgValue:(double)value{
    _orgValue = value;
}
-(void)setBackValue:(double)value{
    _backValue = value;
}
-(void)setRecordValue:(double)value{
    _recordValue = value;
}

-(NSArray*)getArray_movies{
    return _array_movies;
}

-(NSString*)getRecordPath{
    return _recordPath;
}

-(QKMoviePart*)getOldMoviePart:(NSNumber*)part_id{
    if(part_id == nil){
        NSLog(@"error:part_id 是 nil");
        return nil;
    }
    for(QKMoviePart *part in self.array_movies){
        //如果这次录音跨越了这个片段的时候
        if([part.moviePartId isEqualToNumber:part_id]){
            return part;
        }
    }
    return nil;
}

-(long)getSize:(double)time{
    long length = (long)(time*AudioBits*AudioChannels*AudioSampleRate/8);
    if(length%2 == 1){
        length = length - 1;
    }
    return length;
}
//随机生成32位字符串党文件名
-(NSString *)ret32bitString

{
    
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

+(RecordInfoController*)copyInfo:(RecordInfoController*)old{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *arrayMovies = old.array_movies;
    for(QKMoviePart *part in arrayMovies){
        [array addObject:[QKMoviePart copyMoviePart:part]];
    }
    
    RecordInfoController *control = [[RecordInfoController alloc] init];
    control.array_movies = array;
    control.allTime = old.allTime;
    control.startTime = 0;
    control.recordPath = old.recordPath;
    control.recordPath = [control getTempAddress];
    control.recordBegin = NO;
    control.readLength = 0;
    control.musicPath = old.musicPath;
    control.orgValue = old.orgValue;
    control.backValue = old.backValue;
    control.recordValue = old.recordValue;
    
    [control copyPath:old.recordPath];
    return control;
}

-(void)copyPath:(NSString*)oldPath{
    FILE *copyFile = fopen([self.recordPath UTF8String], "w+");
    FILE *readFile = fopen([oldPath UTF8String], "r+");
    char *buffer = (char *)malloc(1024*1024);
    long nowRead = 0;
    do{
        long readSize = 1024*1024;
        nowRead = fread(buffer, 1, readSize, readFile);
        fwrite(buffer, 1, readSize, copyFile);
    }while (nowRead <= 0);
    free(buffer);
}
//将新文件替换掉旧的文件
-(void)changeRecordPath:(NSString*)recordPath{
    if(recordPath == nil || [recordPath isEqualToString:self.recordPath]){
        return;
    }
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL finish = [manager removeItemAtPath:recordPath error:nil];
    finish = [manager moveItemAtPath:self.recordPath toPath:recordPath error:nil];
    self.recordPath = recordPath;
}


-(void)deleteFile{
    self.stopCreatePcm = YES;
    while (!self.canRecord) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:self.recordPath error:nil];
}
-(void)deleteOldFile{
    if(self.oldPath != nil &&self.oldPath.length > 0){
        NSFileManager * manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:self.oldPath error:nil];
    }
}
@end

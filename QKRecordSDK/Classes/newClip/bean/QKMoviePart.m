//
//  QKMoviePart.m
//  QukanTool
//
//  Created by yang on 17/6/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKMoviePart.h"
#import <QKLiveAndRecord/QKPlayerImageHelper.h>
#import "ClipPubThings.h"

static long partId = 0;

@implementation QKMoviePart

-(id)init{
    if(self = [super init]){
        self.moviePartId = @(partId);
        self.transfer = [MovieTransfer getDefaultTransfer];
        partId++;
        self.isTitle = NO;
        self.speedType = (lineCounts+1)/2;
        self.filterType = 0;
        self.orientation = 0;
        self.deleteEndEdict = YES;
    }
    return self;
}

+(QKMoviePart*)startWithRecord:(RecordData*)data{
    QKMoviePart *qk = [[QKMoviePart alloc] init];
    qk.movieStartTime = 0;
    
   
    qk.fileAddress = data.address;
    RecordData *data_movie = [[RecordData alloc] init];
    data_movie.address = data.address;
    qk.data = data;
    qk.data.type = data.type;
    NSLog(@"data.type:%@",data.type);
    if([data isImage]){
        qk.isImage = YES;
        qk.movieEndTime = 3;
        qk.movieStartTime = 0;
        qk.allDuring = 20;

    }else{
        CMTime   time = [data.asset duration];
        double seconds = time.value*1.0/time.timescale;
        qk.movieEndTime = seconds;
        qk.movieStartTime = 0;
        qk.allDuring = seconds;

    }
    qk.deleteEndEdict = data.deleteEndEdict;
//    qk.during = seconds;
    return qk;
}

+(QKMoviePart*)copyMoviePart:(QKMoviePart*)data{
    QKMoviePart *qk = [[QKMoviePart alloc] init];
    qk.movieStartTime = data.movieStartTime;
    
    
    RecordData *data_movie = [[RecordData alloc] init];
    data_movie.address = data.data.address;
    data_movie.asset = data.data.asset;
    data_movie.type = data.data.type;
    qk.data = data_movie;
    qk.isTitle = data.isTitle;

	qk.isImage = data.isImage;
    qk.moviePartId = data.moviePartId;
    qk.movieStartTime = data.movieStartTime;
    qk.movieEndTime = data.movieEndTime;
    qk.beginTime = data.beginTime;
    qk.fileAddress = data.fileAddress;
    qk.allDuring = data.allDuring;
    qk.transfer = data.transfer;
    qk.speedType = data.speedType;
    qk.filterType = data.filterType;
    qk.orientation = data.orientation;
    qk.deleteEndEdict = data.deleteEndEdict;

    NSLog(@"qk.transfer:%@ data.transfer:%@",qk.transfer.name,data.transfer.name);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(data.audioArray != nil && data.audioArray.count > 0){
        for(PartAudioRecord *part in data.audioArray){
            [array addObject:[PartAudioRecord copyPart:part]];
        }
    }
    qk.audioArray = array;
    return qk;
}

-(NSDictionary*)getDictionaryByBean{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(_moviePartId != nil){
        [dict setObject:self.moviePartId forKey:@"moviePartId"];
    }
    [dict setObject:@(self.movieStartTime) forKey:@"startTime"];
    [dict setObject:@(self.movieEndTime) forKey:@"endTime"];
    [dict setObject:@(self.beginTime) forKey:@"beginTime"];
    [dict setObject:@(self.allDuring) forKey:@"allDuring"];
    [dict setObject:@(self.isClip) forKey:@"isClip"];
    [dict setObject:@(self.isImage) forKey:@"isImage"];
    [dict setObject:self.fileAddress forKey:@"fileAddress"];
    
    [dict setObject:@(self.speedType) forKey:@"speedType"];
    [dict setObject:@(self.filterType) forKey:@"filterType"];
    [dict setObject:@(self.orientation) forKey:@"orientation"];
    [dict setObject:@(self.deleteEndEdict) forKey:@"deleteEndEdict"];

    if(self.transfer != nil){
//        NSLog(@"self.transfer:%@",[self.transfer getDictionary]);

        [dict setObject:[self.transfer getDictionary] forKey:@"transfer"];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(self.audioArray != nil && self.audioArray.count > 0){
        for(PartAudioRecord *part in self.audioArray){
            [array addObject:[part getDictionary]];
        }
    }
    [dict setObject:array forKey:@"audioArray"];
//    NSLog(@"dict:%@",dict);
    return dict;
 
}

+(QKMoviePart*)getMoviePartByBean:(NSDictionary*)dict{
    QKMoviePart *qk = [[QKMoviePart alloc] init];
    qk.moviePartId = dict[@"moviePartId"];
    if(partId <= [qk.moviePartId longValue]){
        partId = [qk.moviePartId longValue] + 1;
    }
    qk.movieStartTime = [dict[@"startTime"] doubleValue];
    qk.movieEndTime = [dict[@"endTime"] doubleValue];
    qk.beginTime = [dict[@"beginTime"] doubleValue];
    qk.allDuring = [dict[@"allDuring"] doubleValue];
    qk.isClip = [dict[@"isClip"] boolValue];
    qk.isImage = [dict[@"isImage"] boolValue];
    qk.speedType = [dict[@"speedType"] intValue];
    qk.filterType = [dict[@"filterType"] intValue];
    qk.orientation = [dict[@"orientation"] intValue];
    qk.deleteEndEdict = [dict[@"orientation"] boolValue];

    qk.fileAddress = dict[@"fileAddress"];
    RecordData *data_movie = [[RecordData alloc] init];
    data_movie.address = qk.fileAddress;
    if(qk.isImage){
        data_movie.type = imageType;
    }
    qk.data = data_movie;
    qk.data.clipStartTime = qk.movieStartTime;
    NSArray *array = dict[@"audioArray"];
    NSMutableArray *array_audios = [[NSMutableArray alloc] init];
    if(array != nil && array.count > 0){
        for(NSDictionary *dic_audio in array){
            NSLog(@"dic_audio:%@",dic_audio);

            [array_audios addObject:[PartAudioRecord getPartByDic:dic_audio]];
        }
    }
    qk.audioArray = array_audios;
    NSDictionary *transfer = dict[@"transfer"];
    if(transfer != nil){
        qk.transfer = [MovieTransfer getTransferByDic:transfer];
    }
//    qk.during = [dict[@"during"] doubleValue];
    return qk;
}

-(NSString*)getOrgPath{
    return [[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.fileAddress] copy];
}

-(NSString*)filePath{
    if(self.isImage){
        return [self getImagePath];
    }else{
        return [[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.fileAddress] copy];
    }
}


-(void)saveImage{
    
    @synchronized(self){
        NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *file_path = [NSString stringWithFormat:@"%@/%@",pressfixPath,[self getRgbaPath]];
        NSFileManager *file = [NSFileManager defaultManager];
        
        //录像文件目录
        if ([file fileExistsAtPath:file_path] && self.width != 0 && self.height != 0)
        {
            return;
        }
        NSData *imgData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.fileAddress]];
        UIImage *original = [UIImage imageWithData:imgData];

        int width = original.size.width;
        int height = original.size.height;
   
        UIImageOrientation imageOrientation=original.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp||width%64!= 0)
        {
            if(width%64!= 0){
                width = (width/64 + 1)*64;
                height = width * height /original.size.width;
            }
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
            [original drawInRect:CGRectMake(0, 0, width, height)];
            original = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
            NSLog(@"调整图片角度完毕调整图片角度完毕调整图片角度完毕");
        }
        UIImage *img = original;

        ;
        NSData *data1 = UIImageJPEGRepresentation(original, 1.0);
        [data1 writeToFile:[NSString stringWithFormat:@"%@/Temp/1.jpg",clipPubthings.pressfixPath] atomically:YES];
        
        self.width = img.size.width;
        self.height = img.size.height;
        NSLog(@"self.width:%.1lf height:%.1lf width:%d height:%d",self.width,self.height,width,height);

        char *rgba = [QKPlayerImageHelper convertUIImageToBitmapBGRA8:img];
        
        NSData *data = [NSData dataWithBytes:rgba length:img.size.width*img.size.height*4];
        BOOL write = [data writeToFile:file_path atomically:YES];
        if(write){
            NSLog(@"write:%@",file_path);
        }
        
        free(rgba);
        NSLog(@"imgData:%ld  width:%.1f height:%.1f",imgData.length,self.width,self.height);
    }
    
}

-(NSString*)getImagePath{

    [self saveImage];
 
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *file_path = [NSString stringWithFormat:@"%@/%@",pressfixPath,[self getRgbaPath]];
    return file_path;
}

-(NSString *)getRgbaPath{
    if(self.fileAddress == nil){
        return @"norgb";
    }
    NSArray *array_name = [self.fileAddress componentsSeparatedByString:@"/"];
    NSString *imgName = array_name[(array_name.count - 1)];
    NSArray *array_nameFirst = [imgName componentsSeparatedByString:@"."];
    NSString *useImgName = [NSString stringWithFormat:@"%@.rgba",array_nameFirst[0]];
    //存放在临时目录中
    return [NSString stringWithFormat:@"Temp/%@",useImgName];
}

-(void)removeTemp{
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *file_path = [NSString stringWithFormat:@"%@/%@",pressfixPath,[self getRgbaPath]];
    NSLog(@"removeTemp:%@",file_path);
    NSFileManager *file = [NSFileManager defaultManager];

    BOOL removed = [file removeItemAtPath:file_path error:nil];
    if(removed){
        NSLog(@"1111removeTemp:%@",file_path);
    }
}


//添加一个新的录音文件时间
-(void)setNewRecordPart:(double)audioPartStartTime endTime:(double)audioPartEndTime{
    if(self.audioArray == nil){
        self.audioArray = [[NSMutableArray alloc] init];
        PartAudioRecord *part = [self getAudioPart:audioPartStartTime endTime:audioPartEndTime];
        [self.audioArray addObject:part];
        return;
    }
    NSMutableArray *array_newParts = [[NSMutableArray alloc] init];
    for(PartAudioRecord *part in self.audioArray){
        //排除无交集的音频
        if(part.audioStartTime > audioPartEndTime){
            [array_newParts addObject:part];
            continue;
        }
        if(part.audioEndTime < audioPartStartTime){
            [array_newParts addObject:part];
            continue;
        }
        
        //新录音的文件在中间的时候
        if(part.audioStartTime < audioPartStartTime && part.audioEndTime > audioPartEndTime){
            PartAudioRecord *part1 = [self getAudioPart:part.audioStartTime endTime:audioPartStartTime];
            PartAudioRecord *part2 = [self getAudioPart:audioPartEndTime endTime:part.audioEndTime];

            [array_newParts addObject:part1];
            [array_newParts addObject:part2];
            
        }
        if(part.audioStartTime >= audioPartStartTime && part.audioEndTime > audioPartEndTime){
            PartAudioRecord *part1 = [self getAudioPart:audioPartEndTime endTime:part.audioEndTime];
            [array_newParts addObject:part1];
        }
        if(part.audioStartTime < audioPartStartTime && part.audioEndTime <= audioPartEndTime){
            PartAudioRecord *part1 = [self getAudioPart:part.audioStartTime endTime:audioPartStartTime];
            [array_newParts addObject:part1];
        }
    }
    PartAudioRecord *part = [self getAudioPart:audioPartStartTime endTime:audioPartEndTime];
    [array_newParts addObject:part];
    NSLog(@"array_newParts:%ld",array_newParts.count);
    self.audioArray = array_newParts;
}

//计算录音文件在视频中的开始时间
-(double)getAudioStartTimeInMovie:(double)audioStartTime{
    return (audioStartTime - self.beginTime)*self.speed + self.movieStartTime;
}

//根据时间创建音频片段
-(PartAudioRecord *)getAudioPart:(double)audioPartStartTime endTime:(double)audioPartEndTime{
    PartAudioRecord *part = [[PartAudioRecord alloc] init];
    part.audioStartTime = audioPartStartTime;
    part.audioEndTime = audioPartEndTime;
    part.movieStartTime = [self getAudioStartTimeInMovie:audioPartStartTime];
    part.movieEndTime = part.movieStartTime + (audioPartEndTime - audioPartStartTime)*self.speed;
    return part;
}

-(double)movieDuringTime{
    return (self.movieEndTime - self.movieStartTime)/[self speed];
}
-(double)speed{
    int nowSpeed = self.speedType - (lineCounts - 1)/2;
    if(nowSpeed == 1){
        return 1;
    }
    if(nowSpeed < 1){
        return 1/(1 - (nowSpeed - 1) * 0.5);
    }
    return 1 + (nowSpeed - 1) * 0.5;
}

+(NSNumber*)getNewMoviePartId{
    NSNumber *num = @(partId);
    partId++;;
    return num;
}

@end

//
//  RecordAudio.m
//  QukanTool
//
//  Created by yang on 2017/12/11.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "RecordAudio.h"
#import "QKGetPCMAudio.h"
#import "QKMoviePart.h"
#import "RecordInfoController.h"
#import "ClipPubThings.h"
@interface RecordAudio()

@property double startTime;



@property (strong,nonatomic) QKGetPCMAudio *audio;
@property (strong,nonatomic) RecordInfoController *recordControl;

//数据锁
@property(strong,nonatomic)NSLock *lock;



@end

@implementation RecordAudio

-(void)dealloc{
    [self endRecord];
}

-(instancetype)init:(RecordInfoController*)control{
    if(self = [super init]){
        self.recordControl = control;
        self.startTime = 0;
        self.audio = [[QKGetPCMAudio alloc] init];
        WS(weakSelf);
        [self.audio setGetPcm:^(char *pcm, int length) {
            [weakSelf writePcm:pcm length:length];
        }];
        
        self.lock = [[NSLock alloc] init];
    }
    return self;
}


-(void)startRecord:(double)startTime{
    if(self.recordControl.audioStartRecord){
        return;
    }
    [self.lock lock];
    //seek到指定位置，覆盖文件
    [self.recordControl startRecord:startTime];
    
    _startTime = startTime;
    [self.audio startRecordAudio];
    [self.lock unlock];
}
-(void)startBegin{
    [self.recordControl startBegin];
}
//暂停
-(void)pauseRecord{
    if(!self.recordControl.audioStartRecord){
        return;
    }
    [self.audio stopRecordAudio];
    [self.lock lock];
    [self.recordControl pauseRecord];
    [self setAudioRecordTime];
    [self.lock unlock];

}

//结束录音
-(void)endRecord{
    [self pauseRecord];
}



//把pcm写入文件中
-(void)writePcm:(char*)pcm length:(int)length{
    [self.lock lock];
    [self.recordControl writePcm:pcm length:length];
    [self.lock unlock];
    
}

//计算音频的时间
-(void)setAudioRecordTime{
    double endTime = [self.recordControl getEndTime];;
    if(endTime == self.startTime){
        return;
    }
    [self.recordControl setAudioRecordTime:self.startTime endTime:endTime];
}



-(long)getSize:(double)time{
    long length = (long)(time*AudioBits*AudioChannels*AudioSampleRate/8);
    if(length%2 == 1){
        length = length - 1;
    }
    return length;
}





@end

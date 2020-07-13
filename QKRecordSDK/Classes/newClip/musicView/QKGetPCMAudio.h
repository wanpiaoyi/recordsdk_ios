//
//  QKRecord.h
//  IPCameraSDK
//
//  Created by yang on 16/6/14.
//  Copyright © 2016年 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#define AudioSampleRate 44100.0
#define AudioBits 16.0
#define AudioChannels 1.0

#define kNumberBuffers      3
typedef void (^GetRecordPcm)(char *pcm,int length);

typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
    
} AQCallbackStruct;
@interface QKGetPCMAudio : NSObject{
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    AudioStreamBasicDescription _audioFormat;
    
}
@property (nonatomic, copy) GetRecordPcm getPcm;


@property (nonatomic, assign) AudioUnit audioUnit;
@property (atomic, assign) BOOL isRecord;
- (BOOL) startRecordAudio;
- (BOOL) stopRecordAudio;

@end

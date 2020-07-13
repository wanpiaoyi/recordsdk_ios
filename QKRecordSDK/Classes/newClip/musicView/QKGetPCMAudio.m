//
//  QKRecord.m
//  IPCameraSDK
//
//  Created by yang on 16/6/14.
//  Copyright © 2016年 ReNew. All rights reserved.
//

#import "QKGetPCMAudio.h"
#include <pthread.h>
#define kOutputBus 0
#define kInputBus 1

@implementation QKGetPCMAudio



- (BOOL) startRecordAudio
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    if(_audioUnit != NULL){
        
        aqc.run = 0;
        AudioOutputUnitStop(_audioUnit);
        AudioUnitUninitialize(_audioUnit);
        AudioComponentInstanceDispose(_audioUnit);
        _audioUnit = NULL;

    }
    
    
    NSArray* inputArray = [[AVAudioSession sharedInstance] availableInputs];
    AVAudioSessionPortDescription* descNeedAdd = nil;
    for (AVAudioSessionPortDescription* desc in inputArray) {
        if ([desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            descNeedAdd = desc;
            
        }
        if([desc.portType isEqualToString:AVAudioSessionPortBuiltInMic]){
            if(descNeedAdd == nil){
                descNeedAdd = desc;
            }
        }
        if([desc.portType isEqualToString:AVAudioSessionPortHeadsetMic]){
            descNeedAdd = desc;
            break;
        }
    }
    
    self.isRecord = YES;

    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    
    if(descNeedAdd.portType == nil || [descNeedAdd.portType isEqualToString:AVAudioSessionPortBuiltInMic]){
        desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    }else{
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
    }
    
    //
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    AudioComponentInstanceNew(comp, &_audioUnit);
    
    UInt32 one = 1;
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    
    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         kInputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
    
    _audioFormat.mFormatID = kAudioFormatLinearPCM;
    _audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audioFormat.mSampleRate = 44100;
    _audioFormat.mFramesPerPacket = 1;
    _audioFormat.mBytesPerFrame = 2;
    _audioFormat.mBytesPerPacket = 2;
    _audioFormat.mBitsPerChannel = 16;
    _audioFormat.mChannelsPerFrame = 1;
    
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &_audioFormat,
                         sizeof(_audioFormat));
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kOutputBus,
                         &_audioFormat,
                         sizeof(_audioFormat));
    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one));
    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one));
    
    
    AudioUnitInitialize(_audioUnit);
    
    OSStatus start = AudioOutputUnitStart(_audioUnit);
    
    
    if(start == noErr){
        return YES;
    }else{
        aqc.run = 0;
        AudioQueueDispose(aqc.queue, true);
    }
    return NO;
}

- (BOOL) stopRecordAudio
{
    NSLog(@"stopRecordAudio1");

    NSLog(@"stopRecordAudio2");
    NSLog(@"stopRecordAudio3");
    AudioOutputUnitStop(_audioUnit);
    NSLog(@"stopRecordAudio4");

    aqc.run = 0;
    
    AudioUnitUninitialize(_audioUnit);
    NSLog(@"stopRecordAudio5");

    AudioComponentInstanceDispose(_audioUnit);
    NSLog(@"stopRecordAudio6");

    _audioUnit = NULL;
    NSLog(@"stopRecordAudio7");

    self.isRecord = NO;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];

    return YES;
}

static OSStatus recordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inStartTime,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData)  {
    AudioBufferList bufferList;
    
    SInt16 samples[inNumberFrames];
    memset(&samples, 0, sizeof(samples));
    
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = samples;
    bufferList.mBuffers[0].mNumberChannels = 1;
    bufferList.mBuffers[0].mDataByteSize = inNumberFrames * sizeof(SInt16);
    
    QKGetPCMAudio* qkrecord = (__bridge QKGetPCMAudio *)inRefCon;
    OSStatus status = AudioUnitRender(qkrecord.audioUnit,
                                      ioActionFlags,
                                      inStartTime,
                                      kInputBus,
                                      inNumberFrames, &bufferList);
    if (noErr != status) {
        NSLog(@"error");
        return noErr;
    }
    int buffersize = bufferList.mBuffers[0].mDataByteSize;
    char *audio_pcm = (char*) malloc (sizeof(char)*buffersize);
    memcpy(audio_pcm, bufferList.mBuffers[0].mData, buffersize);
    GetRecordPcm getPcm = qkrecord.getPcm;
    if(getPcm != nil){
        getPcm(audio_pcm,buffersize);
    }
    free(audio_pcm);
    return noErr;
}


@end

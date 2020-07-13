//
//  MP3ToPcm.h
//  MP3TOPCM
//
//  Created by yang on 16/6/23.
//  Copyright © 2016年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKRecordMP3ToPcm : NSObject
+ (OSStatus)mixAudio:(NSString *)audioPath
              toFile:(NSString *)outputPath
  preferedSampleRate:(float)sampleRate;
+ (OSStatus)mixAudioWithUrl:(NSURL *)audioPath
            toFile:(NSString *)outputPath
preferedSampleRate:(float)sampleRate;

+(void)PCMAudioMixing:(UInt32 )frameCount1 buffer1:(char *)buffer1 frameCount2:(UInt32 )frameCount2 buffer2:(char *)buffer2 outBuffer:(char *)outBuffer;

+(void)PCMAudioMixing:(UInt32 )input_size buffer1:(char *)buffer1 buffer2:(char *)buffer2 gain_value:(float)gain_value;
+(void)PCMChangeGainValue:(UInt32 )input_size buffer1:(char *)buffer1 gain_value:(float)gain_value;
@end

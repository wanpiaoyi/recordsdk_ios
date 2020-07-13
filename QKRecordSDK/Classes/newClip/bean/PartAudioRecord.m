//
//  PartAudioRecord.m
//  QukanTool
//
//  Created by yang on 2017/12/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "PartAudioRecord.h"

@implementation PartAudioRecord
+(PartAudioRecord*)copyPart:(PartAudioRecord*)part{
    PartAudioRecord *audioPart = [[PartAudioRecord alloc] init];
    audioPart.movieStartTime = part.movieStartTime;
    audioPart.movieEndTime = part.movieEndTime;
    audioPart.audioStartTime = part.audioStartTime;
    audioPart.audioEndTime = part.audioEndTime;
    return audioPart;
}
-(NSDictionary *)getDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(self.movieStartTime) forKey:@"movieStartTime"];
    [dict setObject:@(self.movieEndTime) forKey:@"movieEndTime"];
    [dict setObject:@(self.audioStartTime) forKey:@"audioStartTime"];
    [dict setObject:@(self.audioEndTime) forKey:@"audioEndTime"];
    return dict;
}

+(PartAudioRecord*)getPartByDic:(NSDictionary*)dict{
    if(dict == nil){
        return nil;
    }
    PartAudioRecord *audioPart = [[PartAudioRecord alloc] init];
    audioPart.movieStartTime = [dict[@"movieStartTime"] doubleValue];
    audioPart.movieEndTime = [dict[@"movieEndTime"] doubleValue];
    audioPart.audioStartTime = [dict[@"audioStartTime"] doubleValue];
    audioPart.audioEndTime = [dict[@"audioEndTime"] doubleValue];
    return audioPart;
}

@end

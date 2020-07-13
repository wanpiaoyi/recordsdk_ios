//
//  PartAudioRecord.h
//  QukanTool
//
//  Created by yang on 2017/12/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartAudioRecord : NSObject

@property double movieStartTime;//在视频文件中的开始时间
@property double movieEndTime;  //在视频文件中的结束时间
@property double audioStartTime;//在本地文件中的开始时间
@property double audioEndTime;  //在本地文件中的结束时间
+(PartAudioRecord*)copyPart:(PartAudioRecord*)part;
-(NSDictionary *)getDictionary;
+(PartAudioRecord*)getPartByDic:(NSDictionary*)dict;
@end

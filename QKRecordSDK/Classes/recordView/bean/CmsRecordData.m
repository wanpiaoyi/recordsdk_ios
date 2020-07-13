//
//  CmsRecordData.m
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import "CmsRecordData.h"
#import "ImageLocalSave.h"
#import <sys/utsname.h>

@interface CmsRecordData ()


@end

@implementation CmsRecordData

+(CmsRecordData*)getVideoByAddress:(NSString*)address{
    CmsRecordData *video = [[CmsRecordData alloc] init];
    NSArray *array = [address componentsSeparatedByString:@"/"];
    NSString *filename = array[array.count - 1];
    
    NSString * uploadfileName = filename;
    NSArray *arr = [filename componentsSeparatedByString:@"."];
    if(arr.count>1){
        uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",arr[0],arr[arr.count-1]];
    }
    NSNumber *start_time = @((NSInteger)[[NSDate date] timeIntervalSince1970]);
    
    video.activityId = @(0);
    video.start_time = start_time;
    video.address = address;
    video.fileName = filename;
    video.displayname = filename;
    video.uploadfileName = uploadfileName;
    return video;
}
@end

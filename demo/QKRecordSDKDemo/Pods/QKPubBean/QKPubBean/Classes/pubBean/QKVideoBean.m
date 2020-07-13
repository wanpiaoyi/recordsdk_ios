//
//  QKVideoBean.m
//  QukanTool
//
//  Created by yang on 17/1/7.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKVideoBean.h"

@implementation QKVideoBean
+(QKVideoBean*)getVideoByAddress:(NSString*)address{
    QKVideoBean *video = [[QKVideoBean alloc] init];
    video.address = address;
    NSArray *array = [address componentsSeparatedByString:@"/"];
    NSString *filename = array[array.count - 1];
    video.fileName = filename;
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *path = [NSString stringWithFormat:@"%@/%@",pressfixPath,address];
    NSURL *url = [NSURL fileURLWithPath:path];
    if(url != nil){
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                              
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:url options:opts];
        video.asset = myAsset;
    }
    NSString * uploadfileName = filename;
    NSArray *arr = [filename componentsSeparatedByString:@"."];
    if(arr.count>1){
        uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",arr[0],arr[arr.count-1]];
    }
    video.uploadfileName = uploadfileName;

    
    return video;
}
@end

//
//  ImageLocalSave.m
//  QukanTool
//
//  Created by yang on 17/3/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ImageLocalSave.h"

@implementation ImageLocalSave
+(ImageLocalSave *)defaultImageLocalSave{
    static dispatch_once_t once;
    static ImageLocalSave *sharedView;
    dispatch_once(&once, ^ {
        
        sharedView = [[ImageLocalSave alloc] init];
        sharedView.cache = [[NSCache alloc] init];
        sharedView.cache.countLimit = 25;  // 设置了存放对象的最大数量
    });
    return sharedView;
}
@end

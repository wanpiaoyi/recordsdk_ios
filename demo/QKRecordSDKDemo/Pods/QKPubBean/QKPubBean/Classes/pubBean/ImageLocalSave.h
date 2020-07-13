//
//  ImageLocalSave.h
//  QukanTool
//
//  Created by yang on 17/3/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
//图片缓存
@interface ImageLocalSave : NSObject
+(ImageLocalSave *)defaultImageLocalSave;
@property(strong,nonatomic)NSCache *cache;

@end

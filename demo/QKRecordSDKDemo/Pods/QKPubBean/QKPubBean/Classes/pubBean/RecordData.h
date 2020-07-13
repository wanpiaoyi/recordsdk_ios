//
//  RecordData.h
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define selectFromPhotoVideo @"selectFromPhoto"
#define selectFromPhotoImg @"selectImageFromPhoto"

#define liveType @"liveVideo"
#define clipType @"clipVideo"
#define localRecordType @"localRecordVideo"
#define imageType @"image"
#define localAudioType @"localAudioType"


typedef NS_ENUM(NSUInteger, RecordUploadState) {
    RecordUploadStateNotUpload,
    RecordUploadStateUploading,
    RecordUploadStateSuccess
};

@class AVAsset;
@interface RecordData : NSObject

@property (nonatomic, strong) NSNumber *liveid;
@property (nonatomic, strong) NSString *liveendname;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *displayname;
@property (nonatomic, strong) NSString *uploadfileName;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *finish_localImgaddress; //本地保存图片地址
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *time; //时长
@property (nonatomic, strong) NSString *start_time;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSNumber *activityId;
@property (nonatomic) NSInteger uploadState; //0未同步  1正在同步 2已同步
@property (nonatomic) long filesize;



@property (nonatomic, assign) BOOL Select;
@property (nonatomic, strong) AVURLAsset *asset;

@property int isCrossScreen; // 1:横屏 2:竖屏
@property double clipStartTime; //被裁减的片段显示图片

/*
 短视频编辑后是否删除文件释放内存
 */
@property BOOL deleteEndEdict;

/*
 根据地址初始化录像对象
 */

+(RecordData*)getVideoByAddress:(NSString*)address;

-(void)setImageView:(UIImageView*)img;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
-(void)saveImageAddress;

-(double)getMovieScale;

-(BOOL)isImage;
-(UIImage*)getImage;
-(NSString *) compareCurrentTime:(NSTimeInterval) timeInterval;

-(NSInteger)canEdict;
@end

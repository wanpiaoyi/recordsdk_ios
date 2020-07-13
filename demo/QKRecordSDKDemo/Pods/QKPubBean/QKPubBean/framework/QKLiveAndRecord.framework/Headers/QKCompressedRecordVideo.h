//
//  QKCompressedRecordVideo.h
//  QkPushVideo
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

//NS_ENUM，码率参数
typedef NS_ENUM(NSUInteger, CompressBitRate) {
    qkCompressBitRate1100 = 1,  //码率  1100KBPS
    qkCompressBitRate1200 = 2,  //码率  1200KBPS
    qkCompressBitRate1300 = 3,  //码率  1300KBPS
    qkCompressBitRate1400 = 4,  //码率  1400KBPS
    qkCompressBitRate1500 = 5,  //码率  1500KBPS
    qkCompressBitRate1600 = 6,  //码率  1600KBPS
    qkCompressBitRate1700 = 7,  //码率  1700KBPS
    qkCompressBitRate1800 = 8,  //码率  1800KBPS
    qkCompressBitRate1900 = 9,  //码率  1900KBPS
    qkCompressBitRate2000 = 10,  //码率  2000KBPS
    qkCompressBitRate2100 = 11,  //码率  2100KBPS
    qkCompressBitRate2200 = 12,  //码率  2200KBPS
    qkCompressBitRate2300 = 13,  //码率  2300KBPS
    qkCompressBitRate2400 = 14,  //码率  2400KBPS
    qkCompressBitRate2500 = 15,  //码率  2500KBPS
    qkCompressBitRate2600 = 16,  //码率  2600KBPS
    qkCompressBitRate2700 = 17,  //码率  2700KBPS
    qkCompressBitRate2800 = 18,  //码率  2800KBPS
    qkCompressBitRate2900 = 19,  //码率  2900KBPS
    qkCompressBitRate3000 = 20,  //码率  3000KBPS
    qkCompressBitRate3100 = 21,  //码率  3100KBPS
    qkCompressBitRate3200 = 22,  //码率  3200KBPS
    qkCompressBitRate3300 = 23,  //码率  3300KBPS
    qkCompressBitRate3400 = 24,  //码率  3400KBPS
    qkCompressBitRate3500 = 25,  //码率  3500KBPS
    qkCompressBitRate3600 = 26,  //码率  3600KBPS
    qkCompressBitRate3700 = 27,  //码率  3700KBPS
    qkCompressBitRate3800 = 28,  //码率  3800KBPS
    qkCompressBitRate3900 = 29,  //码率  3900KBPS
    qkCompressBitRate4000 = 30,  //码率  4000KBPS
};

//NS_ENUM，用户手动取消
typedef NS_ENUM(NSUInteger, CancelCompress) {
    CancelCompressNormal, //取消的成功
    CancelCompressError   //您没有设置appkey，并没有取消的权限
    
};

//NS_ENUM，压缩的错误或完成状态
typedef NS_ENUM(NSUInteger, CompressState) {
    CompressStart,  //开始压缩文件

    CompressAnOther,  //正在压缩另一个文件
    CompressEnding,  //上次转码正在关闭中

    CompressFinish,  //压缩完成
    CompressUserCancel,//用户取消
    CompressError,//压缩失败
    CompressAppkeyError    //Appkey没有设置成功
};
//获取压缩后的文件名,[NSString] compressName压缩后的文件名
typedef void (^getCompressFilename)(NSString *compressName);

/*
 2.	获取文件的压缩进度
 [NSString] compressName压缩后的文件名，用于匹配正在压缩的文件
 [double] progress 文件的压缩进度，为百分数 0 – 100之间
 */
typedef void (^getCompress)(NSString *compressName , double progress);

/*
  文件压缩完成或者错误状态
 [NSString] compressName压缩后的文件名，用于匹配正在压缩的文件
 [NSError] error,若有错误信息则显示在这
 [CompressState]state 错误状态
 */
typedef void (^CompressStateSign)(NSString *compressName , CompressState state,NSError *error);


@interface QKCompressedRecordVideo : NSObject

/*
 [AVURLAsset] avasset:需要被压缩的视频
 [getCompress] progress:视频压缩的进度
 [CompressStateSign] finishstate:视频状态返回
 [getCompressFilename] getname:获取压缩的视频的文件名
 */

+(void)decodeAsset:(AVURLAsset *)avasset getCompress:(getCompress)progress finish:(CompressStateSign)finishstate getName:(getCompressFilename)getname;

/*
 设置视频压缩后对应的分辨率，如果不设置，则默认使用源视频分辨率
 注：视频最好等比例压缩，视频的宽度和高度要为16的整数倍数，不然有可能会出现绿边的情况。压缩的分辨率最好小于或等于原视频分辨率
 例：iphone6 拍摄的视频 分辨率为 1920*1080的，那么该视频可以被压缩的分辨率选择为：1280x720 1024x576 768x432 512x288 等，高宽皆为16的倍数，并且高宽比皆为16：9
 */
+(void)changeFrame:(NSInteger)width height:(NSInteger)height;

//设置视频压缩的码率
+(void)changeBitRate:(CompressBitRate)bitrate;

//取消压缩
+(CancelCompress)cancelCompress:(NSString*)filename;

@end

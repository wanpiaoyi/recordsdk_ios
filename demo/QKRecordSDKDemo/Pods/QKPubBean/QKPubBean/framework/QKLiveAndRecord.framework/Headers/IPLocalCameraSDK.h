//
//  IPLocalCameraSDK.h
//  IPLocalCameraSDK
//
//  Created by wang macmini on 14-10-1.
//  Copyright (c) 2014年 ReNew. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*
 结束当前录播片段的时候的回调
 NSString *filename 文件片段的名称，名称的规则是:yyyyMMddHHmmss_第几个片段.mp4,例如：20161220141516_2.mp4 这表示的是2016年12月20日14点15分16秒开始录制录播的，第二个片段。
 Type：文件类型，目前只有localvideo一种。
 
 */
typedef void (^getFileEndRecord)(NSString *filename,NSInteger filetime,NSString *type);
/*
 拍照完成后的block回调，
 返回img_address 图片完整路径，
 img_name 图片名称，
 img 图片数据
 
 */
typedef void (^getImgAddress)(NSString *img_address,NSString *img_name,NSData *img);
typedef NS_ENUM(NSUInteger, HttpState) {
    HttpSuccess,
    HttpError
};
enum kLocalIPCameraOutputType{
    kLocalIPCameraOutputType16x9 = 0,
    kLocalIPCameraOutputType4x3 = 1,
    kLocalIPCameraOutputType1x1 = 2
};
enum kLocalIPCameraEncodeType {
    kLocalIPCameraEncodeType352x288,
    kLocalIPCameraEncodeType640x480,
    kLocalIPCameraEncodeType1280x720,
    kLocalIPCameraEncodeType1920x1080,
    kLocalIPCameraEncodeType3840x2160,
    kLocalIPCameraEncodeType512x288,
    kLocalIPCameraEncodeType768x432,
    kLocalIPCameraEncodeType1024x576,
    kLocalIPCameraEncodeType640x360
};

enum kLocalBitRate{
    kLocalBitRate1100 = 1,  //码率  1100KBPS
    kLocalBitRate1200 = 2,  //码率  1200KBPS
    kLocalBitRate1300 = 3,  //码率  1300KBPS
    kLocalBitRate1400 = 4,  //码率  1400KBPS
    kLocalBitRate1500 = 5,  //码率  1500KBPS
    kLocalBitRate1600 = 6,  //码率  1600KBPS
    kLocalBitRate1700 = 7,  //码率  1700KBPS
    kLocalBitRate1800 = 8,  //码率  1800KBPS
    kLocalBitRate1900 = 9,  //码率  1900KBPS
    kLocalBitRate2000 = 10,  //码率  2000KBPS
    kLocalBitRate2100 = 11,  //码率  2100KBPS
    kLocalBitRate2200 = 12,  //码率  2200KBPS
    kLocalBitRate2300 = 13,  //码率  2300KBPS
    kLocalBitRate2400 = 14,  //码率  2400KBPS
    kLocalBitRate2500 = 15,  //码率  2500KBPS
    kLocalBitRate2600 = 16,  //码率  2600KBPS
    kLocalBitRate2700 = 17,  //码率  2700KBPS
    kLocalBitRate2800 = 18,  //码率  2800KBPS
    kLocalBitRate2900 = 19,  //码率  2900KBPS
    kLocalBitRate3000 = 20,  //码率  3000KBPS
    kLocalBitRate3100 = 21,  //码率  3100KBPS
    kLocalBitRate3200 = 22,  //码率  3200KBPS
    kLocalBitRate3300 = 23,  //码率  3300KBPS
    kLocalBitRate3400 = 24,  //码率  3400KBPS
    kLocalBitRate3500 = 25,  //码率  3500KBPS
    kLocalBitRate3600 = 26,  //码率  3600KBPS
    kLocalBitRate3700 = 27,  //码率  3700KBPS
    kLocalBitRate3800 = 28,  //码率  3800KBPS
    kLocalBitRate3900 = 29,  //码率  3900KBPS
    kLocalBitRate4000 = 30,  //码率  4000KBPS
    
};

enum{
    kLocalIPCameraLogoClose = 0,
    kLocalIPCameraLogoOpen = 1
};
enum{
    kIPLocalCameraCloseAudio = 0,
    kIPLocalCameraOpenAudio = 1
};

enum{
    kIPLocalCameraAutoFoucs = 0,
    kIPLocalCameraManulFoucs = 1
};

enum{
    kIPLocalCameraFrontCamera = 0,
    kIPLocalCameraBackCamera = 1
};

enum{
    kIPLocalCameraCloseFlash = 0,
    kIPLocalCameraOpenFlash = 1
};

enum{
    kIPLocalCameraLogoClose = 0,//关闭本地日志文件
    kIPLocalCameraLogoOpen = 1  //打开本地日志文件
};



@interface IPLocalCameraSDK : NSObject

+(NSString*)getVersion;

+(int)initAppkey:(NSString*)appkey;


//设置日志是否生成本地文件。
+(void)initSdkSaveLog:(int)saveLog;

//用户开始摄像头，必须在初始化之后，及录播之前调用，
/*
 [in]view，录播画面所在的页面，self.view;
 [in]videoPath 录像相对路径，可以传@“record"，表示存在record文件夹下，如果不需要录像则nil
 [in]GainValue 声音增益 放大音量 传float 0-1
 [in]Orientation 横拍还是竖排 AVCaptureVideoOrientationPortrait竖排  AVCaptureVideoOrientationLandscapeRight横拍
 [in]Camera 0 前置摄像头 1后置摄像头
 
 */
+(int) startLocalCamera:(UIView *)view Orientation:(AVCaptureVideoOrientation)Orientation Camera:(NSInteger)cameraValue recordPath:(NSString*)recordPath;
+(void)setAppOrientation:(UIInterfaceOrientation)orientation;
+(void)clearLocalUserImage;
//关闭摄像头
+(void) stopLocalCamera;

//该函数用来开启录播，必须要在开启摄像头后调用 -2 ：appkey验证失败 ，-1：已经开始录播了， 0：开启成功
+(int)startLocalRecord;

//关闭录播
+(void)stopLocalRecord;

//设置本地录像视频清晰度
+(void)setLocalCameraEncodeType:(NSInteger)encodeType;
//设置本地录像视频码率，单位KB/s
/*
 在用户调用startLocalCameraNoEncodeType，开启摄像头前，设置视频的码率，如果未设置或者设置错误参数，将默认为kLocalBitRate2000
 */
+(void)setLocalCameraVideoBitRate:(NSInteger)videobitrate;

//闪光灯：0 关闭 1 开启
//YES：关闭或开启闪光灯的操作成功  NO：开启或关闭闪光灯的操作失败
+(BOOL) switchLocalFlash:(int)flashFlag;

//音频开关：0 关闭音频 ， 1 打开音频
+(void) switchLocalAudio :(int) audioType;

//摄像头：0 前置摄像头 ， 1 后置摄像头
//返回值：YES表示支持该类摄像头，NO表示不支持该类摄像头
+(BOOL) switchLocalChangeCamera : (int) cameraValue;

//设置聚焦：0 自动聚焦 ， 1 手动聚焦
//返回值YES：表示支持这种聚焦模式，NO表示不支持
+(BOOL) switchLocalFocusMode : (int) focusType;

//touchPoint 聚焦在当前view的坐标，TouchView当前的view
//手动聚焦的点击点和点击画面
+(void) manualLocalFocus:(CGPoint) touchPoint  TouchView:(UIView *)view;



//摄像头的远近缩放改变后的大小，scale范围1～10 , 该接口作用于ios7.0并且iphone5以上
+(void) zoomLocalOut : (float) scale;


//拍照
+(void) takeLocalPhoto:(getImgAddress)getaddress address:(NSString*)address;

//录播一个分片完成时候调用的，返回分片文件的名称 时间 类型 Type：文件类型，目前只有localvideo一种。
+(void)getFileEndRecord:(getFileEndRecord)endrecord ;

//修改录像片段的时长，单位秒
+(void)changePartTime:(NSInteger)partTime;



+(NSInteger)cameraIsRecord;
//设置画幅比 0 16：9，1 4：3， 2 1：1
+(void)changeRenderOutPut:(int)type;
//设置防抖
+(void)setStabilization:(BOOL)stabilization;
//修改倍速
+(BOOL)changeSpeed:(double)speed;
//检查是否支持某种分辨率
+(BOOL)checkEncodeType:(int)type font:(BOOL)font;

//mp3转PCM
+ (int)changeMp3ToPcm:(NSString *)audioPath1
               toFile:(NSString *)outputPath;


@end

//
//  IPCameraSDK.h
//  IPCameraSDK
//
//  Created by wang macmini on 14-10-1.
//  Copyright (c) 2014年 ReNew. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^getFileEndRecord)(NSString *filename,NSInteger filetime,NSString *type);
typedef void (^getFileStartRecord)(NSString *filename,NSString *type);
typedef void (^getImgAddress)(NSString *img_address,NSString *img_name,NSData *img);
typedef void (^getVideoProgress)(double time,BOOL replay);

typedef void (^getAudioChange)(double audioPower);

//视频质量encodeType对应的值
enum {
    kIPCameraFormatType25 = 25,  //视频352*288  比特率200kbps
    kIPCameraFormatType37 = 37,  //视频352*288  比特率300kbps
    kIPCameraFormatType62 = 62,  //视频640*480  比特率500kbps
    kIPCameraFormatType93 = 93,  //视频640*480  比特率750kbps
    kIPCameraFormatType129 = 129,//视频1280*720 比特率960kbps
    kIPCameraFormatType150 = 150 //视频1280*720 比特率1200kbps
};

enum {
    kIPCameraEncodeType352x288,
    kIPCameraEncodeType640x480,
    kIPCameraEncodeType1280x720,
    kIPCameraEncodeType1920x1080,
    kIPCameraEncodeType3840x2160,
    
    kIPCameraEncodeType512x288,
    kIPCameraEncodeType768x432,
    kIPCameraEncodeType1024x576,
    kIPCameraEncodeType640x360
};

enum {
    kBitRate100 = 1,  //码率  100KBPS
    kBitRate200 = 2,  //码率  200KBPS
    kBitRate300 = 3,  //码率  300KBPS
    kBitRate400 = 4,  //码率  400KBPS
    kBitRate500 = 5,  //码率  500KBPS
    kBitRate600 = 6,  //码率  600KBPS
    kBitRate700 = 7,  //码率  700KBPS
    kBitRate800 = 8,  //码率  800KBPS
    kBitRate900 = 9,  //码率  900KBPS
    kBitRate1000 = 10,  //码率  1000KBPS
    kBitRate1100 = 11,  //码率  1100KBPS
    kBitRate1200 = 12,  //码率  1200KBPS
    kBitRate1300 = 13,  //码率  1300KBPS
    kBitRate1400 = 14,  //码率  1400KBPS
    kBitRate1500 = 15,  //码率  1500KBPS
    kBitRate1600 = 16,  //码率  1600KBPS
    kBitRate1700 = 17,  //码率  1700KBPS
    kBitRate1800 = 18,  //码率  1800KBPS
    kBitRate1900 = 19,  //码率  1900KBPS
    kBitRate2000 = 20,  //码率  2000KBPS
    
};


enum{
    kIPCameraCloseAudio = 0,
    kIPCameraOpenAudio = 1
};

enum{
    kIPCameraAutoFoucs = 0,
    kIPCameraManulFoucs = 1
};

enum{
    kIPCameraFrontCamera = 0,
    kIPCameraBackCamera = 1
};

enum{
    kIPCameraCloseFlash = 0,
    kIPCameraOpenFlash = 1
};

enum{
    kIPCameraLogoClose = 0,//关闭本地日志文件
    kIPCameraLogoOpen = 1  //打开本地日志文件
};

enum{
    kImageLeftOffset = 0,
    kImageRightOffset = 1,
    kImageLeftBottomOffset = 2,
    kImageRightBottomOffset = 3
};

enum RCP2PCtrlType
{
    EMRC_RTMP_DICONNECT, //RTMP无法连接对端
    EMRC_RTMP_CONNECT, //RTMP连接成功
    EMRC_RTMP_RECONNECT, //RTMP重连成功
    
    EMRC_APPKEY_UNKNOW,  //APPKEY是无效的
    EMRC_APPKEY_UNCHECK, //APPKEY验证未能正常进行，常为网络不佳情况导致
    EMRC_NOAPPKEY,        //未上传APPKEY
    EMRC_URLERROR,       //地址不合法
    EMRC_APPKEY_HTTPUNKNOW,  //APPKEY验证时候网络不给力
    
    
    EMRC_VIDEO_PACKET, //打包
    SocketLive_DisConnect //断开链接
    
    
};

@protocol IPCameraSDKSupport <NSObject>

@required
//参数
//type 返回类型
//error 错误字符串
//直播不会结束，需要用户自己结束
-(void)IPCameraSDKSupportFun:(UInt16)type ErrorString:(NSString*) error;
@end

@interface IPCameraSDK : NSObject

+(NSString*)getVersion;

+(void)initSDKDelegate:(id)delegate;
+(int)initAppkey:(NSString*)appkey;





+(void)initSdkSaveLog:(int)saveLog;
+(void) cleanupDelegate;

//开启摄像头，view为直播画面显示画面
//encodeType 视频质量，参数对应enum中得值
//videoPath 录像相对路径，可以传@"record"，表示存在record文件夹下，如果不需要录像则nil
//返回，0表示成功，-1表示失败

//GainValue 声音增益 放大音量 传float 0-1
//Camera 0 前置摄像头 1后置摄像头
//Orientation 横拍还是竖排 AVCaptureVideoOrientationPortrait竖排  AVCaptureVideoOrientationLandscapeRight横拍
+(int) startCamera : (UIView *)view streamType:(int) encodeType VideoPath:(NSString*) videoPath GainValue:(float)gain_value Orientation:(AVCaptureVideoOrientation)Orientation Camera:(NSInteger)cameraValue;


+(void)setRecordPath:(NSString*) videoPath;

+(int) startCameraNoEncodeType:(UIView *)view VideoPath:(NSString*) videoPath GainValue:(float)gain_value  Camera:(NSInteger)cameraValue;
//是否开启直播
+(NSInteger)cameraIsRecord;


//设置设备的方向，目前支持：竖屏 UIInterfaceOrientationPortrait，横屏 UIInterfaceOrientationLandscapeRight
+(void)setAppOrientation:(UIInterfaceOrientation)orientation;


//设置帧率 10-30,返回bool  yes设置成功 ，NO设置失败
+(BOOL)setVideoFrame:(int)videoframe;


//设置视频清晰度
+(BOOL)setCameraEncodeType:(NSInteger)encodeType;
//设置视频码率，单位KB/s
+(BOOL)setCameraVideoBitRate:(NSInteger)videobitrate;
//获取直播总流量消耗
+(double)getAllFlow;
//获取直播前一秒流量消耗
+(double)getNowFlow;

//rtmp的重连的时间，单位毫秒
+(void)setRtmpReConnectTime:(int)iTime;

//清空总流量消耗统计
+(void)clearAllFlow;

//关闭摄像头
+(void) stopCamera;

//开启rtmp发送 需要传入rtmp的地址 0正常 -1 启动非正常 -2APPKEY验证未能正常进行，常为网络不佳情况导致 -3 地址不和法或者云端地址配置错误 -4 APPKey是无效的
+(int) startRtmp :(NSString *)rtmp_server_address;
+(void) startJustAac :(NSString *)rtmp_aac_address;
+(void) stopJustAac;


+(void)changeUserName:(NSString*)userName;
+(void)getPcMsg:(void (^)(NSString *msg))getPcMsg;
// -1 未连接， 0:导播台未接收推流  1:推流成功
+(NSInteger)getSocketPushState;
+(void)startFindDevice;
+(int) startSocketPush;
+(void)stopSocketPush;
+(void)stopFindDevice;


//关闭rtmp发送
+(void) stopRtmp;
//结束录像
+(BOOL) stopRecord;

+(void)autoBackgroundStopRtmp:(BOOL)value;

//添加logo type字段png或者其他，其中png的时候我们程序不会给图片设置透明度，其他类型图片的时候程序会给设置0.8的透明度 offset目前支持kImageLeftOffset和kImageRightOffset
+(void)setUserImage:(UIImage*)logoimg Transparent:(int)transparent Offset:(int) offset;
//清空所有logo
+(void)clearUserImage;



//网络发送队列的情况
+(int)  getNetPercent;
+(int)  getNetPercentEx;

+(uint64_t)  getStartTime;
+(uint64_t)  getNowTime;

//闪光灯：0 关闭 1 开启
//YES：关闭或开启闪光灯的操作成功  NO：开启或关闭闪光灯的操作失败
+(BOOL) switchFlash:(int)flashFlag;

//音频开关：0 关闭音频 ， 1 打开音频
+(void) switchAudio :(int) audioType;

+(void) switchMirror : (BOOL) open;

//摄像头：0 前置摄像头 ， 1 后置摄像头
//返回值：YES表示支持该类摄像头，NO表示不支持该类摄像头
+(BOOL) switchChangeCamera : (int) cameraValue;

//设置聚焦：0 自动聚焦 ， 1 手动聚焦
//返回值YES：表示支持这种聚焦模式，NO表示不支持
+(BOOL) switchFocusMode : (int) focusType;

//touchPoint 聚焦在当前view的坐标，TouchView当前的view
//手动聚焦的点击点和点击画面
+(void) manualFocus:(CGPoint) touchPoint  TouchView:(UIView *)view;


+(void) manualOneLockedFoucs:(CGPoint) touchPoint  TouchView:(UIView *)view;


//摄像头的远近缩放改变后的大小，scale范围1～10 , 该接口作用于ios7.0并且iphone5以上
+(void) zoomOut : (float) scale;

//GainValue 声音增益 放大音量 传float 0-1
+(void) changeGainValue : (float)gain_value;
+(void) takelivePhoto:(getImgAddress)getaddress  address:(NSString*)address;
//设置背景声音
+(NSInteger) playBackgroundAudio:(NSString*)mp3_path progress:(getVideoProgress)progress;
//关闭背景声音
+(BOOL) stopBackgroundAudio;
+(BOOL) changeMusicAudio:(float)value;


+(void)getFileStartAndEndRecord:(getFileEndRecord)endrecord start:(getFileStartRecord)startrecord;

//开启美颜效果，在iphone5s以上机器使用
//返回： 0 表示成功 ， －1 表示无美颜功能权限 , -2 表示机器不支持该功能
+(int) setEffect:(BOOL) value;
+(void)useMuting:(BOOL)useMut;

+(void)setAudioChange:(getAudioChange)audiochange;

//添加cg字幕图片
+(void)setNewCg:(UIImage*)img;
+(void)setNewLivePhoto:(UIImage*)img;
+ (BOOL)getCurrentDeviceModelIsIphone4;
+ (BOOL)getCurrentDeviceModelIsIphone6;

//设置蓝牙配置
+ (BOOL)userBluetooth:(BOOL)use;
@end

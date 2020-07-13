//
//  SrtSdk.h
//  IPCameraSDK
//
//  Created by yangpeng on 2020/2/12.
//  Copyright © 2020 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger,SrtCode){
    SrtCode_None = 0,         //普通消息
    SrtCode_ReconnectFailed,  //重连失败
    SrtCode_PktLoss,          //长时间丢包
    SrtCode_PktLossMax,
};

@interface SrtSdk : NSObject


+(void)connect:(NSString*)ip port:(int)port;
+(void)connectServer:(NSString*)ip port:(int)port;

+(void)changeUserName:(NSString*)userName;

+(void)getPcMsg:(void (^)(NSString *msg,SrtCode code))getPcMsg;

// -1 未连接， 0:导播台未接收推流  1:推流成功
+(NSInteger)getSocketPushState;

+(int) startSocketPush;
+(int) startServerSocketPush;

+(void)stopSocketPush;
+(void)stopConnect;
+(double)checkLoss;

@end


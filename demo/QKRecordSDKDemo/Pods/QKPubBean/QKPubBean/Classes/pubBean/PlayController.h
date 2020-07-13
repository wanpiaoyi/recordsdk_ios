//
//  PlayController.h
//  QukanTool
//
//  Created by yang on 2017/12/26.
//  Copyright © 2017年 yang. All rights reserved.
//

typedef NS_ENUM(NSUInteger, PlayerControl){
    PlayerControlPlay = 1,  //播放
    PlayerControlPause = 2,  //暂停
    PlayerControlSeek = 3,  //跳转到指定时间
    PlayerControlStop = 4,  //结束播放器
    PlayerControlDel = 5,    //视频删除
    PlayerControlClip = 6,   //视频裁剪了
    PlayerControlMove = 7,   //视频位置发生改变
    PlayerControlAdd = 8,    //新增视频
    PlayerControlTransferChange = 9,    //更改了字幕的动画
    PlayerControlSpeedChange = 10   //更改了速度
};

typedef NS_ENUM(NSUInteger, AudioChange){
    AudioChangeOrgValue = 1,  //修改原视频音量
    AudioChangeBackValue = 2,  //修改背景音音量
    AudioChangeBackPath = 3,  //修改新的背景音
    AudioChangeRecordValue = 4,  //修改配音音量
    AudioChangeRecordPath= 5  //修改或者刷新配音地址
};


typedef NS_ENUM(NSUInteger, CloseViewType){
    CloseViewTypeNormal = 1,
    CloseViewTypeDelete = 2,
    CloseViewTypeTimeChanges = 3,
    CloseViewTypeCut = 4
};

typedef void (^StartShowMovies)(NSArray *array,BOOL showPlayBottom);
//控制主界面的播放器
typedef void (^ChangePlayerControl)(PlayerControl state,double time);
//控制播放器音频
typedef void (^ChangeAudioControl)(AudioChange state,double value,NSString *path);

typedef void (^closeEdictView)(CloseViewType type);


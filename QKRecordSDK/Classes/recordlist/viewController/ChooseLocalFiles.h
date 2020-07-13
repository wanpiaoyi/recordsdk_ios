//
//  ChooseLocalFiles.h
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectVideoByType.h"
#import "BaseViewController.h"

typedef void (^BlcSelectLocalVideos)(NSArray *array);

@interface ChooseLocalFiles : BaseViewController

/*
 选择视频文件
 */
@property(copy,nonatomic) BlcSelectLocalVideos selectVideos;


@property BOOL justOne;

/*
 显示直播文件
 */
@property BOOL showLive;
/*
显示录像文件
*/
@property BOOL showRecord;
/*
显示裁剪文件
*/
@property BOOL showClip;


@end

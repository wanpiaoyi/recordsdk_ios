//
//  QKClipController.h
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKMoviePartDrafts.h"
#import "BaseViewController.h"
#import "QKVideoBean.h"


@interface QKClipController : BaseViewController

/*
 视频列表进行短视频编辑
 创建QKVideoBean
 fileState = selectFromPhotoVideo; //视频
 fileState = selectFromPhotoImg; //图片
 QKVideoBean *bean = [QKVideoBean getVideoByAddress:address];
 bean.type = fileState;
 
 */
-(id)init:(NSMutableArray<QKVideoBean*>*)array;

/*
 草稿还原成短视频编辑
 */
-(id)initWithDrafts:(QKMoviePartDrafts*)movieDrafts;

/*
 短视频生成后存储本地的文件,默认为 NO
 如果设置为YES，则会存储本地文件,并返回
 [clipPubthings setCompleteUrl:^(NSString *path) {
     NSLog(@"生成的本地文件:%@",path);
 }];
 */
@property(nonatomic) BOOL saveLocalVideo;


//获取视频片段
-(NSArray*)getMovieParts;


@end

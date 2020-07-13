//
//  MovieChooseTransfer.h
//  QukanTool
//
//  Created by yang on 2017/12/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKMoviePart.h"
#import "MovieTransfer.h"
#import "PlayController.h"

/*
 
 state:0 应用当前选中的  1:应用全部
 type:转场动画：0 没有动画  1:左侧划入 2右侧划入 3:淡出
 
 */
typedef void (^chooseTransfer)(NSInteger state,MovieTransfer *transfer,double startTime);


@interface MovieChooseTransfer : UIView

@property(copy,nonatomic) chooseTransfer choose;
@property(copy,nonatomic) closeEdictView close;

//添加一个选中的视频片段
-(void)setMoviePart:(QKMoviePart *)moviePart;


@end

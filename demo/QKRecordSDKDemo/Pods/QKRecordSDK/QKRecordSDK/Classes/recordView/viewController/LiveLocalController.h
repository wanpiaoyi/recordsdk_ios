//
//  LiveLocalController.h
//  QukanTool
//
//  Created by yang on 2018/7/4.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
enum changeState{
    changeLocalStateHidden = 0,
    changeLocalStateShow = 1,
    changeLocalStateClose = 2

};

typedef void (^changeLocalState)(enum changeState state);
@interface LiveLocalController : UIViewController

/*
 是否保留本地视频
 */
@property BOOL saveLocalRecord;
/*
 录制视频是否直接保存到相册
 */
@property BOOL saveToPhoto;
-(void)changeCameraFrame;

@end

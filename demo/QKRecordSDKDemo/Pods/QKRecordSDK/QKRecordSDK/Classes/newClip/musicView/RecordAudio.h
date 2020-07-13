//
//  RecordAudio.h
//  QukanTool
//
//  Created by yang on 2017/12/11.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>



@class RecordInfoController;

@interface RecordAudio : NSObject


-(instancetype)init:(RecordInfoController*)control;
/*修改总时长
 allTime:录制文件总时长，应该与视频总时长一致
 */
-(void)changeAllTime:(double)allTime;
/*准备开始录音
 startTime:录音文件要去替换的时间
 */
-(void)startRecord:(double)startTime;
-(void)startBegin;

/*暂停录音
 用户home键的时候，该方法会自动触发，停止录音并且回调recordEndCall
 */
-(void)pauseRecord;
//结束录音
-(void)endRecord;




@end


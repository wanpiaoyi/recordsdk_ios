//
//  QKVideoBean.h
//  QukanTool
//
//  Created by yang on 17/1/7.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordData.h"

@interface QKVideoBean : RecordData

/*
 创建QKVideoBean
 fileState = selectFromPhotoVideo; //视频
 fileState = selectFromPhotoImg; //图片
 NSString *address = @“localvideo/temp_2019103011432555407240_1.mp4”

 address:Document文件下的路径地址。例如视频完整路径为：
 @“/var/mobile/Containers/Data/Application/49AA453F-A7E8-46AE-B1F6-30307F810624/Documents/localvideo/temp_2019103011432555407240_1.mp4”
 address应该填写为：@“localvideo/temp_2019103011432555407240_1.mp4”

 QKVideoBean *bean = [QKVideoBean getVideoByAddress:address];
 bean.type = fileState;
 
 address：视频在document目录下的地址
 */
+(QKVideoBean*)getVideoByAddress:(NSString*)address;

/*
短视频编辑结束后，是否删除源文件释放内存:YES:删除文件，NO：不删除文件。默认为YES
*/
-(void)setDeleteEndEdict:(BOOL)deleteEndEdict;
@end

//
//  QKMoviePartDrafts.h
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface QKMoviePartDrafts : NSObject

@property(strong,nonatomic) NSNumber *part_id;
@property(strong,nonatomic) NSDictionary *dict_save;
@property(copy,nonatomic) NSString *img_address;
@property(copy,nonatomic) NSString *change_time; //最后编辑时间
@property(copy,nonatomic) NSString *part_name; //展示的名称
@property(strong,nonatomic) NSString *musicPath;
@property(copy,nonatomic) NSString *recordPath;
@property float orgVoice;
@property float backVoice;
@property float recordVoice;

@property NSInteger during;


@property BOOL isBroken; //文件是否已损坏
@property BOOL checked; //草稿是否检查过


/*
刷新最后编辑时间
*/
-(void)changeNewChangeTime;
-(NSString*)getDuringTime;

/*
 删除所有文件
 */
-(void)deleteAllFiles;
/*
 检查草稿是否已损坏
 */
-(BOOL)checkBroken;
@end

//
//  QKAudioBean.h
//  QukanTool
//
//  Created by yang on 2017/12/22.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface QKAudioBean : NSObject

@property double orgVale;
@property double backVale;
@property double recordVale;
@property (copy,nonatomic) NSString *recordPath;
@property (strong,nonatomic) NSString *backMusic;
-(NSString *)getSaveRecordPath;
@end

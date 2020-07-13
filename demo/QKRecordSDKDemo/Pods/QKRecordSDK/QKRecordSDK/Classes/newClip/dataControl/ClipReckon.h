//
//  ClipReckon.h
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieClipDataBase.h"

@interface ClipReckon : NSObject
//计算播放器界面的大小
+(CGRect)reckonRect:(CGSize)superBoundSize drawType:(DrawType)type;
@end

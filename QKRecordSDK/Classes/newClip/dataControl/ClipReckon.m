//
//  ClipReckon.m
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ClipReckon.h"

@implementation ClipReckon

+(CGRect)reckonRect:(CGSize)superBoundSize drawType:(DrawType)type{
    double scale = 0;
    switch (type) {
        case DrawType1x1:
            scale = 1;
            break;
        case DrawType4x3:
            scale = 4.0/3;
            break;
        case DrawType3x4:
            scale = 3.0/4;
            break;
        case DrawType16x9:
            scale = 16.0/9;
            break;
        case DrawType9x16:
            scale = 9.0/16;
            break;
        default:
            break;
    }
    float width = superBoundSize.width;
    float height = superBoundSize.height;
    
    float fitheight = width / scale;
    
    float fitWidth = height * scale;
    if(fitheight < height){
        return CGRectMake(0, (height - fitheight) / 2, width, fitheight);
    }
    
    return CGRectMake((width - fitWidth)/ 2, 0,fitWidth , height);
}

@end

//
//  ChangeImageSize.h
//  QukanTool
//
//  Created by yang on 2019/1/26.
//  Copyright © 2019 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKImageChangeBean.h"

@interface ChangeImageSize : UIView
typedef NS_ENUM(NSUInteger, ImageChange){
    ImageChangeScale = 1,  //修改大小
    ImageChangeDuring = 2,  //修改时间
    ImageChangeStartTime = 3 //修改开始时间
};

typedef void (^changeImageValue)(ImageChange state,QKImageChangeBean *bean);

@property(copy,nonatomic)changeImageValue getImage;


-(id)init:(double)scale during:(double)during startTime:(double)startTime;

@end

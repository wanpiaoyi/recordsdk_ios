//
//  ChangeTextView.h
//  QukanTool
//
//  Created by yang on 17/6/19.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKTextChangeBean.h"
typedef NS_ENUM(NSUInteger, TextChange){
    TextChangeText = 1,  //修改文字
    TextChangeColor = 2,  //修改颜色
    TextChangeSize = 3,  //修改文字大小
    TextChangeAlpha = 4,  //修改透明度
    TextChangeDuring = 5,  //修改时间
    TextChangeStartTime = 6 //修改开始时间

};
typedef void (^changeTextValue)(TextChange state,QKTextChangeBean *bean);
@interface ChangeTextView : UIView

@property(copy,nonatomic)changeTextValue getText;



-(id)init:(NSString*)text color:(NSString*)color fontSize:(NSInteger)fontSize during:(double)during startTime:(double)startTime;
-(void)changeBackColor:(UIColor*)color;
@end

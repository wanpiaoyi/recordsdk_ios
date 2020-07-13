//
//  RawSpeedChoose.h
//  QukanTool
//
//  Created by yang on 2018/6/19.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^changeSpeedType)(int speedType);
@interface RawSpeedChoose : UIView
@property(copy,nonatomic) changeSpeedType changeSpeed;
@property BOOL canChangeSpeed;
-(void)showNowSpeed:(int)speedType;
@end

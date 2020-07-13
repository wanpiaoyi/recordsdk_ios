//
//  ChangeFilterColor.h
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayController.h"
#import "QKColorFilterGroup.h"

typedef void (^ColorChanged)(QKColorFilterGroup *group);

@interface ChangeFilterColor : UIView
@property(copy,nonatomic) closeEdictView closeView;
@property(copy,nonatomic)  ColorChanged change;

-(id)initWithFrame:(CGRect)frame group:(QKColorFilterGroup*)group;

@end

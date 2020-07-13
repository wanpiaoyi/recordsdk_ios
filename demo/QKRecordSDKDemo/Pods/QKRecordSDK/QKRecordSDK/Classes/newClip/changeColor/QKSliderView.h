//
//  QKSilderView.h
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^getSliderValue)(double valueChanged);
@interface QKSliderView : UIView

@property(copy,nonatomic) getSliderValue getValue;

@property(nonatomic) double minValue;
@property(nonatomic) double maxValue;
@property(nonatomic) double sliderValue;

@end


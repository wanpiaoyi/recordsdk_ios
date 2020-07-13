//
//  MovieView.h
//  QukanTool
//
//  Created by yang on 2017/9/30.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ViewFrameChanged)(CGRect rect);
@interface MovieView : UIView

@property (copy,nonatomic) ViewFrameChanged frameChanged;
@property BOOL canMove;

@end

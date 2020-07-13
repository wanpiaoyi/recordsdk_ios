//
//  FilterChooseView.h
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FilterChooseView : UIView

-(int)selectBeforeFilter;
-(int)selectNextFilter;
-(void)showFilterType:(int)fileType;

@end

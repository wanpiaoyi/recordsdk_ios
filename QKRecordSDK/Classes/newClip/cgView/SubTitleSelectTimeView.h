//
//  SubTitleSelectTimeView.h
//  QukanTool
//
//  Created by yang on 2018/1/2.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubTitleSelectTimeView : UIView
@property double startTime;
@property double endTime;

-(id)initWithFrame:(CGRect)frame;

-(void)setIsSelect:(BOOL)select;
-(void)setText:(NSString*)text;
@end

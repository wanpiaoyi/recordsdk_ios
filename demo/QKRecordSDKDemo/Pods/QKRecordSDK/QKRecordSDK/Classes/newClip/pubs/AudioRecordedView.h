//
//  AudioRecordedView.h
//  QukanTool
//
//  Created by yang on 2017/12/20.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioRecordedView;
typedef void (^selectRecordView)(AudioRecordedView *recordView);

@interface AudioRecordedView : UIView

@property double startTime;
@property double endTime;
@property(copy,nonatomic) selectRecordView selectRecord;

-(id)initWithFrame:(CGRect)frame;

-(void)setIsSelect:(BOOL)select;

@end

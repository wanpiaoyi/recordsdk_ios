//
//  AudioRecordedView.m
//  QukanTool
//
//  Created by yang on 2017/12/20.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "AudioRecordedView.h"
#define selectColor [UIColor redColor]
#define unSelectColor [UIColor colorWithRed:115/255.0 green:163/255.0 blue:255/255.0 alpha:1.0]

#define selectBackColor [UIColor colorWithRed:254/255.0 green:68/255.0 blue:105/200.0 alpha:0.6]
#define unSelectBackColor [UIColor colorWithRed:0/255.0 green:39/255.0 blue:176/255.0 alpha:0.6]

@interface AudioRecordedView()

@property(strong,nonatomic) UILabel *lbl1;
@property(strong,nonatomic) UILabel *lbl2;


@end

@implementation AudioRecordedView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
        lbl1.backgroundColor = unSelectColor;
        
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-1, 0, 1, frame.size.height)];
        lbl2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        lbl2.backgroundColor = unSelectColor;
        [self addSubview:lbl1];
        [self addSubview:lbl2];
        
        self.lbl1 = lbl1;
        self.lbl2 = lbl2;
        self.backgroundColor = unSelectBackColor;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(getSelectRecordView:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = self.bounds;
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:btn];
    }
    return self;
}

-(void)setIsSelect:(BOOL)select{
    if(select){
        self.lbl1.backgroundColor = selectColor;
        self.lbl2.backgroundColor = selectColor;
        self.backgroundColor = selectBackColor;
    }else{
        self.lbl1.backgroundColor = unSelectColor;
        self.lbl2.backgroundColor = unSelectColor;
        self.backgroundColor = unSelectBackColor;
    }
}

-(void)getSelectRecordView:(id)sender{
    if(self.selectRecord){
        self.selectRecord(self);
    }
}

@end

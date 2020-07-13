//
//  SubTitleSelectTimeView.m
//  QukanTool
//
//  Created by yang on 2018/1/2.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "SubTitleSelectTimeView.h"
#import "ClipPubthings.h"

#define unSelectBackColor [UIColor colorWithRed:56.0/255.0 green:159.0/255.0 blue:255/255.0 alpha:1.0];

@interface SubTitleSelectTimeView()

@property(strong,nonatomic) UILabel *lbl_text;

@end
@implementation SubTitleSelectTimeView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = unSelectBackColor;
        self.layer.cornerRadius = 3;
        self.layer.borderWidth = 1;
        self.clipsToBounds = YES;

        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lbl_text = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, qk_screen_width, frame.size.height)];
        self.lbl_text.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.lbl_text];
        self.lbl_text.textColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setText:(NSString*)text{
    self.lbl_text.text = text;
}

@end

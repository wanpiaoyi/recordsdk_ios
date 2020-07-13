//
//  ChooseAudio.h
//  QukanTool
//
//  Created by yang on 2018/1/11.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKMusicBean.h"

typedef void (^chooseOneMusic)(QKMusicBean *music);

@interface ChooseAudio : UIView
@property(strong,nonatomic) QKMusicBean *selectMusic;

@property(copy,nonatomic) chooseOneMusic chooseMusic;
-(instancetype)initWithFrame:(CGRect)frame music:(NSString *)path;
@end

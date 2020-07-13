//
//  QKAudioBean.m
//  QukanTool
//
//  Created by yang on 2017/12/22.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKAudioBean.h"
#import "ClipPubThings.h"

@implementation QKAudioBean

-(NSString *)getSaveRecordPath{
    return [self.recordPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",clipPubthings.pressfixPath] withString:@""];
}

@end

//
//  AudioGet.h
//  QukanTool
//
//  Created by 袁儿宝贝 on 2019/10/29.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKMusicBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewAudios : NSObject
//获取音频
@property(copy,nonatomic) void (^getAudio)(QKMusicBean *bean);

-(void)getNewAudios:(NSMutableDictionary *)dic;
-(NSArray*)getLocalAudios;

@end

NS_ASSUME_NONNULL_END

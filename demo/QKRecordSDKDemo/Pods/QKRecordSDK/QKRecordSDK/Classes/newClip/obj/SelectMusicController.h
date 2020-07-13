//
//  SelectMusicController.h
//  QukanTool
//
//  Created by yangpeng on 2019/11/25.
//  Copyright © 2019 yang. All rights reserved.
//

#import "BaseViewController.h"
#import "QKMusicBean.h"

//typedef  void (^selectMusic)(QKMusicBean *selectmusic);
NS_ASSUME_NONNULL_BEGIN

@interface SelectMusicController : BaseViewController

@property(copy,nonatomic) void (^playMusic)(QKMusicBean *bean);

@end

NS_ASSUME_NONNULL_END

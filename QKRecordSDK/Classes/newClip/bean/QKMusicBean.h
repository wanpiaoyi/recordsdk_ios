//
//  QKMusicBean.h
//  QukanTool
//
//  Created by 袁儿宝贝 on 2019/10/24.
//  Copyright © 2019 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QKMusicBean : NSObject

@property(copy,nonatomic) NSString *name;
//地址必须是document目录下的相对地址
@property(copy,nonatomic) NSString *address;

@end

NS_ASSUME_NONNULL_END

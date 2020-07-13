//
//  GetNowSubtitles.h
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKShowMovieSuntitle.h"

@interface GetNowSubtitles : NSObject

+(NSArray*)getArrays;
+(QKShowMovieSuntitle *)getMovieSub:(NSString*)str;


@end

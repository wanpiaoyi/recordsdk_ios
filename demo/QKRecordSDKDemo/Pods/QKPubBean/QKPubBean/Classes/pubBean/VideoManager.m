//
//  VideoManager.m
//  QukanTool
//
//  Created by yangpeng on 2020/2/19.
//  Copyright © 2020 yang. All rights reserved.
//

#import "VideoManager.h"
#import "QKVideoBean.h"
#import "OSSSqlite.h"

@implementation VideoManager

+(VideoManager *)sharePubThings{
    static dispatch_once_t once;
    static VideoManager *sharedView;
    dispatch_once(&once, ^ {
        
        sharedView = [[VideoManager alloc] init];
        
    });
    return sharedView;
}

-(id)init{
    self = [super init];
    if(self){
        self.liveVideoShow = YES;
        self.recordVideoShow = YES;
        self.clipVideoShow = YES;
    }
    return self;
}

@end

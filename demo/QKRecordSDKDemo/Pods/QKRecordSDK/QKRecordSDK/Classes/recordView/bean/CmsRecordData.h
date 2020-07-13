//
//  CmsRecordData.h
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RecordData.h"

@class AVAsset;
@interface CmsRecordData : RecordData
+(CmsRecordData*)getVideoByAddress:(NSString*)address;
@end

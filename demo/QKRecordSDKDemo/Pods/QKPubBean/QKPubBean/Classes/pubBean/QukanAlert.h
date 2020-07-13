//
//  QukanAlert.h
//  MobileIPC
//
//  Created by chenyu on 13-11-7.
//  Copyright (c) 2013年 ReNew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QukanAlert : UIAlertView
@property (nonatomic, assign) NSInteger orientationFlay;
@property (nonatomic, strong)NSString *content;
-(id)initWithCotent:(NSString*)content Delegate:(NSObject*)object;
+(void)alertMsg:(NSString*)msg;

@end

//
//  NSString+Size.h
//  qukan4
//
//  Created by chenyu on 14-9-30.
//  Copyright (c) 2014年 RenewTOOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString(CheckSize)
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

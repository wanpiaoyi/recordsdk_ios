//
//  QKPlayerImageHelper.h
//  IPCameraSDK
//
//  Created by chenyu on 14/12/1.
//  Copyright (c) 2014年 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface QKPlayerImageHelper : NSObject

+ (char *) convertUIImageToBitmapBGRA8:(UIImage *) image;
/** A helper routine used to convert a RGBA8 to UIImage
 @return a new context that is owned by the caller
 */
+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef)image;


/** Converts a RGBA8 bitmap to a UIImage.
 @param buffer - the RGBA8 unsigned char * bitmap
 @param width - the number of pixels wide
 @param height - the number of pixels tall
 @return a UIImage that is autoreleased or nil if memory allocation issues
 */
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
                                withWidth:(int)width
                               withHeight:(int)height;
@end

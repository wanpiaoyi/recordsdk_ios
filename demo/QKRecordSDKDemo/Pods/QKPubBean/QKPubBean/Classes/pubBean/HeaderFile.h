//
//  HeaderFile.h
//  MobileIPC
//
//  Created by chenyu on 13-9-4.
//  Copyright (c) 2013年 ReNew. All rights reserved.
//

#ifndef MobileIPC_HeaderFile_h
#define MobileIPC_HeaderFile_h

#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height >= 548)
#define IOS_SYSTEM ([[[UIDevice currentDevice] systemVersion] floatValue])
#define pgToast ((PGToastView*)[PGToastView getPgtoast])



#define pressfixPathAddress (NSString*)([NSHomeDirectory() stringByAppendingPathComponent:@"Documents"])
#define AutoSizingMask (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)
#define RenewLog(format,...)      // NSLog(@"{%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)
#define Renew_DEBUG(format,...)    //NSLog(@"[DEBUG] {%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)
#define Renew_INFO(format,...)     NSLog(@"[INFO] {%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)
#define Renew_ERROR(format,...)    //NSLog(@"[ERROR] {%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)
#define Renew_WARNING(format,...)  //NSLog(@"[WARNING] {%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)
#define Renew_TIME(format,...)     //NSLog(@"[TIME] {%s,%d}" format, __FUNCTION__,__LINE__,##__VA_ARGS__)


#ifndef weakify
#if __has_feature(objc_arc)

#define weakify( x ) \\
_Pragma("clang diagnostic push") \\
_Pragma("clang diagnostic ignored \\"-Wshadow\\"") \\
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \\
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \\
_Pragma("clang diagnostic push") \\
_Pragma("clang diagnostic ignored \\"-Wshadow\\"") \\
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \\
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)

#define strongify( x ) \\
_Pragma("clang diagnostic push") \\
_Pragma("clang diagnostic ignored \\"-Wshadow\\"") \\
try{} @finally{} __typeof__(x) x = __weak_##x##__; \\
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \\
_Pragma("clang diagnostic push") \\
_Pragma("clang diagnostic ignored \\"-Wshadow\\"") \\
try{} @finally{} __typeof__(x) x = __block_##x##__; \\
_Pragma("clang diagnostic pop")

#endif
#endif



#define recordpath @"LocalRecord"

#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;
#define qk_screen_width [[UIScreen mainScreen] bounds].size.width
#define qk_screen_height [[UIScreen mainScreen] bounds].size.height


#endif

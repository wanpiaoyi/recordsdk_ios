//
//  SubtitlePreview.h
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ClipPubThings.h"
#define previewheight 57
#define previewWidth (qk_screen_width - 36)/3

@interface SubtitlePreview : NSObject

@property(strong,nonatomic) NSString *text;
@property(strong,nonatomic) UIFont *font;
@property NSInteger font_size;
@property(strong,nonatomic) UIColor *text_color;
@property(strong,nonatomic) NSString *img_name;
@property(strong,nonatomic) NSString *img_address;
@property(strong,nonatomic) UIColor *backgroundColor;
@property CGRect rect;
@property CGRect rect_backGround;
@property NSInteger type; //3:图片 2:文字
@property BOOL addBackground; //3:图片 2:文字

+(SubtitlePreview*)getSubTitlePreview:(NSDictionary*)dict;

@end

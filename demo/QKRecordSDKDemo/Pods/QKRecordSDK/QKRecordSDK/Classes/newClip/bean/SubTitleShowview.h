//
//  SubTitleShowview.h
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define lineBetween 5
#define rightBetween 12
#define controlWidth 375.0
#define controlVerWith 210.0

typedef NS_ENUM(NSUInteger, alignSuntitle){
    alignSuntitleLeft = 1,  //显示在左边
    alignSuntitleRight = 2,//显示在右边
    alignSuntitleCenter = 3//显示在中间
    
};
typedef NS_ENUM(NSUInteger, paddingSuntitle){
//    paddingSuntitleAlign = -1, //参照align处理
    paddingSuntitleLine = 0,  //占用一行
    paddingSuntitleLeft = 1,  //跟在左边
    paddingSuntitleRight = 2,//跟在右边
    paddingSuntitleCenter = 3,  //居中
    paddingSuntitleAll = 4  //整行并填充满
};

@interface SubTitleShowview : NSObject

@property(copy,nonatomic) NSString *text;
@property(strong,nonatomic) UIFont *font;
@property(copy,nonatomic) NSString *font_name;
@property NSInteger font_size;
@property(strong,nonatomic) UIColor *text_color;
@property(strong,nonatomic) NSString *img_name;
@property(strong,nonatomic) UIColor *backgroundColor;
@property(strong,nonatomic) NSArray *array_margin;
@property alignSuntitle align; //1：左 2：右边
@property paddingSuntitle padding; //0：一行 1：左 2：右边
@property CGRect rect;
@property CGRect rect_backGround;
@property CGRect imgRect;
@property NSInteger type; //1:图片 2:文字 3:本地图片，4
@property BOOL addBackground; 
@property double imageScale;


-(void)changeMarginTop:(NSInteger)marginy marginx:(NSInteger)marginx;

+(SubTitleShowview*)getSubTitleShowview:(NSDictionary*)dict;
-(void)changeSubPre:(NSString*)str;
-(void)changeRect:(CGSize)superSize maxWidth:(float)maxWidth;



-(NSDictionary*)getDictionaryByBean;
+(SubTitleShowview *)getSubtitleByBean:(NSDictionary *)dict;
@end

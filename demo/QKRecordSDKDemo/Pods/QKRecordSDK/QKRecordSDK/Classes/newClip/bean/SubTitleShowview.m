//
//  SubTitleShowview.m
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubTitleShowview.h"
#import "NSString+Size.h"


@interface SubTitleShowview()

@property NSInteger addMore;


@property CGSize superSize;
@property float maxWidth;
@property (copy,nonatomic) NSString *str_textColor;
@property (copy,nonatomic) NSString *str_backgroundColor;
@end


@implementation SubTitleShowview

-(id)init{
    if(self = [super init]){
        self.imageScale = 1.0;
        self.imgRect = CGRectZero;
    }
    return self;
}

+(SubTitleShowview*)getSubTitleShowview:(NSDictionary*)dict{
    SubTitleShowview *subpreview = [[SubTitleShowview alloc] init];
    NSNumber *type = dict[@"type"];
    NSString *margin = dict[@"margin"];
    NSNumber *align = dict[@"align"];
    NSNumber *padding = dict[@"padding"];

    NSArray *array_margin = [margin componentsSeparatedByString:@","];
    NSInteger top = [array_margin[0] integerValue];
    NSInteger marginx = 0;
    NSInteger marginy = 0;
    
    subpreview.array_margin = array_margin;
    if(type == nil){
        subpreview.type = 2;
    }else{
        subpreview.type = [type integerValue];
    }
    subpreview.align = [align integerValue];
    subpreview.padding = [padding integerValue];

    
    if(type != nil &&( [type integerValue] == 1 || [type integerValue] == 3 || [type integerValue] == 5)){
        NSString *imgName = dict[@"imgName"];
        NSString *imgSize = dict[@"imgSize"];
        NSArray *array_imgsize = [imgSize componentsSeparatedByString:@","];
        
        if(top > 0){
            marginy = top;
        }
        CGRect rect = CGRectMake(marginx, marginy, [array_imgsize[0] integerValue], [array_imgsize[1] integerValue]);
        subpreview.rect = rect;
        subpreview.img_name = imgName;
        subpreview.rect_backGround = rect;
        subpreview.imgRect = rect;
        return subpreview;
    }
    
    
    NSString *text = dict[@"text"];
    NSString *font_name = dict[@"fontName"];
    NSNumber *font_size = dict[@"fontSize"];
    NSString *text_color = dict[@"textColor"];
    NSString *backgroundColor = dict[@"backgroundColor"];
    subpreview.text = text;
    subpreview.font = [UIFont fontWithName:font_name size:[font_size integerValue]];
    subpreview.font_name = font_name;
    subpreview.font_size = [font_size integerValue];
    subpreview.text_color = [SubTitleShowview getColorFromString:text_color];
    subpreview.backgroundColor = [SubTitleShowview getColorFromString:backgroundColor];
    subpreview.str_textColor = text_color;
    subpreview.str_backgroundColor = backgroundColor;

    if(backgroundColor != nil && ![backgroundColor hasSuffix:@",0"]){
        subpreview.addBackground = YES;
    }else{
        subpreview.addBackground = NO;
    }
    
    return subpreview;
}

+(UIColor*)getColorFromString:(NSString *)backGroundColor{
    if(backGroundColor == nil){
        return [UIColor clearColor];
    }
    NSArray *rgbArray = [backGroundColor componentsSeparatedByString:@","];
    if(rgbArray.count == 4){
        return [UIColor colorWithRed:[rgbArray[0] floatValue] green:[rgbArray[1] floatValue] blue:[rgbArray[2] floatValue] alpha:[rgbArray[3] floatValue]];
    }
    return [UIColor clearColor];
}

-(void)changeSubPre:(NSString*)str{
    self.text = str;
    [self changeRect:self.superSize maxWidth:self.maxWidth];
}

-(void)changeMarginTop:(NSInteger)marginy marginx:(NSInteger)marginx{
    NSInteger addMore = self.addMore;
    CGSize size = self.rect.size;
    float superWidth = 0;
    if(self.superSize.width > self.superSize.height){
        superWidth = self.superSize.width;
    }else{
        superWidth = self.superSize.height;
    }
    float scale = superWidth / controlWidth;

    if(self.type == 1 || self.type == 3){
        CGSize size = self.imgRect.size;

        CGRect rect = CGRectMake(marginx + addMore, marginy, size.width*self.imageScale*scale,size.height*self.imageScale*scale);
        self.rect = rect;
        self.rect_backGround = rect;

        return;
    }
    
    CGRect rect = CGRectMake(marginx + addMore, marginy, size.width ,size.height);
    CGRect  rect_backGround = CGRectMake(marginx, marginy, size.width + addMore * 2,size.height);
    self.rect = rect;
    self.rect_backGround = rect_backGround;
}

-(void)changeRect:(CGSize)superSize maxWidth:(float)maxWidth{
    self.superSize = superSize;
    float superWidth = 0;
    if(superSize.width > superSize.height){
        superWidth = superSize.width;
    }else{
        superWidth = superSize.height;
    }
    
    float scale = superWidth / controlWidth;
    self.maxWidth = maxWidth;
    if(self.type == 1 || self.type == 3){
        CGRect rect = CGRectMake(self.imgRect.origin.x * scale, self.imgRect.origin.y * scale, self.imgRect.size.width *scale*self.imageScale, self.imgRect.size.height *scale*self.imageScale);
        self.rect = rect;
        self.rect_backGround = rect;
        self.addMore = 0;
        return;
    }
    NSString *str = self.text;
    if(str == nil || str.length == 0){
        str = @"   ";
    }
    
    CGSize size = [SubTitleShowview getLblSize: [UIFont fontWithName:self.font_name size:scale*self.font_size] width:maxWidth height:MAXFLOAT str:str];

    NSInteger addMore = 0; //这里主要是文字距离周围的边距
    if(self.addBackground){
        addMore = self.font_size * scale/3;
    }
    NSLog(@"size:%@ maxWidth:%.3lf",NSStringFromCGSize(size),maxWidth);
    float useWidth = size.width + 1;
    
    if(self.align == alignSuntitleCenter&& maxWidth - useWidth<self.font_size){
        useWidth = maxWidth - addMore*2;
    }
    
    CGRect rect = CGRectMake(addMore, 0, useWidth,size.height +1 + addMore * 2);
    
    CGRect  rect_backGround = CGRectMake(0, 0, useWidth + addMore * 2,size.height +1 + addMore * 2);
    self.rect = rect;
    self.rect_backGround = rect_backGround;
    self.addMore = addMore;
}



-(NSDictionary*)getDictionaryByBean{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.array_margin forKey:@"array_margin"];
    [dict setObject:@(self.type) forKey:@"type"];
    [dict setObject:@(self.align) forKey:@"align"];
    [dict setObject:@(self.padding) forKey:@"padding"];
    [dict setObject:[NSString stringWithFormat:@"%.1lf,%.1lf,%.1lf,%.1lf",self.rect.origin.x,self.rect.origin.y,self.rect.size.width,self.rect.size.height] forKey:@"rect"];
    [dict setObject:[NSString stringWithFormat:@"%.1lf,%.1lf,%.1lf,%.1lf",self.rect_backGround.origin.x,self.rect_backGround.origin.y,self.rect_backGround.size.width,self.rect_backGround.size.height] forKey:@"rect_backGround"];

    if(!CGRectEqualToRect(self.imgRect, CGRectZero)){
        [dict setObject:[NSString stringWithFormat:@"%.1lf,%.1lf,%.1lf,%.1lf",self.imgRect.origin.x,self.imgRect.origin.y,self.imgRect.size.width,self.imgRect.size.height] forKey:@"rect_img"];
    }

    [dict setObject:@(self.addBackground) forKey:@"addBackground"];
    [dict setObject:@(self.imageScale) forKey:@"imageScale"];

    if(self.text != nil){
        [dict setObject:self.text forKey:@"text"];
    }
    if(self.font_name != nil){
        [dict setObject:self.font_name forKey:@"fontName"];
    }
    [dict setObject:@(self.font_size) forKey:@"fontSize"];
    
    if(self.img_name != nil){
        [dict setObject:self.img_name forKey:@"imgName"];
    }
    if(self.str_textColor != nil){
        [dict setObject:self.str_textColor forKey:@"textColor"];
    }
    if(self.str_backgroundColor != nil){
        [dict setObject:self.str_backgroundColor forKey:@"backgroundColor"];
    }

    return dict;
}

+(SubTitleShowview *)getSubtitleByBean:(NSDictionary *)dict{
    SubTitleShowview *subpreview = [[SubTitleShowview alloc] init];
    NSNumber *type = dict[@"type"];
    NSArray *array_margin = dict[@"array_margin"];
    NSNumber *align = dict[@"align"];
    NSNumber *padding = dict[@"padding"];
    
    subpreview.array_margin = array_margin;
    if(type == nil){
        subpreview.type = 2;
    }else{
        subpreview.type = [type integerValue];
    }
    subpreview.align = [align integerValue];
    subpreview.padding = [padding integerValue];
    
    NSString *str_rect = dict[@"rect"];
    NSString *str_rectbackground = dict[@"rect_backGround"];
    NSString *str_rectImg = dict[@"rect_img"];
    
    NSArray *array_rect = [str_rect componentsSeparatedByString:@","];
    NSArray *array_rectbackground = [str_rectbackground componentsSeparatedByString:@","];
   
    CGRect rect = CGRectMake([array_rect[0] floatValue], [array_rect[1] floatValue], [array_rect[2] floatValue], [array_rect[3] floatValue]);

    CGRect rect_background = CGRectMake([array_rectbackground[0] floatValue], [array_rectbackground[1] floatValue], [array_rectbackground[2] floatValue], [array_rectbackground[3] floatValue]);
    subpreview.rect = rect;
    subpreview.rect_backGround = rect_background;
    if(str_rectImg != nil){
        NSArray *array_rectImg = [str_rectImg componentsSeparatedByString:@","];
        
        CGRect rectImg = CGRectMake([array_rectImg[0] floatValue], [array_rectImg[1] floatValue], [array_rectImg[2] floatValue], [array_rectImg[3] floatValue]);
        subpreview.imgRect = rectImg;
    }
    
    if(type != nil &&( [type integerValue] == 1 || [type integerValue] == 3)){
        NSString *imgName = dict[@"imgName"];
        subpreview.img_name = imgName;
        return subpreview;
    }
    
    
    NSString *text = dict[@"text"];
    NSString *font_name = dict[@"fontName"];
    NSNumber *font_size = dict[@"fontSize"];
    NSString *text_color = dict[@"textColor"];
    NSString *backgroundColor = dict[@"backgroundColor"];
    subpreview.text = text;
    subpreview.font = [UIFont fontWithName:font_name size:[font_size integerValue]];
    subpreview.font_name = font_name;
    subpreview.font_size = [font_size integerValue];
    subpreview.text_color = [SubTitleShowview getColorFromString:text_color];
    subpreview.backgroundColor = [SubTitleShowview getColorFromString:backgroundColor];
    subpreview.str_textColor = text_color;
    subpreview.str_backgroundColor = backgroundColor;
    
    if(backgroundColor != nil && ![backgroundColor hasSuffix:@",0"]){
        subpreview.addBackground = YES;
    }else{
        subpreview.addBackground = NO;
    }
    NSNumber *imageScale = dict[@"imageScale"];
    if(imageScale != nil){
        subpreview.imageScale = [imageScale doubleValue];
    }else{
        subpreview.imageScale = 1.0;
    }
    
    return subpreview;
}
//计算label高宽
+(CGSize)getLblSize:(UIFont *)font width:(CGFloat)width height:(CGFloat)height str:(NSString*)str{
    CGSize size =[str textSizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}


@end

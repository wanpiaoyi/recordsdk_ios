//
//  SubtitlePreview.m
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubtitlePreview.h"
#import "NSString+Size.h"

@implementation SubtitlePreview


+(SubtitlePreview*)getSubTitlePreview:(NSDictionary*)dict{
    SubtitlePreview *subpreview = [[SubtitlePreview alloc] init];
    NSNumber *type = dict[@"type"];
    NSString *margin = dict[@"margin"];
    NSArray *array_margin = [margin componentsSeparatedByString:@","];
    NSInteger top = [array_margin[0] integerValue];
    NSInteger left = [array_margin[1] integerValue];
    NSInteger bottom = [array_margin[2] integerValue];
    NSInteger right = [array_margin[3] integerValue];
    NSInteger marginx = 0;
    NSInteger marginy = 0;
    
    
    if(type == nil){
        subpreview.type = 2;
    }else{
        subpreview.type = [type integerValue];
    }

    
    if(type != nil && ([type integerValue] == 3 ||[type integerValue] == 1)){
        NSString *img_name = dict[@"imgName"];
        NSString *imgSize = dict[@"imgSize"];
        NSArray *array_imgsize = [imgSize componentsSeparatedByString:@","];
        
        if(top > 0){
            marginy = top;
        }
        if(bottom > 0){
            marginy = previewheight - bottom - [array_imgsize[1] integerValue];
        }
        if(left > 0){
            marginx = left;
        }
        if(right > 0){
            marginx = previewWidth - [array_imgsize[0] integerValue] - right;
        }
        if(left == 0 && right == 0){
            marginx = (previewWidth - [array_imgsize[0] integerValue]) /2;
        }
        CGRect rect = CGRectMake(marginx, marginy, [array_imgsize[0] integerValue], [array_imgsize[1] integerValue]);
        subpreview.rect = rect;
        subpreview.img_name = img_name;
        return subpreview;
    }
    
    
    NSString *text = dict[@"text"];
    NSString *font_name = dict[@"fontName"];
    NSNumber *font_size = dict[@"fontSize"];
    NSString *text_color = dict[@"textColor"];
    NSString *backgroundColor = dict[@"backgroundColor"];
    subpreview.text = text;
    subpreview.font = [UIFont fontWithName:font_name size:[font_size integerValue]];
    subpreview.font_size = [font_size integerValue];
    subpreview.text_color = [SubtitlePreview getColorFromString:text_color];
    subpreview.backgroundColor = [SubtitlePreview getColorFromString:backgroundColor];
    
    CGSize size = [SubtitlePreview getLblSize:subpreview.font width:MAXFLOAT height:subpreview.font_size+5 str:subpreview.text];
    NSInteger addMore = 0; //这里主要是文字距离周围的边距
    if(backgroundColor != nil && ![backgroundColor hasSuffix:@",0"]){
        addMore = [font_size integerValue]/3;
        subpreview.addBackground = YES;
    }else{
        subpreview.addBackground = NO;
    }
    if(left > 0){
        marginx = left;
    }
    if(right > 0){
        marginx = previewWidth - size.width - right - addMore * 2;
    }
    if(left == 0 && right == 0){
        marginx = (previewWidth - size.width - addMore * 2) /2;
    }
    if(top > 0){
        marginy = top;
    }
    if(bottom > 0){
        marginy = previewheight - bottom - size.height - addMore * 2;
    }
    
    if(top == 0 && bottom == 0){
        marginy = (previewheight - bottom - size.height - addMore * 2)/2;
    }
    
    CGRect rect = CGRectMake(marginx + addMore, marginy, size.width + 1,size.height +1 + addMore * 2);
    CGRect  rect_backGround = CGRectMake(marginx, marginy, size.width + 1 + addMore * 2,size.height +1 + addMore * 2);
    subpreview.rect = rect;
    subpreview.rect_backGround = rect_backGround;
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

//计算label高宽
+(CGSize)getLblSize:(UIFont *)font width:(CGFloat)width height:(CGFloat)height str:(NSString*)str{
    CGSize size =[str textSizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}
@end

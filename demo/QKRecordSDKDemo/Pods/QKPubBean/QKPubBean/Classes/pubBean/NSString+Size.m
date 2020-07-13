//
//  NSString+Size.m
//  qukan4
//
//  Created by chenyu on 14-9-30.
//  Copyright (c) 2014年 RenewTOOL. All rights reserved.
//

#import "NSString+Size.h"
@implementation NSString(Size)
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    CGSize textSize;
    
    if (CGSizeEqualToSize(size, CGSizeZero))
        
    {
        
        //            NSDictionary *attributes = @{NSFontAttributeName:font}
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        //            textSize = [self sizeWithAttributes:attributes];
        
        //            textSize = []
        
        
        
        textSize = [self sizeWithAttributes:attributes];
        
    }
    
    else
        
    {
//        if(clipPubthings.isIos7){
//
////            NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//
//            //NSStringDrawingTruncatesLastVisibleLine如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。 如果指定了NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略 NSStringDrawingUsesFontLeading计算行高时使用行间距。（译者注：字体大小+行间距=行高）
//
////            NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
//
////            CGRect rect = [self boundingRectWithSize:size
////
////                                             options:option
////
////                                          attributes:attributes
////
////                                             context:nil];
//
//            textSize=[self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
//
//
////            textSize = rect.size;
//
//        }else{
//
//
//            textSize=[self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
//        }
        textSize = [self sizeForString:self attribute:@{NSFontAttributeName:font} width:size.width];
    }
    
    return textSize;
}

#pragma mark - tool
-(CGSize) sizeForString:(NSString*)string attribute:(NSDictionary*) attribute width:(CGFloat)width
{
    CGRect newFrame = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attribute
                                           context:nil];
    newFrame.size.height = ceil(newFrame.size.height);
    return newFrame.size;
}
@end

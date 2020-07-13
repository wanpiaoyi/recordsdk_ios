//
//  QKJsonKit.m
//  BeijingNews
//
//  Created by yang on 2017/8/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKJsonKit.h"

@implementation QKJsonKit
+ (id)JSONValue:(id)data {
    
    if([data isKindOfClass:[NSData class]]){
        NSError *error;
        
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        id weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if(weatherDic == nil){
//            NSLog(@"jsonChangeError");
            return nil;
        }
        return weatherDic;
    }else if([data isKindOfClass:[NSString class]]){
        
        NSData *jsonData = [data dataUsingEncoding: NSUTF8StringEncoding];
        NSError *error;
        
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        id weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        if(weatherDic == nil){
//            NSLog(@"jsonChangeError");
            return nil;
        }
        return weatherDic;
    }
    
    return nil;
    
}



// 将字典或者数组转化为JSON串

+ (NSString *)JSONString:(id)theData{
    
    
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                        
                                                       options:NSJSONWritingPrettyPrinted
                        
                                                         error:&error];
    
    
    
    if ([jsonData length] > 0 && error == nil){
        
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                
                                                     encoding:NSUTF8StringEncoding];
        
        return jsonString;
        
    }else{
        
        return nil;
        
    }
    
}

@end

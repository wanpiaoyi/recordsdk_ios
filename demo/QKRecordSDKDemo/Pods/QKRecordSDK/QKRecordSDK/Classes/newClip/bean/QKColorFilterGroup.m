//
//  QKColorFilterGroup.m
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "QKColorFilterGroup.h"

@implementation QKColorFilterGroup

-(NSDictionary*)getDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.brightness) forKey:@"brightness"];
    [dic setObject:@(self.contrast) forKey:@"contrast"];
    [dic setObject:@(self.saturation) forKey:@"saturation"];
    [dic setObject:@(self.sharpness) forKey:@"sharpness"];
    [dic setObject:@(self.hue) forKey:@"hue"];
    return dic;
}

+(QKColorFilterGroup*)getFilterGroupByDic:(NSDictionary*)dic{
    if(dic == nil || [dic isKindOfClass:[NSNull class]]){
        return [QKColorFilterGroup getDefaultFilterGroup];
    }
    QKColorFilterGroup *group = [[QKColorFilterGroup alloc] init];
    group.brightness = [[dic objectForKey:@"brightness"] floatValue];
    group.contrast = [[dic objectForKey:@"contrast"] floatValue];
    group.saturation = [[dic objectForKey:@"saturation"] floatValue];
    group.sharpness = [[dic objectForKey:@"sharpness"] floatValue];
    group.hue = [[dic objectForKey:@"hue"] floatValue];
    return group;
}

+(QKColorFilterGroup*)getDefaultFilterGroup{
    QKColorFilterGroup *group = [[QKColorFilterGroup alloc] init];
    group.brightness = 0;
    group.contrast = 1.0;
    group.saturation = 1.0;
    group.sharpness = 0;
    group.hue = 0;
    return group;
}

@end

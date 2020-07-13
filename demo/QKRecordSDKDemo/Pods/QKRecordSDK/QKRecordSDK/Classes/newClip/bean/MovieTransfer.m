//
//  MovieTransfer.m
//  QukanTool
//
//  Created by yang on 2017/12/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MovieTransfer.h"

@implementation MovieTransfer
+(MovieTransfer*)getDefaultTransfer{
    MovieTransfer *transfer = [[MovieTransfer alloc] init];
    transfer.type = 0;
    transfer.name = @"无特效";
    transfer.img_name = @"qk_transfer_no";
    transfer.img_transfer = @"transfer_no";
    return transfer;
}

+(NSArray*)getTransfer{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //转场动画：0 没有动画    1:左侧划入 2右侧划入 3:淡出 4、闪白 5、闪黑 6、模糊推出
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 0;
        transfer.name = @"无特效";
        transfer.img_name = @"qk_transfer_no";
        transfer.img_transfer = @"transfer_no";
        
        [array addObject:transfer];
    }
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 1;
        transfer.name = @"左侧划入";
        transfer.img_name = @"qk_transfer_left";
        transfer.img_transfer = @"trans_left";
        
        [array addObject:transfer];
    }
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 2;
        transfer.name = @"右侧划入";
        transfer.img_name = @"qk_transfer_right";
        transfer.img_transfer = @"trans_right";
        
        [array addObject:transfer];
    }
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 3;
        transfer.name = @"淡入淡出";
        transfer.img_name = @"qk_transfer_thin";
        transfer.img_transfer = @"trans_thin";
        
        [array addObject:transfer];
    }
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 4;
        transfer.name = @"闪白";
        transfer.img_name = @"qk_transfer_white";
        transfer.img_transfer = @"trans_white";
        
        [array addObject:transfer];
    }
    {
        MovieTransfer *transfer = [[MovieTransfer alloc] init];
        transfer.type = 5;
        transfer.name = @"闪黑";
        transfer.img_name = @"qk_transfer_black";
        transfer.img_transfer = @"trans_black";
        
        [array addObject:transfer];
    }

    return array;
}

-(NSDictionary*)getDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.type) forKey:@"type"];
    [dic setObject:self.name forKey:@"name"];
    [dic setObject:self.img_name forKey:@"img_name"];
    [dic setObject:self.img_transfer forKey:@"img_transfer"];
    return dic;
}

+(MovieTransfer*)getTransferByDic:(NSDictionary*)dic{
    if(dic == nil || [dic isKindOfClass:[NSNull class]]){
        return [MovieTransfer getDefaultTransfer];
    }
    MovieTransfer *transfer = [[MovieTransfer alloc] init];
    transfer.type = [[dic objectForKey:@"type"] integerValue];
    transfer.name = [dic objectForKey:@"name"];
    transfer.img_name = [dic objectForKey:@"img_name"];
    transfer.img_transfer = [dic objectForKey:@"img_transfer"];
    
    return transfer;
}

@end

//
//  QKMoviePartDrafts.m
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKMoviePartDrafts.h"
#import "ClipPubThings.h"

@interface QKMoviePartDrafts ()



@end

@implementation QKMoviePartDrafts

-(id)init{
    static long draftId = 0;
    self = [super init];
    if(self){
        self.part_id = @(draftId);
        draftId++;
    }
    return self;
}

-(void)changeNewChangeTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.change_time = [formatter stringFromDate:date];
}

-(NSString*)getDuringTime{
    if(self.during < 60){
        return [NSString stringWithFormat:@"%ld秒",self.during];
    }
    int second = self.during%60;
    int min = self.during/60;
    return [NSString stringWithFormat:@"%d分%d秒",min,second];
}

-(void)deleteAllFiles{
    NSFileManager *fileManager = [[NSFileManager alloc]init];

    NSArray *array_movieParts = [self.dict_save objectForKey:@"array_movieParts"];
//    NSLog(@"array_movieParts:%@",array_movieParts);
    for(NSDictionary *dict in array_movieParts){
        NSString *filepath = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,dict[@"fileAddress"]];
//        NSLog(@"filepath:%@",filepath);
        if([filepath rangeOfString:@"hebingremove"].location != NSNotFound){
            BOOL remove = [fileManager removeItemAtPath:filepath error:nil];
//            NSLog(@"remove:%d  filepath:%@",remove,filepath);
        }
        
    }
    if(self.img_address != nil && self.img_address.length > 0){
        NSString *path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.img_address];
        if([fileManager fileExistsAtPath:path]){
            
            [fileManager removeItemAtPath:path error:nil];
//            NSLog(@"[fileManager removeItemAtPath:path error:nil]:%@",path);
        }
    }
}

/*
 检查草稿是否已损坏
 */
-(BOOL)checkBroken{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *array_movieParts = [self.dict_save objectForKey:@"array_movieParts"];
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL broken = NO;
    for(NSDictionary *dict in array_movieParts){
        [array addObject:dict[@"fileAddress"]];
        if(![manager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,dict[@"fileAddress"]]]){
            broken = YES;
            break;
        }
    }
    self.checked = YES;
    
    if(broken){
        self.isBroken = broken;
    }
    return broken;
}

@end

//
//  GetNowSubtitles.m
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "GetNowSubtitles.h"
#import "QKShowMovieSuntitle.h"
#import "FlyToTop.h"
#import "FlyFromLeftAndEndRight.h"
#import "FlyFromLeft.h"
#import "AutoInAndAutoOut.h"
#import "JustAutoOut.h"
#import "FlyDownAndEndUp.h"
#import "FlyRightTopAndBottom.h"
#import "QKJsonKit.h"

@implementation GetNowSubtitles
////相对屏幕 210 375
//+(NSArray*)getArrays{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    {
//        NSString *str = @"{\"pointCreen\":\"12,165\",\"pointVer\":\"12,330\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"18\",\"textColor\":\"0.2,0.2,0.2,1\",\"backgroundColor\":\"1,0.847,0.0627,1\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"0.2,0.2,0.2,1\",\"backgroundColor\":\"1,0.847,0.0627,1\"}]}";
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        [array addObject:qk];
//    }
//    {
//        NSString *str = @"{\"pointCreen\":\"12,125\",\"pointVer\":\"12,290\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,0.847,0.0627,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,18,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,0.847,0.0627,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        [array addObject:qk];
//    }
//
//    {
//        NSString *str = @"{\"pointCreen\":\"12,125\",\"pointVer\":\"12,290\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,18,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        [array addObject:qk];
//    }
//
//    {
//        NSString *str = @"{\"pointCreen\":\"360,165\",\"pointVer\":\"160,340\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,4,4\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        [array addObject:qk];
//    }
//
//
//    {
//        NSString *str = @"{\"pointCreen\":\"12,130\",\"pointVer\":\"12,310\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,1\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,14,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,1\"}]}";
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        [array addObject:qk];
//    }
//    {
//        NSString *city = @"杭州";
//
//        NSString *nowTime = [GetNowSubtitles stringDateToDate:[NSDate date]];
//
//        NSString *str = [NSString stringWithFormat:@"{\"pointCreen\":\"20,110\",\"pointVer\":\"20,240\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"%@ %@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0.5\"}],\"previews\":[{\"type\":2,\"margin\":\"0,6,18,0\",\"text\":\"%@ %@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0.5\"}]}",nowTime,city,nowTime,city];
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        qk.subControl.animation = [[FlyFromLeftAndEndRight alloc] init];
//        qk.endTime = 3.5;
//
//        [array addObject:qk];
//    }
////    {
////        NSString *city = userQkLocation.city;
////        if(city == nil){
////            city = @"杭州";
////        }
////        NSString *nowTime = [GetNowSubtitles stringDateToDate:[NSDate date]];
////
////        NSString *str = [NSString stringWithFormat:@"{\"pointCreen\":\"360,8\",\"pointVer\":\"200,8\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":0,\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"13\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":1,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":2,\"imgName\":\"qktool_local_address.png\",\"imgSize\":\"13,13\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":2,\"padding\":2,\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"13\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"4,0,0,4\",\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":3,\"margin\":\"16,0,0,24\",\"imgName\":\"qktool_local_address.png\",\"imgSize\":\"10,10\"},{\"type\":2,\"margin\":\"16,0,0,4\",\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}",nowTime,city,nowTime,city];
////
////
////        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
////        [array addObject:qk];
////    }
//
////    {\"type\":2,\"margin\":\"0,4,4,0\",\"img_name\":\"\",\"imgSize\":\"\"}
//    {
//        NSString *str = @"{\"pointCreen\":\"360,180\",\"pointVer\":\"160,340\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":3,\"padding\":3,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        qk.subControl.animation = [[BaseAnimation alloc] init];
//        [array addObject:qk];
//    }
//
//    {
//        NSString *str = @"{\"pointCreen\":\"360,70\",\"pointVer\":\"160,150\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":3,\"padding\":3,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"22\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
//
//
//        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
//        qk.subControl.animation = [[FlyToTop alloc] init];
//        [array addObject:qk];
//    }
//
//
//
//    return array;
//}

//相对屏幕 210 375
+(NSArray*)getArrays{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    {
        NSString *str = @"{\"pointCreen\":\"12,165\",\"pointVer\":\"12,330\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"18\",\"textColor\":\"0.2,0.2,0.2,1\",\"backgroundColor\":\"1,0.847,0.0627,1\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"0.2,0.2,0.2,1\",\"backgroundColor\":\"1,0.847,0.0627,1\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        
        qk.subControl.animation = [[AutoInAndAutoOut alloc] init];
        
        [array addObject:qk];
    }
    {
        NSString *str = @"{\"pointCreen\":\"12,125\",\"pointVer\":\"12,290\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,0.847,0.0627,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,18,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,0.847,0.0627,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[FlyFromLeft alloc] init];
        
        [array addObject:qk];
    }
    
    {
        NSString *str = @"{\"pointCreen\":\"12,125\",\"pointVer\":\"12,290\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,18,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[FlyFromLeft alloc] init];
        
        [array addObject:qk];
    }
    
    {
        NSString *str = @"{\"pointCreen\":\"360,165\",\"pointVer\":\"160,340\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"23\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,4,4\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[AutoInAndAutoOut alloc] init];
        
        [array addObject:qk];
    }
    
    
    {
        NSString *str = @"{\"pointCreen\":\"12,130\",\"pointVer\":\"12,310\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,1\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,14,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,1\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[AutoInAndAutoOut alloc] init];
        
        [array addObject:qk];
    }
    {
        NSString *city = @"杭州";
 
        NSString *nowTime = [GetNowSubtitles stringDateToDate:[NSDate date]];
        
        NSString *str = [NSString stringWithFormat:@"{\"pointCreen\":\"20,110\",\"pointVer\":\"20,240\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"%@ %@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0.5\"}],\"previews\":[{\"type\":2,\"margin\":\"0,6,18,0\",\"text\":\"%@ %@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0.5\"}]}",nowTime,city,nowTime,city];
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[FlyFromLeftAndEndRight alloc] init];
        qk.endTime = 3.5;
        
        [array addObject:qk];
    }
    //    {
    //        NSString *city = userQkLocation.city;
    //        if(city == nil){
    //            city = @"杭州";
    //        }
    //        NSString *nowTime = [GetNowSubtitles stringDateToDate:[NSDate date]];
    //
    //        NSString *str = [NSString stringWithFormat:@"{\"pointCreen\":\"360,8\",\"pointVer\":\"200,8\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":0,\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"13\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":1,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":2,\"imgName\":\"qktool_local_address.png\",\"imgSize\":\"13,13\"},{\"type\":2,\"margin\":\"30,0,0,0\",\"align\":2,\"padding\":2,\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"13\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"4,0,0,4\",\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":3,\"margin\":\"16,0,0,24\",\"imgName\":\"qktool_local_address.png\",\"imgSize\":\"10,10\"},{\"type\":2,\"margin\":\"16,0,0,4\",\"text\":\"%@\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}",nowTime,city,nowTime,city];
    //
    //
    //        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
    //        [array addObject:qk];
    //    }
    
    //    {\"type\":2,\"margin\":\"0,4,4,0\",\"img_name\":\"\",\"imgSize\":\"\"}
    {
        NSString *str = @"{\"pointCreen\":\"360,180\",\"pointVer\":\"160,340\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":3,\"padding\":3,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"17\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[JustAutoOut alloc] init];
        [array addObject:qk];
    }
    
    {
        NSString *str = @"{\"pointCreen\":\"360,70\",\"pointVer\":\"160,150\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":3,\"padding\":3,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"22\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0.145,0.49,1,0\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        qk.subControl.animation = [[FlyToTop alloc] init];
        [array addObject:qk];
    }

    {
        NSString *str = @"{\"pointCreen\":\"12,165\",\"pointVer\":\"12,330\",\"showviews\":[{\"type\":1,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":2,\"imgName\":\"qktool_yellowcolor.png\",\"imgSize\":\"4,24\"},{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":2,\"padding\":2,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"18\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":1,\"margin\":\"0,4,2,0\",\"imgName\":\"qktool_yellowcolor.png\",\"imgSize\":\"2,16\"},{\"type\":2,\"margin\":\"0,8,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        
        qk.subControl.animation = [[FlyFromLeft alloc] init];
        
        [array addObject:qk];
    }
    {
        NSString *str = @"{\"pointCreen\":\"12,165\",\"pointVer\":\"12,330\",\"showviews\":[{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"18\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":1,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":4,\"imgName\":\"qktool_yellowcolor.png\",\"imgSize\":\"30,2\"},{\"type\":2,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"12\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}],\"previews\":[{\"type\":2,\"margin\":\"0,4,24,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"14\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"},{\"type\":1,\"margin\":\"0,4,20,0\",\"imgName\":\"qktool_yellowcolor.png\",\"imgSize\":\"80,2\"},{\"type\":2,\"margin\":\"0,4,4,0\",\"text\":\"演示文字\",\"fontName\":\"Helvetica-Bold\",\"fontSize\":\"10\",\"textColor\":\"1,1,1,1\",\"backgroundColor\":\"0,0,0,0\"}]}";
        
        
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str];
        
        qk.subControl.animation = [[FlyRightTopAndBottom alloc] init];
        
        [array addObject:qk];
    }
    
    return array;
}

+(QKShowMovieSuntitle *)getMovieSub:(NSString*)str{
    NSDictionary *dict = [QKJsonKit JSONValue:str];
    QKShowMovieSuntitle *qk = [QKShowMovieSuntitle getShowMovieSuntitle:dict];
    return qk;
}
+(NSString *)stringDateToDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MM月dd日"];
    
    return [formatter stringFromDate:date];
    
}
@end

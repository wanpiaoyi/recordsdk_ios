//
//  OSSSqlite.h
//  QukanTool
//
//  Created by yang on 15/11/23.
//  Copyright © 2015年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "RecordData.h"

#define ossSynch ((OSSSqlite *)[OSSSqlite getLiveOSSSqlite])

//uploadListIsFinished NSNotificationCenter 第一次upload的时候完成
@interface OSSSqlite : NSObject{
    mach_timespec_t mts;
}

@property (strong, nonatomic) FMDatabase *db; //sqlite
@property (nonatomic, strong) NSFileManager *main_thread_manager;


+ (OSSSqlite *)getLiveOSSSqlite;
@property(copy,nonatomic) NSString *name;
//获取全部的录像文件
-(NSMutableArray*)getAllRecord:(NSString *)type;


//state 1彻底删除 state2 只是不在上传列表中显示
-(void)deleteNameOrAddress:(NSArray*)arrayRecord;

- (void)insertLiveLocal:(NSString*)name address:(NSString*)address time:(NSInteger)time type:(NSString*)type activityId:(NSNumber*)activityId;

-(void)updateState:(RecordData*)data state:(NSNumber*)state;


-(BOOL)getUpdateState:(NSNumber*)liveId;
@end

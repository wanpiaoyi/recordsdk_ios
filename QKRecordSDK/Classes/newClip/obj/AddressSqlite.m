//
//  AddressSqlite.m
//  QukanTool
//
//  Created by yang on 2019/2/21.
//  Copyright © 2019 yang. All rights reserved.
//

#import "AddressSqlite.h"
#import "RecordData.h"
#import "ClipPubThings.h"
#define ADDRESSDBNAME @"address.sqlite"
#define ADDRESSSql @"addressSql"


@implementation AddressSqlite

+(AddressSqlite *)getAddressSqlite{
    static dispatch_once_t once;
    static AddressSqlite *sharedView;
    dispatch_once(&once, ^{
        sharedView = [[AddressSqlite alloc] init];
    });
    return sharedView;
}

- (id)init {
    self = [super init];
    if (self) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:ADDRESSDBNAME];
        self.db = [FMDatabase databaseWithPath:path];
        [self createTable];
    }
    return self;
}

- (void)createTable {
    //sql 语句
    
    FMDatabaseQueue *queue = [AddressSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            //type 10:最近的cg    'pgc_id', 'pgc_title', 'content', 'vposter','live_type', 'live_url', 'live_stime', 'live_etime', 'need_recommend', 'user_id'
            NSString *sqlCreateTable1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'address' TEXT, 'file_name' TEXT, 'draft_id' INTEGER)", ADDRESSSql];
            BOOL res1 = [db executeUpdate:sqlCreateTable1];
            if (!res1) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"success to creating db table");
            }
            [db close];
        }
        
    }];
}

#pragma mark - 配置数据库单聊
+ (FMDatabaseQueue *)getSharedDatabaseQueue {
    FMDatabaseQueue *my_FMDatabaseQueue = nil;
    
    if (!my_FMDatabaseQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:ADDRESSDBNAME];
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return my_FMDatabaseQueue;
}

-(void)insertAddress:(NSString*)address name:(NSString*)name draftId:(NSNumber *)draftId{
    FMDatabaseQueue *queue = [AddressSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            
            //
            [db beginTransaction];
            BOOL isRollBack = NO;
            @try {
                {
                    NSString *sql = [NSString stringWithFormat:
                                     @"INSERT INTO '%@' ('address','file_name','draft_id') VALUES (?,?,?)",ADDRESSSql];
                    long long change_time_int = [[NSDate date] timeIntervalSince1970];
                    
                    BOOL a = [db executeUpdate:sql,address,name,draftId];
                    if (!a) {
                        NSLog(@"插入失败1");
                    }else{
                        NSLog(@"插入成功");
                    }
                }
                
            }
            @catch (NSException *exception) {
                isRollBack = YES;
                [db rollback];
            }
            @finally {
                if (!isRollBack) {
                    [db commit];
                    [db close];
                }
            }
        }
        
    }];
}

-(void)deleteSql:(NSNumber *)draftId{
   
    FMDatabaseQueue *queue = [AddressSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            
            NSString *deleteSql = [NSString stringWithFormat:
                                   @"delete from '%@' where draft_id = '%@'",
                                   ADDRESSSql, draftId];
            
            BOOL res = [db executeUpdate:deleteSql];
            
            if (!res) {
                NSLog(@"error when deleteSql db table");
            } else {
                NSLog(@"success to deleteSql db table");
            }
            [db close];
        }
    }];
}

-(void)deleteUnuseFiles{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dicFiles = [weakSelf getAddress];
        NSString *baseSavePath = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,localRecordType];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:baseSavePath];  //baseSavePath 为文件夹的路径
        NSString *file;
        while((file=[myDirectoryEnumerator nextObject]))     //遍历当前目录
        {
            NSString *str = [dicFiles objectForKey:file];
            if(str == nil){
                NSString *path = [NSString stringWithFormat:@"%@/%@",baseSavePath,file];
                Boolean delete = [fileManager removeItemAtPath:path error:nil];
                if(delete){
                    NSLog(@"delete:%@",path);
                }
            }
        }
    });

}



-(NSMutableDictionary *)getAddress{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self.db open]) {
        
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM %@ ", ADDRESSSql];
        sql = [NSString stringWithFormat:@"%@ order by id desc limit 1",sql];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            NSString *fileName = [rs stringForColumn:@"file_name"];
            [dict setObject:@"1" forKey:fileName];
        }
        
        [self.db close];
    }
    
    
    return dict;
}

@end

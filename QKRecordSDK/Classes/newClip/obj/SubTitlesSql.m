//
//  SubTitlesSql.m
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubTitlesSql.h"
#import "QKJsonKit.h"
#import "AddressSqlite.h"

#define SUBTITLEDBNAME @"subtitle.sqlite"
#define SubTitleDrafts @"qkSubTitleDrafts"

@implementation SubTitlesSql

+(SubTitlesSql *)getSubTitleSqlite{
    static dispatch_once_t once;
    static SubTitlesSql *sharedView;
    dispatch_once(&once, ^{
        sharedView = [[SubTitlesSql alloc] init];
    });
    return sharedView;
}

- (id)init {
    self = [super init];
    if (self) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:SUBTITLEDBNAME];
        self.db = [FMDatabase databaseWithPath:path];
        [self createTable];
    }
    return self;
}

- (void)createTable {
    //sql 语句
    
    FMDatabaseQueue *queue = [SubTitlesSql getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            //type 10:最近的cg    'pgc_id', 'pgc_title', 'content', 'vposter','live_type', 'live_url', 'live_stime', 'live_etime', 'need_recommend', 'user_id'
            NSString *sqlCreateTable1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'dict_save' TEXT, 'img_address' TEXT, 'change_time' TEXT, 'part_name' TEXT,'during' INTEGER,'isBroken' INTEGER,'username' TEXT,'change_time_int' INTEGER)", SubTitleDrafts];
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
        NSString *path = [documents stringByAppendingPathComponent:SUBTITLEDBNAME];
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return my_FMDatabaseQueue;
}



-(void)insertSql:(QKMoviePartDrafts*)drafts{
    FMDatabaseQueue *queue = [SubTitlesSql getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
//        @property(strong,nonatomic) NSDictionary *dict_save;
//        @property(copy,nonatomic) NSString *img_address;
//        @property(copy,nonatomic) NSString *change_time;
//        @property(copy,nonatomic) NSString *part_name;
//        @property NSInteger during;
//        @property BOOL isBroken;
        //打开数据库
        if ([db open]) {
            
            //
            [db beginTransaction];
            BOOL isRollBack = NO;
            @try {
                {
                    NSData *jsonData = [self toJSONData:drafts.dict_save];
                    NSString *str = [[NSString alloc] initWithData:jsonData
                                                          encoding:NSUTF8StringEncoding];
                    NSString *sql = [NSString stringWithFormat:
                                     @"INSERT INTO '%@' ('dict_save','img_address','change_time','part_name','during','isBroken','username','change_time_int') VALUES (?,?,?,?,?,?,?,?)",SubTitleDrafts];
                    long long change_time_int = [[NSDate date] timeIntervalSince1970];
                    
                    BOOL a = [db executeUpdate:sql,str,drafts.img_address,drafts.change_time,drafts.part_name,@(drafts.during),@(drafts.isBroken),[self getName],@(change_time_int)];
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

-(void)updateSql:(QKMoviePartDrafts*)drafts{
    if(drafts.part_id == nil){
        return;
    }
    
    FMDatabaseQueue *queue = [SubTitlesSql getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //        @property(strong,nonatomic) NSDictionary *dict_save;
        //        @property(copy,nonatomic) NSString *img_address;
        //        @property(copy,nonatomic) NSString *change_time;
        //        @property(copy,nonatomic) NSString *part_name;
        //        @property NSInteger during;
        //        @property BOOL isBroken;
        //打开数据库
        if ([db open]) {
            
            //
            [db beginTransaction];
            BOOL isRollBack = NO;
            @try {
                {
                    NSData *jsonData = [self toJSONData:drafts.dict_save];
                    NSString *str = [[NSString alloc] initWithData:jsonData
                                                          encoding:NSUTF8StringEncoding];
                    NSString *updateSql = [NSString stringWithFormat:
                                           @"UPDATE %@ SET 'dict_save'=?,'img_address'=?,'change_time'=?,'part_name'=?,'during'=?,'isBroken'=?,'change_time_int'=? where id = '%@'",
                                           SubTitleDrafts,drafts.part_id];
                    long long change_time_int = [[NSDate date] timeIntervalSince1970];
           
                    
                    BOOL a = [db executeUpdate:updateSql,str,drafts.img_address,drafts.change_time,drafts.part_name,@(drafts.during),@(drafts.isBroken),@(change_time_int)];
                    if (!a) {
                        NSLog(@"更改失败1");
                    }else{
                        NSLog(@"更改成功");
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

-(void)deleteSqlAndFile:(QKMoviePartDrafts *)drafts{
    NSFileManager *fileManager = [[NSFileManager alloc]init];

    NSArray *array_movieParts = [drafts.dict_save objectForKey:@"array_movieParts"];
//    NSLog(@"array_movieParts:%@",array_movieParts);
    for(NSDictionary *dict in array_movieParts){
        NSString *filepath = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,dict[@"fileAddress"]];
//        NSLog(@"filepath:%@",filepath);
        if([filepath rangeOfString:@"hebingremove"].location != NSNotFound){
            BOOL remove = [fileManager removeItemAtPath:filepath error:nil];
//            NSLog(@"remove:%d  filepath:%@",remove,filepath);
        }
        
    }
    [self deleteSql:drafts];
}

-(void)deleteSql:(QKMoviePartDrafts *)drafts{
    NSFileManager *fileManager = [[NSFileManager alloc]init];

    if(drafts.img_address != nil && drafts.img_address.length > 0){
        NSString *path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,drafts.img_address];
        if([fileManager fileExistsAtPath:path]){
            
            [fileManager removeItemAtPath:path error:nil];
            NSLog(@"[fileManager removeItemAtPath:path error:nil]:%@",path);
        }
    }

    
    
    FMDatabaseQueue *queue = [SubTitlesSql getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            
            NSString *deleteSql = [NSString stringWithFormat:
                             @"delete from '%@' where id = '%@'",
                             SubTitleDrafts, drafts.part_id];
  
            BOOL res = [db executeUpdate:deleteSql];
            
            if (!res) {
                NSLog(@"error when deleteSql db table");
            } else {
                NSLog(@"success to deleteSql db table");
            }
            
            [db close];
        }
        
    }];
    [addressSql deleteSql:drafts.part_id];

}


-(QKMoviePartDrafts *)getNewsDrafts{
    
    QKMoviePartDrafts *qk = nil;
    if ([self.db open]) {
        
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM %@ where username = '%@' ", SubTitleDrafts,[self getName]];
        sql = [NSString stringWithFormat:@"%@ order by id desc limit 1",sql];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            qk = [[QKMoviePartDrafts alloc] init];
            
            NSInteger draft_id = [rs intForColumn:@"id"];
            
            qk.part_id = @(draft_id);
            NSString *dict_save = [rs stringForColumn:@"dict_save"];
            
            qk.dict_save = [QKJsonKit JSONValue:dict_save];
            NSString *img_address = [rs stringForColumn:@"img_address"];
            
            qk.img_address = img_address;
            NSString *change_time = [rs stringForColumn:@"change_time"];
            
            qk.change_time = change_time;
            NSString *part_name = [rs stringForColumn:@"part_name"];
            
            qk.part_name = part_name;
            NSInteger during = [rs intForColumn:@"during"];
            
            qk.during = during;
            NSInteger isBroken = [rs intForColumn:@"isBroken"];
            
            qk.isBroken = isBroken;
            
            break;
            
        }
        
        [self.db close];
    }
    
    
    return qk;
}


-(NSMutableArray*)getDraftsLists{

    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([self.db open]) {
        
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM %@ where username = '%@' ", SubTitleDrafts,[self getName]];
        sql = [NSString stringWithFormat:@"%@ order by change_time_int desc",sql];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            QKMoviePartDrafts *qk = [[QKMoviePartDrafts alloc] init];
            NSInteger draft_id = [rs intForColumn:@"id"];
            
            qk.part_id = @(draft_id);
            NSString *dict_save = [rs stringForColumn:@"dict_save"];

            qk.dict_save = [QKJsonKit JSONValue:dict_save];
            NSString *img_address = [rs stringForColumn:@"img_address"];

            
            qk.img_address = img_address;
            NSString *change_time = [rs stringForColumn:@"change_time"];

            qk.change_time = change_time;
            NSString *part_name = [rs stringForColumn:@"part_name"];

            qk.part_name = part_name;
            NSInteger during = [rs intForColumn:@"during"];

            qk.during = during;
            NSInteger isBroken = [rs intForColumn:@"isBroken"];

            qk.isBroken = isBroken;
     
            [array addObject:qk];
 
        }
        
        [self.db close];
    }
    
    
    return array;
}


// 将字典或者数组转化为JSON串
- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0&&error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

-(NSString*)getName{
    return @"112233";
}

@end

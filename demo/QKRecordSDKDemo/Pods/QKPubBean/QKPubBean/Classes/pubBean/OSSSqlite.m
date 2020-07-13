 //
//  OSSSqlite.m
//  QukanTool
//
//  Created by yang on 15/11/23.
//  Copyright © 2015年 yang. All rights reserved.
//

#import "OSSSqlite.h"
#import "HeaderFile.h"

#define DBNAME @"zjgd.sqlite"
#define OSS_live @"zjgdSql1"



@implementation OSSSqlite

+ (OSSSqlite *)getLiveOSSSqlite {
    static dispatch_once_t once;
    static OSSSqlite *sharedView;
    dispatch_once(&once, ^{
        
        sharedView = [[OSSSqlite alloc] init];
        
    });
    return sharedView;
}
#pragma mark - 配置数据库单聊
+ (FMDatabaseQueue *)getSharedDatabaseQueue {
    FMDatabaseQueue *my_FMDatabaseQueue = nil;
    
    if (!my_FMDatabaseQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:DBNAME];
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return my_FMDatabaseQueue;
}
- (id)init {
    self = [super init];
    if (self) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *path = [documents stringByAppendingPathComponent:DBNAME];
        self.db = [FMDatabase databaseWithPath:path];
        self.main_thread_manager = [[NSFileManager alloc] init];
        [self createTable];
    }
    return self;
}


//介绍：1次录播 可以生产多个mp4的文件分块，每个mp4的文件分块上传到服务器后，可以通知服务器合并这些分块成为一个完整的视频文件


//OSS_liveend 用于管理一次录播的上传。
//字段id ：主键
//字段name：本次录播的唯一标示，用于了解，那些文件是属于这次录播的，每个录播的分片也会携带这个name字段。
//字段uploadfinished：0 未发出过合并请求  1 合并请求成功  2、发送过合并请求，但是没有收到成功的消息
//字段user_name:用于做多个用户的区分，标示哪些用户合并文件完成了


//OSS_live 用于管理一次录播的多个分片
//字段id：主键，也是RecordData对象中的liveid.
//字段name :分片文件名
//字段type ：文件类型，目前只支持localvideo 录播文件类型
//字段address：文件相对路径
//字段time :录像的时长
//字段updatefilename：上传到服务器上的名称
//字段updatetype: 上传方式，目前只支持断点续传initMultipart
//字段appendPosition：上传进度
//字段pause：是否暂停
//字段uploadfinish：文件是否上传到阿里云服务器。0：未完成  1：完成了
//字段noticeserver：文件通知服务器，上传完成。 0：未通知 1：通知完成 2：通知过，但是没有收到服务器完成的返回。
//字段liveendname： OSS_liveend 中的name字段，标示那些分片属于同一次录播
//字段user_name:用于做多个用户的区分，目前只是记录了分片在那些用户上面上传完成了
//字段needupload:是否需要进行上传。 0：不需要 1：需要.这个是记录上次正在进行上传的文件的标示。



- (void)createTable {
    //sql 语句
    
    FMDatabaseQueue *queue = [OSSSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            
            

            
            NSString *sqlCreateTable1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT, 'name' TEXT,  'address' TEXT,'type' TEXT, 'time' TEXT,'size' INTEGER,'userName' TEXT,'activityId' INTEGER,'uploadState' INTEGER)",OSS_live];
            BOOL res1 = [db executeUpdate:sqlCreateTable1];
            if (!res1) {
                NSLog(@"error when creating OSS_live db table");
            } else {
                NSLog(@"success to creating OSS_live db table");
            }
            
            
            
            [db close];
        }
        
    }];
    
}




#pragma mark - OSS_live 中数据操作


#pragma mark - OSS_live 中数据查询操作
//获取全部的录像
-(NSMutableArray*)getAllRecord:(NSString *)type{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if ([self.db open]) {
        NSString *userName = self.name;
        if(userName == nil){
            userName = @"qktest";
        }

        
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM %@ where type = '%@' and userName = '%@'", OSS_live,type,userName];
        
        
        
        sql = [NSString stringWithFormat:@"%@ order by id desc",sql];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            RecordData *data = [[RecordData alloc] init];
            [self getRecordDatabyRs:data rs:rs  nowname:[self getUserSingleName]];
            [array addObject:data];
        }
        
        [self.db close];
    }
    
    return array;
}

-(BOOL)getUpdateState:(NSNumber*)liveId{
    BOOL finished = NO;
    if(liveId == nil){
        return finished;
    }
    if ([self.db open]) {
        
        NSString *sql = [NSString stringWithFormat:
                         @"SELECT uploadState FROM %@ where id = '%@'", OSS_live,liveId];
        
        
        
        sql = [NSString stringWithFormat:@"%@ order by id desc",sql];
        FMResultSet *rs = [self.db executeQuery:sql];
        
        while ([rs next]) {
            NSInteger uploadState = [rs intForColumn:@"uploadState"];
            if(uploadState == 2){
                finished = YES;
            }
        }
        
        [self.db close];
    }
    return finished;
}

//插入一条数据
- (void)insertLiveLocal:(NSString*)name address:(NSString*)address time:(NSInteger)time type:(NSString*)type activityId:(NSNumber*)activityId{
    if(activityId == nil){
        activityId = @(0);
    }
    NSString *addtime = [self compareCurrentTime:time];
    FMDatabaseQueue *queue = [OSSSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        
        //打开数据库
        if ([db open]) {
            
            
            [db beginTransaction];
            BOOL isRollBack = NO;
            @try {
                NSString *userName = self.name;
                if(userName == nil){
                    userName = @"qktest";
                }
                NSString *filepath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,address];
                NSString *size = [self fileSizeAtPath:filepath];
                NSString *sql = [NSString stringWithFormat:
                                 @"INSERT INTO '%@' ('name','address','time','size','type','userName','activityId','uploadState') VALUES (?,?,?,?,?,?,?,?)",OSS_live];
                
                BOOL a = [db executeUpdate:sql,name,address,addtime,size,type,userName,activityId,@(0)];
                
                
                if (!a) {
                    NSLog(@"插入失败1");
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


//删除指定录像
-(void)deleteNameOrAddress:(NSArray*)arrayRecord{
    NSMutableArray *arrayAddress = [[NSMutableArray alloc] init];
    NSString *liveid = @"(";
    if(arrayRecord!=nil&&arrayRecord.count>0){
        int i = 0;
        for (RecordData *data in arrayRecord) {
            if(i == 0){
                liveid = [NSString stringWithFormat:@"%@'%@'",liveid,data.liveid];
            }else{
                liveid = [NSString stringWithFormat:@"%@,'%@'",liveid,data.liveid];
            }
            i++;
            NSString *addr = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,data.address];
            [arrayAddress addObject:addr];
        }
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for(NSString *addr in arrayAddress){
            NSFileManager *file = [[NSFileManager alloc] init];
            [file removeItemAtPath:addr error:nil];
        }
 
    });
    
    
    liveid = [NSString stringWithFormat:@"%@)",liveid];
    
    
    FMDatabaseQueue *queue = [OSSSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {

            NSString *deleteSql = [NSString stringWithFormat:
                                   @"delete from '%@' where id in %@",
                                   OSS_live, liveid];
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




//获取指定文件的文件大小
-(NSString*) fileSizeAtPath:(NSString*)address{
    double temp = 0;
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:address])
    {
        temp = [[manager attributesOfItemAtPath:address error:nil] fileSize];
        //        return (long)temp;
    }
    
    if (temp / 1024 < 1024) {
        return [NSString stringWithFormat:@"%.1lfK",temp/1024];
    } else {
        return [NSString stringWithFormat:@"%.1fM",temp/1024.0/1024.0];
    }
    
}

//转化下时间，更加直白
-(NSString *) compareCurrentTime:(NSTimeInterval) timeInterval
{
    int temp = 0;
    int remainder = 0;
    NSString *result;
    
    
    if (timeInterval < 1 )
    {
        result = @"00:00:01";
        
    }else if(timeInterval >= 1 && timeInterval < 60)
    {
        if (timeInterval<10)
        {
            result = [NSString stringWithFormat:@"00:00:0%d",(int)timeInterval];
            
        }else
        {
            result = [NSString stringWithFormat:@"00:00:%d",(int)timeInterval];
        }
    }
    else if(60 <= timeInterval&& timeInterval<= 900)
    {
        
        if(300<=timeInterval&&timeInterval<=303){
            timeInterval = 300;
        }
        remainder = ((int)timeInterval)%60;
        temp = ((int)timeInterval)/60;
        NSString *str1 = nil;
        NSString *str2 = nil;
        if (remainder<10)
        {
            str1 = [NSString stringWithFormat:@"0%d",remainder];
            
        }else
        {
            str1 = [NSString stringWithFormat:@"%d",remainder];
        }
        
        if (temp < 10)
        {
            str2 = [NSString stringWithFormat:@"0%d",temp];
        }else
        {
            str2 = [NSString stringWithFormat:@"%d",temp];
        }
        
        result = [NSString stringWithFormat:@"00:%@:%@",str2,str1];
        
    }else
    {
        result = @"00:15:00";
    }
    
    return  result;
}

-(void)updateState:(RecordData*)data state:(NSNumber*)state{
    data.uploadState = [state integerValue];
    FMDatabaseQueue *queue = [OSSSqlite getSharedDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //打开数据库
        if ([db open]) {
            
            NSString *updateSql = [NSString stringWithFormat:
                                   @"UPDATE %@ SET uploadState = %@ where id = '%@'",
                                   OSS_live,state,data.liveid];
            
            
            BOOL res = [db executeUpdate:updateSql];
            if (!res) {
                //NSLog(@"error when update db table");
            } else {
                //NSLog(@"success to update db table");
            }
            
            
            [db close];
        }
        
    }];

}


//重要 获取当前用户的唯一标示
-(NSString*)getUserSingleName{
    return @"name1";
}



-(void)getRecordDatabyRs:(RecordData*)data rs:(FMResultSet *)rs nowname:(NSString*)nowname{
    
    NSInteger liveId = [rs intForColumn:@"id"];
    NSInteger uploadState = [rs intForColumn:@"uploadState"];
    long long activityId = [rs longLongIntForColumn:@"activityId"];
    NSString *name = [rs stringForColumn:@"name"];
    NSString *type = [rs stringForColumn:@"type"];

    NSString *address = [rs stringForColumn:@"address"];
    NSString *time = [rs stringForColumn:@"time"];
    NSString *size = [rs stringForColumn:@"size"];
    if([size isEqualToString:@"0.0K"]){
        NSString *filepath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,address];
        size = [self fileSizeAtPath:filepath];
    }
    data.liveid = @(liveId);
    data.activityId = @(activityId);
    data.uploadState = @(uploadState);

    data.fileName = name;
    data.address = address;
    data.type = type;
    data.time = time;
    data.size = size;
    if(data.fileName!=nil && data.fileName.length >=14 ){
         data.start_time = [NSString stringWithFormat:@"%@.%@.%@ %@:%@:%@",[data.fileName substringWithRange:NSMakeRange(0, 4)],[data.fileName substringWithRange:NSMakeRange(4, 2)],[data.fileName substringWithRange:NSMakeRange(6, 2)],[data.fileName substringWithRange:NSMakeRange(8, 2)],[data.fileName substringWithRange:NSMakeRange(10, 2)],[data.fileName substringWithRange:NSMakeRange(12, 2)]];
    }else{
         data.start_time = @"";
    }
    data.displayname = name;
}



@end

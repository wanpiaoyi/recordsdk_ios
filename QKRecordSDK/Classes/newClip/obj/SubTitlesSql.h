//
//  SubTitlesSql.h
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKMoviePartDrafts.h"
#import "ClipPubThings.h"
#import "ThirdHead.h"
#define subsql ((SubTitlesSql*)[SubTitlesSql getSubTitleSqlite])

@interface SubTitlesSql : NSObject{
    mach_timespec_t mts;
}

@property (strong, nonatomic) FMDatabase *db; //sqlite

+(SubTitlesSql *)getSubTitleSqlite;


-(void)insertSql:(QKMoviePartDrafts*)drafts;
-(void)updateSql:(QKMoviePartDrafts*)drafts;
-(NSMutableArray*)getDraftsLists;
-(void)deleteSqlAndFile:(QKMoviePartDrafts *)drafts;
-(void)deleteSql:(QKMoviePartDrafts*)drafts;
-(QKMoviePartDrafts *)getNewsDrafts;
@end

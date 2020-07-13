//
//  AddressSqlite.h
//  QukanTool
//
//  Created by yang on 2019/2/21.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdHead.h"

#define addressSql ((AddressSqlite*)[AddressSqlite getAddressSqlite])
@interface AddressSqlite : NSObject{
    mach_timespec_t mts;
}

@property (strong, nonatomic) FMDatabase *db; //sqlite

+(AddressSqlite *)getAddressSqlite;
-(void)insertAddress:(NSString*)address name:(NSString*)name draftId:(NSNumber *)draftId;
-(void)deleteSql:(NSNumber *)draftId;
-(void)deleteUnuseFiles;

@end


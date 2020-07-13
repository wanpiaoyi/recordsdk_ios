//
//  PubBundle.m
//  QukanTool
//
//  Created by yangpeng on 2020/2/19.
//  Copyright © 2020 yang. All rights reserved.
//

#import "PubBundle.h"

@implementation PubBundle

+(NSBundle*)bundle{
    
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [cbundle pathForResource:@"QKPubBean" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

@end

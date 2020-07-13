//
//  ALAsset+isEqual.m
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import "ALAsset+isEqual.h"

@implementation ALAsset (isEqual)

- (NSURL *)defaultURL {
  return self.defaultRepresentation.url;
}

- (BOOL)isEqual:(id)obj {
  if (![obj isKindOfClass:[ALAsset class]])
    return NO;

  NSURL *u1 = [self defaultURL];
  NSURL *u2 = [obj defaultURL];
  return ([u1 isEqual:u2]);
}
@end

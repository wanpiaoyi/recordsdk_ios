//
//  RecordData.h
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface QKRecord : NSObject

@property (nonatomic, strong) NSNumber *liveid; //这个录像文件的唯一标示
@property (nonatomic, copy) NSString *fileName; //在后台显示的文件名,文件名规则为：唯一标示符_第几个分片.后缀，同一批录播文件的唯一标示符必须相同，例如：aaa_1.mp4, aaa_2.mp4,代表的是标识符为aaa的第一个和第二个录像分片，唯一标识符要尽量复杂，确保唯一。如果是本地视频也要参照这个规则，就是只有一个分片的录像。
@property (nonatomic, copy) NSString *uploadfileName; //在阿里云服务器上的文件名
@property (nonatomic, copy) NSString *address; //文件在documents目录下的相对路径,格式为: 文件夹/文件名，例如：上传在documents的Record目录下的mp_1.mp4文件，路径填写:Record/mp_1.mp4
@property (nonatomic, copy) NSString *type; //文件类型  localvideo:录播视频，目前支持一种type


@end

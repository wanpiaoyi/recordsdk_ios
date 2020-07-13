//
//  LocalOrSystemVideos.m
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "LocalOrSystemVideos.h"
#import "AssetPickerController.h"
#import "QKVideoBean.h"
#import <QKLiveAndRecord/QKMovieClipController.h>
#import "ClipPubThings.h"
#import "ChooseLocalFiles.h"
#import "VideoManager.h"

#define ReadBufferSize  (1024*128)

@interface LocalOrSystemVideos()<SelectPicFromLibraryDelegate>
@property(strong,nonatomic) UIView *v_main;
@property(strong,nonatomic) IBOutlet UIButton *btn_cancel;
@property(strong,nonatomic) IBOutlet UIView *v_choose;
@property(strong,nonatomic) NSLock *lock;
@property BOOL justOne;
@property BOOL showimg;
@property BOOL showVideo;
@property NSInteger copyFile;
@property NSInteger chooseSelect;
@end

@implementation LocalOrSystemVideos

+(LocalOrSystemVideos *)shareLocalOrSystemVideos{
    static dispatch_once_t once;
    static LocalOrSystemVideos *sharedView;
    dispatch_once(&once, ^ {
        
        sharedView = [[LocalOrSystemVideos alloc] init];
        sharedView.lock = [[NSLock alloc] init];
    });
    return sharedView;
}
+(void)getVideosFastPhoto:(BlockselectVideos)blcSelect copyFile:(NSInteger)copyFile showimg:(BOOL)showimg justOne:(BOOL)justOne showVideo:(BOOL)showVideo{
    LocalOrSystemVideos *share = [LocalOrSystemVideos shareLocalOrSystemVideos];
    share.copyFile = copyFile;
    share.selectVideos = blcSelect;
    share.hidden = NO;
    share.justOne = justOne;
    share.showimg = showimg;
    share.showVideo = showVideo;
    
    if(justOne){
        share.chooseSelect = 1;
    }else{
        share.chooseSelect = 10;
    }
    [share choosePhoto:nil];
}
+(void)getVideos:(BlockselectVideos)blcSelect copyFile:(NSInteger)copyFile showimg:(BOOL)showimg justOne:(BOOL)justOne showVideo:(BOOL)showVideo{
    LocalOrSystemVideos *share = [LocalOrSystemVideos shareLocalOrSystemVideos];
    share.copyFile = copyFile;
    share.selectVideos = blcSelect;
    [clipPubthings.window addSubview:share];
    share.hidden = NO;
    share.justOne = justOne;
    share.showimg = showimg;
    share.showVideo = showVideo;
    if(justOne){
        share.chooseSelect = 1;
    }else{
        share.chooseSelect = 10;
    }
}

+(void)removeSelf{
    LocalOrSystemVideos *share = [LocalOrSystemVideos shareLocalOrSystemVideos];
    share.copyFile = -1;
    share.selectVideos = nil;
    [share removeFromSuperview];
    share.hidden = NO;
    
}

-(id)init{
    self = [super initWithFrame:CGRectMake(0, 0, clipPubthings.screen_width, qk_screen_height)];
    if(self){
        self.v_main = [[[clipPubthings clipBundle] loadNibNamed:@"LocalOrSystemVideos1" owner:self options:nil] lastObject];
        
        self.v_main.frame = self.bounds;
        [self addSubview:self.v_main];
//        self.btn_cancel.layer.cornerRadius = 5.0;
//        self.v_choose.layer.cornerRadius = 5.0;
        if(clipPubthings.deleteBottom > 0){
            CGRect rect = self.btn_cancel.frame;
            self.btn_cancel.frame = CGRectMake(rect.origin.x, rect.origin.y - clipPubthings.deleteBottom, rect.size.width, rect.size.height);
            
            rect = self.v_choose.frame;
            self.v_choose.frame = CGRectMake(rect.origin.x, rect.origin.y - clipPubthings.deleteBottom, rect.size.width, rect.size.height);
        }
        self.chooseSelect = 1;
        self.copyFile = 1;
    }
    return self;
}

-(IBAction)chooseLocal:(id)sender{
    WS(weakSelf);
    ChooseLocalFiles *choose = [[ChooseLocalFiles alloc] init];
    choose.justOne = self.justOne;
    choose.showLive = videoManager.liveVideoShow;
    choose.showClip = videoManager.clipVideoShow;
    choose.showRecord = videoManager.recordVideoShow;
    choose.selectVideos = ^(NSArray *array){
        for(RecordData *data in array){
            data.deleteEndEdict = NO;
        }
        if(weakSelf.selectVideos){
            weakSelf.selectVideos(array);
        }
        [weakSelf cancelView:nil];
    };
    choose.modalPresentationStyle = UIModalPresentationFullScreen;
    [clipPubthings.nav presentViewController:choose animated:YES completion:NULL];
    self.hidden = YES;
    
}

-(IBAction)choosePhoto:(id)sender{
    AssetPickerController *_picker = [[AssetPickerController alloc] init];
    if(self.showimg&&self.showVideo){
        _picker.assetsFilter = [ALAssetsFilter allAssets];
        //        NSLog(@"[ALAssetsFilter allAssets]1");
    }else if(self.showVideo){
        _picker.assetsFilter = [ALAssetsFilter allVideos];
    }else{
        _picker.assetsFilter = [ALAssetsFilter allPhotos];
    }
    _picker.showImages = self.showimg;
    _picker.showVideo = self.showVideo;
    _picker.showEmptyGroups = NO;
    _picker.picDelegate = self;
    _picker.selectAllcount = self.chooseSelect;
    _picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [clipPubthings.nav presentViewController:_picker animated:YES completion:NULL];
    self.hidden = YES;
}

-(IBAction)cancelView:(id)sender{
    self.copyFile = -1;
    self.selectVideos = nil;
    [self removeFromSuperview];
}
#pragma mark - SelectPicFromLibraryDelegate
- (void)returnSelectedAssetFromLibrary:(NSMutableArray *)AssetArray {
    WS(weakSelf);
    [clipPubthings showHUD_Login:@"视频处理中"];
    if([self.lock tryLock]){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (ALAsset *asset in AssetArray) {
                NSString *type = [asset valueForProperty:ALAssetPropertyType];
                NSString *fileState = localRecordType;
                if ([type isEqual:ALAssetTypeVideo]) {
                    fileState = selectFromPhotoVideo;
                }
                if ([type isEqual:ALAssetTypePhoto]) {
                    fileState = selectFromPhotoImg;
                }
                
                
                
                if(weakSelf.copyFile > 0){
                    NSString *filename = [NSString stringWithFormat:@"temp_%@",[weakSelf getFilename]]; //文件名必须唯一，所以更具时间与随机数创建;
                    //给文件名加上后缀如.mov  .mp4之类的
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    NSString *asset_filename = rep.filename;
                    NSArray *array_asset = [asset_filename componentsSeparatedByString:@"."];
                    NSString *houzhui = [NSString stringWithFormat:@".%@",array_asset[array_asset.count-1]];
                    if(array_asset.count > 1){
                        houzhui = array_asset[array_asset.count - 1];
                        if([type isEqual:ALAssetTypeVideo]){
                            houzhui = @"mp4";
                        }
                    }
                    filename = [NSString stringWithFormat:@"%@_1.%@",filename,houzhui];
                    
                    NSString *str_filedirect = localRecordType;
              
                    
                    NSString *address = [NSString stringWithFormat:@"%@/%@",str_filedirect,filename];
                    
                    NSString *outputURL = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,str_filedirect];
                    NSFileManager *manager = [NSFileManager defaultManager];
                    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
                    outputURL = [outputURL stringByAppendingPathComponent:filename];
                    // Remove Existing File
                    [manager removeItemAtPath:outputURL error:nil];
                    NSURL *url = [NSURL fileURLWithPath:outputURL];
                    NSError *error;
                    if([weakSelf exportDataToURL:url error:&error asset:asset]){
                        QKVideoBean *bean = [QKVideoBean getVideoByAddress:address];
                        bean.type = fileState;
                        [array addObject:bean];
                    }
                    
                }else{
                    QKVideoBean *video = [[QKVideoBean alloc] init];
                    video.type = @"localvideo";
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    
                    NSString *displayname = [NSString stringWithFormat:@"%@%@.mp4",rep.filename,[self dealTimeWith:([[NSDate date] timeIntervalSince1970]*1000) withType:10]];
                    
                    video.displayname = displayname;
                    
                    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:rep.url options:opts];
                    video.asset = myAsset;
                    
                    [array addObject:video];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weakSelf.selectVideos){
                    weakSelf.selectVideos(array);
                }
                [weakSelf cancelView:nil];
                [weakSelf.lock unlock];
                [clipPubthings hideHUD];
            });
        });
        
    }
    
}


- (BOOL) exportDataToURL: (NSURL*) fileURL error: (NSError**) error asset:(ALAsset*)asset

{
    [self exportDataToURL1:fileURL error:error asset:asset];
    return YES;
    NSString *type = [asset valueForProperty:ALAssetPropertyType];
    
    if ([type isEqual:ALAssetTypePhoto]) {
        [[NSFileManager defaultManager] createFileAtPath:[fileURL path] contents:nil attributes:nil];
        
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileURL error:error];
        
        if (!handle) {
            
            return NO;
            
        }
        
        UIImage *original=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImageOrientation imageOrientation=original.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp)
        {
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(original.size);
            [original drawInRect:CGRectMake(0, 0, original.size.width, original.size.height)];
            original = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
        }
        NSData *imageData = UIImageJPEGRepresentation(original, 1.0);
        [handle writeData:imageData];
        
    }else{

        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSURL *url = rep.url;
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSLog(@"url = %@",url);
        
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        __block BOOL finished = NO;
        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
            
            NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
            float with = videoTrack.naturalSize.width;
            float height = videoTrack.naturalSize.height;
            NSString *persetName = AVAssetExportPresetHighestQuality;
            if(with > 1920 || height > 1920){
                persetName = AVAssetExportPreset1920x1080;
            }
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:persetName];
            
            NSLog(@"fileURL = %@",fileURL);
            
            exportSession.outputURL = fileURL;
            
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            exportSession.shouldOptimizeForNetworkUse = YES;
            WS(weakSelf);
            [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
             
             {
                 
                 NSLog(@"error:%@",exportSession.error);
                 switch (exportSession.status) {
                         
                     case AVAssetExportSessionStatusUnknown:
                         
                         NSLog(@"AVAssetExportSessionStatusUnknown");
                         
                         break;
                         
                     case AVAssetExportSessionStatusWaiting:
                         
                         NSLog(@"AVAssetExportSessionStatusWaiting");
                         
                         break;
                         
                     case AVAssetExportSessionStatusExporting:
                         
                         NSLog(@"AVAssetExportSessionStatusExporting");
                         
                         break;
                         
                     case AVAssetExportSessionStatusCompleted:
                         
                         NSLog(@"AVAssetExportSessionStatusCompleted");
                         
                         break;
                         
                     case AVAssetExportSessionStatusFailed:
                         
                         NSLog(@"AVAssetExportSessionStatusFailed");
                         [weakSelf exportDataToURL1:fileURL error:error asset:asset];
                         break;
                         
                 }
                 finished = YES;
             }];
            
        }
        do {
            [NSThread sleepForTimeInterval:0.1];
        } while (!finished);
    }
    return YES;
    
}



- (BOOL) exportDataToURL1: (NSURL*) fileURL error: (NSError**) error asset:(ALAsset*)asset

{
    
    
    [[NSFileManager defaultManager] createFileAtPath:[fileURL path] contents:nil attributes:nil];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileURL error:error];
    
    if (!handle) {
        
        return NO;
        
    }
    
    
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    const int bufferSize = ReadBufferSize;
    
    Byte *buffer =(Byte*)malloc(bufferSize);
    
    NSUInteger offset = 0, bytesRead = 0;
    
    
    
    do {
        
        @try {
            
            bytesRead = [rep getBytes:buffer fromOffset:offset length:bufferSize error:error];
            
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            
            offset += bytesRead;
            
        } @catch (NSException *exception) {
            
            free(buffer);
            
            return NO;
            
        }
        
    } while (bytesRead > 0);
    
    free(buffer);
    
    return YES;
    
}

//生成一个随机的32为字符串，当做数据库唯一标示
-(NSString*)getLiveuuid
{
    NSString *str =nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [[NSDate alloc] init];
    str = [formatter stringFromDate:date];
    
    str = [NSString stringWithFormat:@"%@_%@",str,[self ret32bitString]];
    
    return str;
}


-(NSString *)ret32bitString

{
    
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

-(NSString*)getFilename
{
    int time = [self getRandomNumber:10000000 to:99999999];
    NSString *str =nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [[NSDate alloc] init];
    str = [formatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@%d",str,time];
}

-(int)getRandomNumber:(int)from to:(int)to

{
    srand((unsigned)time(0)); //不加这句每次产生的随机数不变
    return (int)(from + (arc4random() % (to - from + 1)));
    
}

-(NSString*)dealTimeWith:(long long)time withType:(NSInteger)type
{
    //把毫秒数转换为时间字符串
    NSString *dateString = @"";
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time/1000.0] ;
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    dateString = [formatter stringFromDate:date];
    
    return dateString;
}

@end

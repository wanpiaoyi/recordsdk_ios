//
//  RecordData.m
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import "RecordData.h"
#import "ImageLocalSave.h"
#import <sys/utsname.h>
#import "HeaderFile.h"
@interface RecordData ()
@property (weak, atomic) UIImageView *nowImage;
@property (strong, nonatomic) NSLock *lock;

@end

@implementation RecordData
static NSLock *lock1;
static NSLock *lock2;
static NSLock *lock3;
static long long lockCount = 0;
-(id)init
{
    self = [super init];
    if (self)
    {
        self.Select = NO;
        if(!lock1){
            lock1 = [[NSLock alloc] init];
        }
        if(!lock2){
            lock2 = [[NSLock alloc] init];
        }
        if(!lock3){
            lock3 = [[NSLock alloc] init];
        }
        _lock = [[NSLock alloc] init];
        _address = @"";
        _fileName = @"";
        self.clipStartTime = 0;
        self.isCrossScreen = 0;
        self.deleteEndEdict = YES;
    }
    return self;
}

+(RecordData*)getVideoByAddress:(NSString*)address{
    RecordData *video = [[RecordData alloc] init];
    NSArray *array = [address componentsSeparatedByString:@"/"];
    NSString *filename = array[array.count - 1];
    
    NSString * uploadfileName = filename;
    NSArray *arr = [filename componentsSeparatedByString:@"."];
    if(arr.count>1){
        uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",arr[0],arr[arr.count-1]];
    }
    NSNumber *start_time = @((NSInteger)[[NSDate date] timeIntervalSince1970]);
    
    video.activityId = @(0);
    video.start_time = start_time;
    video.address = address;
    video.fileName = filename;
    video.displayname = filename;
    video.uploadfileName = uploadfileName;
    return video;
}




-(void)setAddress:(NSString *)address{
    _address = address;
    //    NSLog(@"%@",address);
    
    if(_asset){
        return;
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,address];
    NSURL *url = [NSURL fileURLWithPath:path];
    if(url == nil){
        return;
    }
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                          
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:url options:opts];
    _asset = myAsset;
}


-(void)setImageView:(UIImageView*)img{
    @autoreleasepool {
        
        if(_asset == nil||img==nil){
            return;
        }
        NSInteger tag = -1;
        if(self.liveid != nil){
            tag = [self.liveid integerValue];
        }else{
            tag = [self getRandomNumber:0 to:99999999];
        }
        _nowImage = img;
        img.tag = tag;
        ImageLocalSave *imgLocalSave = [ImageLocalSave defaultImageLocalSave];
        
        UIImage *_clipImage = [imgLocalSave.cache objectForKey:_address];
        if(_clipImage){
            img.image = _clipImage;
            return;
        }
        WS(weakSelf);

        if([self.type isEqualToString:imageType]||[self.type isEqualToString:selectFromPhotoImg]){
            if([_lock tryLock]){
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.address];
                    
                    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
                    
                    UIImage *image = [UIImage imageWithData: imageData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        float scale = 0.4;
                        if(image.size.width >512 ||image.size.height >512){
                            scale = 0.2;
                        }
                        UIImage *clipImage = [RecordData scaleImage:image toScale:scale];
                        if(clipImage != nil){
                            [imgLocalSave.cache setObject:clipImage forKey:weakSelf.address];
                            
                        }
                        if(weakSelf.nowImage != nil && (weakSelf.nowImage.tag == -1 || weakSelf.nowImage.tag == tag)){
                            weakSelf.nowImage.image = clipImage;
                        }
                        [weakSelf.lock unlock];
                    });
                });
            }
            return;
        }
        
        if(self.finish_localImgaddress !=nil &&self.finish_localImgaddress.length > 0){
            if([_lock tryLock]){
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.finish_localImgaddress];
                    
                    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
                    UIImage *image = [UIImage imageWithData: imageData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *clipImage = image;
                        [imgLocalSave.cache setObject:clipImage forKey:weakSelf.address];
                        
                        if(weakSelf.nowImage != nil && (weakSelf.nowImage.tag == -1 || weakSelf.nowImage.tag == tag)){
                            weakSelf.nowImage.image = clipImage;
                        }
                        [weakSelf.lock unlock];
                    });
                });
            }
            return;
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if([weakSelf.lock tryLock]){
                @autoreleasepool {
                    
                    NSInteger count = [weakSelf recordTryLocked];
                    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:_asset];
                    assetImageGenerator.appliesPreferredTrackTransform = YES;
                    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
                    CGImageRef thumbnailImageRef = NULL;
                    NSError *thumbnailImageGenerationError = nil;
                    
                    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake((1+self.clipStartTime)*60, 60) actualTime:NULL error:&thumbnailImageGenerationError];
                    UIImage *image = nil;
                    if(thumbnailImageRef != NULL){
                        image = [UIImage imageWithCGImage:thumbnailImageRef];
                        float scale = 0.4;
                        if(image.size.width >512 ||image.size.height >512){
                            scale = 0.2;
                        }
                        image = [RecordData scaleImage:image toScale:scale];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            
                            if(thumbnailImageRef == NULL){
                                weakSelf.nowImage.image = [UIImage imageNamed:@""];
                            }else{
                                UIImage *clipImage = image;
                                [imgLocalSave.cache setObject:clipImage forKey:weakSelf.address];
                                
                                if(weakSelf.nowImage != nil && (weakSelf.nowImage.tag == -1 || weakSelf.nowImage.tag == tag)){
                                    weakSelf.nowImage.image = clipImage;
                                }
                                CGImageRelease(thumbnailImageRef);
                                
                            }
                        };
                    });
                    [weakSelf.lock unlock];
                    
                    [weakSelf recordUnLocked:count];
                };
            }
        });
    };
}

-(NSInteger)recordTryLocked{
    if([lock1 tryLock]){
        return 1;
    }
    if([lock2 tryLock]){
        return 2;
    }
    if([lock3 tryLock]){
        return 3;
    }
    lockCount++;
    switch (lockCount%3) {
        case 0:
            [lock1 lock];
            return 1;
            break;
        case 1:
            [lock2 lock];
            return 2;
            break;
        case 2:
            [lock3 lock];
            return 3;
            break;
            
        default:
            break;
    }
    [lock1 lock];
    return 1;
}

-(void)recordUnLocked:(NSInteger)locktag{
    switch (locktag) {
        case 1:
            [lock1 unlock];
            break;
        case 2:
            [lock2 unlock];
            break;
        case 3:
            [lock3 unlock];
            break;
            
        default:
            break;
    }
}

-(NSString*)time{
    if((_time == nil || [_time isEqualToString:@"00:00:00"]||[_time isEqualToString:@"00:00:01"])&&([self isVideo])){
        
        AVAsset *asset = _asset;
        if(asset == nil){
            NSString *addr_path = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.address];
            NSURL *url = [NSURL fileURLWithPath:addr_path];
            asset = [AVAsset assetWithURL:url];
        }
        if(asset == nil){
            return @"00:00:00";
        }
        NSInteger duration = asset.duration.value / asset.duration.timescale; //视频总时间
        _time = [self compareCurrentTime:duration];
    }
    return _time;
}

-(BOOL)isVideo{
    if([self.type isEqualToString:liveType]||[self.type isEqualToString:selectFromPhotoVideo]||[self.type isEqualToString:localRecordType]||[self.type isEqualToString:clipType]){
        return YES;
    }
    return NO;
}


//-(BOOL)isText{
//    if([self.type isEqualToString:textType]){
//        return YES;
//    }
//    return NO;
//}


-(BOOL)isImage{
    if([self.type isEqualToString:selectFromPhotoImg] || [self.type isEqualToString:imageType]){
        return YES;
    }
    return NO;
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
-(void)setClipStartTime:(double)clipStartTime{
    if(clipStartTime > 1){
        clipStartTime = clipStartTime - 1;
    }else{
        clipStartTime = 0;
    }
    _clipStartTime = clipStartTime;
}

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
    else if(60 <= timeInterval)
    {
        NSInteger second = ((int)timeInterval)%60;
        NSInteger min = ((int)timeInterval)/60%60;
        NSInteger hour = ((int)timeInterval)/3600;
        NSString *str_sec = [NSString stringWithFormat:@"0%ld",second];
        NSString *str_min = [NSString stringWithFormat:@"0%ld",min];
        NSString *str_hour = [NSString stringWithFormat:@"0%ld",hour];
        
        if(second >= 10){
            str_sec = [NSString stringWithFormat:@"%ld",second];
            
        }
        
        if(min >= 10){
            str_min = [NSString stringWithFormat:@"%ld",min];
        }
        if(hour >= 10){
            str_hour = [NSString stringWithFormat:@"%ld",hour];
        }
        
        
        
        result = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_min,str_sec];
        
    }
    
    return  result;
}

//-(void)setDisplayname:(NSString *)displayname{
//    _displayname = @"好人";
//}
//-(void)setActivityId:(NSNumber *)activityId{
//    _activityId = @(1500286182524986);
//}

-(long)filesize{
    NSString *filepath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,_address];
    long temp = 0;
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filepath])
    {
        temp = [[manager attributesOfItemAtPath:filepath error:nil] fileSize];
        //        return (long)temp;
    }
    return temp;
}

-(void)saveImageAddress{
    
    if((self.finish_localImgaddress == nil || self.liveid == nil) && [self.type isEqualToString:selectFromPhotoVideo]){
        if(self.displayname == nil){
            self.finish_localImgaddress = [NSString stringWithFormat:@"localImage/%.0lf%d.jpg",[[NSDate date] timeIntervalSince1970],[self getRandomNumber:10000000 to:99999999]];
            
        }else{
            self.finish_localImgaddress = [NSString stringWithFormat:@"localImage/%@%d.jpg",[self.displayname stringByReplacingOccurrencesOfString:@"." withString:@"_"],[self getRandomNumber:10000000 to:99999999]];
        }
        NSString *path = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.finish_localImgaddress];
        NSData *imageData = nil;
        ImageLocalSave *imgLocalSave = [ImageLocalSave defaultImageLocalSave];
        
        UIImage *_clipImage = [imgLocalSave.cache objectForKey:self.liveid];
        
        if(_clipImage){
            imageData = UIImageJPEGRepresentation(_clipImage, 1.0);
        }else{
            AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:_asset];
            assetImageGenerator.appliesPreferredTrackTransform = YES;
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            CGImageRef thumbnailImageRef = NULL;
            NSError *thumbnailImageGenerationError = nil;
            
            thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake((1+self.clipStartTime)*60, 60) actualTime:NULL error:&thumbnailImageGenerationError];
            if(thumbnailImageRef == NULL){
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(5, 5), NO,1);
                
                
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                imageData = UIImageJPEGRepresentation(image, 1.0);
                
            }else{
                UIImage *image = [UIImage imageWithCGImage:thumbnailImageRef];
                float scale = 0.4;
                if(image.size.width >512 ||image.size.height >512){
                    scale = 0.2;
                }
                image = [RecordData scaleImage:image toScale:scale];
                
                CGImageRelease(thumbnailImageRef);
                imageData = UIImageJPEGRepresentation(image, 1.0);
                
            }
            
        }
        [imageData writeToFile:path atomically:YES];
        
    }
}


-(UIImage*)getImage{
    @autoreleasepool {
        UIImage *img;
        if(_asset == nil){
            return nil;
        }
        NSInteger tag = -1;
        if(self.liveid != nil){
            tag = [self.liveid integerValue];
        }
        ImageLocalSave *imgLocalSave = [ImageLocalSave defaultImageLocalSave];
        
        UIImage *_clipImage = [imgLocalSave.cache objectForKey:_address];
        if(_clipImage){
            img = _clipImage;
            return img;
        }
        WS(weakSelf);
        
        if([self.type isEqualToString:selectFromPhotoImg]||[self.type isEqualToString:imageType]){
            if([_lock tryLock]){
                @autoreleasepool {
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.address];
                    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
                    UIImage *image = [UIImage imageWithData: imageData];
                    img = image;
                    [weakSelf.lock unlock];
                }
                
            }
            return img;
        }
        
        
        if([_lock tryLock]){
            @autoreleasepool {
                NSInteger count = [weakSelf recordTryLocked];
                AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:_asset];
                assetImageGenerator.appliesPreferredTrackTransform = YES;
                assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
                CGImageRef thumbnailImageRef = NULL;
                NSError *thumbnailImageGenerationError = nil;
                
                thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(1*60, 60) actualTime:NULL error:&thumbnailImageGenerationError];
                UIImage *image = nil;
                if(thumbnailImageRef != NULL){
                    image = [UIImage imageWithCGImage:thumbnailImageRef];
                }
                
                img = image;
                
                CGImageRelease(thumbnailImageRef);
                [weakSelf.lock unlock];
                [weakSelf recordUnLocked:count];
            }
        }
        return img;
    }
}

-(int)getRandomNumber:(int)from to:(int)to

{
    srand((unsigned)time(0)); //不加这句每次产生的随机数不变
    return (int)(from + (arc4random() % (to - from + 1)));
    
}

-(BOOL)checkisCrossScreen{
    if([self isImage]){
        if(self.isCrossScreen > 0){
            switch (self.isCrossScreen) {
                case 1:
                    return YES;
                case 2:
                    return NO;
            }
        }
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",pressfixPathAddress,self.address];
        
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        
        UIImage *image = [UIImage imageWithData: imageData];
        if(image.size.width > image.size.height){
            self.isCrossScreen = 1;
            return YES;
        }
        self.isCrossScreen = 2;
        return NO;
    }
    if(self.asset == nil){
        return NO;
    }
    
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        return [self AssetCheckIsCrossScreen:videoTrack];
    }
    return NO;
    
}



-(double)getMovieScale{
    if(self.asset == nil){
        //录像保存路径
        NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@",pressfixPath,self.address];
        NSURL *url = [NSURL fileURLWithPath:path];
        if(url == nil){
            return 1;
        }
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                              
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:url options:opts];
        self.asset = myAsset;
        
    }
    if(self.asset == nil){
        return 1;
    }
    
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        return [self assetGetScale:videoTrack];
    }
    return 1;
}

-(NSInteger)canEdict{
    if(self.asset == nil){
        //录像保存路径
        NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@",pressfixPath,self.address];
        NSURL *url = [NSURL fileURLWithPath:path];
        if(url == nil){
            return -1;
        }
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                              
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:url options:opts];
        self.asset = myAsset;
        
    }
    if([self isImage]){
        return 1;
    }else if(self.asset == nil){
        return -1;
    }
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        float with = videoTrack.naturalSize.width;
        float height = videoTrack.naturalSize.height;
        if(with > 1920 || height > 1920){
            if([self isIPhone8]){
                return 1;
            }else{
                return 0;
            }
        }
        return 1;
    }
    return -1;
}



-(BOOL)AssetCheckIsCrossScreen:(AVAssetTrack *)track{
    float with = track.naturalSize.width;
    float height = track.naturalSize.height;
    
    CGAffineTransform t = track.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        float between = height;
        height = with;
        with = between;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        float between = height;
        height = with;
        with = between;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        
    }
    if(with > height){
        return YES;
    }
    return  NO;
}
-(double)assetGetScale:(AVAssetTrack *)track{
    float with = track.naturalSize.width;
    float height = track.naturalSize.height;
    
    CGAffineTransform t = track.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        float between = height;
        height = with;
        with = between;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        float between = height;
        height = with;
        with = between;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        
    }
    
    return  with*1.0 / height;
}


-(BOOL)isIPhone8{
    
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
    NSArray *array = [platform componentsSeparatedByString:@","];
    if(array != nil && array.count > 0){
        NSString *num = [array[0] stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        if([num integerValue] >= 10){
            return YES;
        }
    }
    
    return NO;
}


@end

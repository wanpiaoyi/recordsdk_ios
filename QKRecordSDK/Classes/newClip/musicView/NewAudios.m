//
//  AudioGet.m
//  QukanTool
//
//  Created by 袁儿宝贝 on 2019/10/29.
//  Copyright © 2019 yang. All rights reserved.
//

#import "NewAudios.h"
#import "SelectMusicController.h"
#import "ClipPubThings.h"
#import <QKLiveAndRecord/QKRecordMP3ToPcm.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QKVideoBean.h"
@implementation NewAudios
-(void)getNewAudios:(NSMutableDictionary *)dic{
     
    WS(weakSelf);
    NSArray *types = @[(__bridge NSString *)kUTTypeMP3]; // 可以选择的文件类型
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [clipPubthings.nav presentViewController:documentPicker animated:YES completion:nil];

    
//    SelectMusicController *music = [[SelectMusicController alloc] init];
//    music.playMusic = ^(QKMusicBean * _Nonnull bean) {
//        if(weakSelf.getAudio != nil){
//            weakSelf.getAudio(bean);
//        }
//    };
//    [clipPubthings.nav pushViewController:music animated:YES];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    NSLog(@"url:%@",url);
    [self selectMusic:url];
}

-(NSArray*)getLocalAudios{
    NSMutableArray *musics = [NSMutableArray new];
    NSUserDefaults *application = [NSUserDefaults standardUserDefaults];
    NSArray *array = [application objectForKey:@"local_pcmmusic"];
    for(NSDictionary *dic in array){
        NSString *address = dic[@"address"];
        NSString *name = dic[@"name"];
        QKMusicBean *bean = [[QKMusicBean alloc] init];
        bean.address = address;
        bean.name = name;
        [musics addObject:bean];
    }
    return musics;
}
/*
 把Mp3转成PCM
 */
-(void)Mp3ToPcm:(NSString*)mp3Path pcmPath:(NSString*)pcmPath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      OSStatus state = [QKRecordMP3ToPcm mixAudio:mp3Path toFile:pcmPath preferedSampleRate:44100];
      if(state == noErr){
          NSLog(@"setMp3Path success");
      }else{
          NSLog(@"MP3存在异常");
      }
    });
}



-(IBAction)selectMusic:(NSURL*)url{
    [clipPubthings showHUD_Login:@"处理中"];
    NSString *path = [url path];
    QKVideoBean *song = [QKVideoBean getVideoByAddress:[url path]];
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *musics = [NSMutableArray new];
        NSUserDefaults *application = [NSUserDefaults standardUserDefaults];
        NSArray *array = [application objectForKey:@"local_pcmmusic"];
        if(array != nil){
            musics = [NSMutableArray arrayWithArray:array];
        }
        NSString *sessionId = [[NSUUID UUID] UUIDString];
        
        NSString *outPath = [NSString stringWithFormat:@"%@/musicPcm/%@.pcm",clipPubthings.pressfixPath,sessionId];
        NSString *address = [NSString stringWithFormat:@"musicPcm/%@.pcm",sessionId];
        NSString *nowMusicPath = [url path];
        BOOL toPcm = true;
        for(NSDictionary *dic in musics){
            NSString *path = dic[@"address"];
            if(path != nil && [path isEqualToString:address]){
                outPath = [NSString stringWithFormat:@"%@/musicPcm/%@1.pcm",clipPubthings.pressfixPath,sessionId];
                address = [NSString stringWithFormat:@"musicPcm/%@1.pcm",sessionId];
            }
            NSString *musicPath = dic[@"musicPath"];
            if(musicPath != nil && [musicPath isEqualToString:nowMusicPath]){
                toPcm = false;
                address = path;
                break;
            }
        }

        if(toPcm){
            NSLog(@"toPcm");
            [QKRecordMP3ToPcm mixAudioWithUrl:url toFile:outPath preferedSampleRate:44100];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:address forKey:@"address"];
            [dic setObject:nowMusicPath forKey:@"musicPath"];
            if(song.fileName != nil){
                [dic setObject:song.fileName forKey:@"name"];
            }else{
                [dic setObject:@"未知" forKey:@"name"];
            }
            [musics addObject:dic];
            [application setObject:musics forKey:@"local_pcmmusic"];
        }
        QKMusicBean *bean = [[QKMusicBean alloc] init];
        bean.address = address;
        bean.name = song.fileName;
        NSLog(@"%@ %@",song.fileName,address);

        dispatch_async(dispatch_get_main_queue(), ^{
            [clipPubthings hideHUD];

            if(weakSelf.getAudio){
                weakSelf.getAudio(bean);
            }
        });
    });
}

@end

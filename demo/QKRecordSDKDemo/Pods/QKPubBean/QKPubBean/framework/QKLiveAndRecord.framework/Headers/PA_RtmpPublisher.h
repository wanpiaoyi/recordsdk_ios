//
//  PA_RtmpPublisher.h
//  IPCameraSDK
//
//  Created by wang macmini on 15-1-4.
//  Copyright (c) 2015年 ReNew. All rights reserved.
//

#ifndef IPCameraSDK_PA_RtmpPublisher_h
#define IPCameraSDK_PA_RtmpPublisher_h

#include "rtmp.h"

@interface PA_RtmpPublisher : NSObject
{
    RTMP*    m_pstRtmp;
    int     m_bSpsPpsSent;
    int     m_bAACSpecSent;
    
    unsigned int  m_uiTimesTamp;
    volatile int m_iTcpNoDelayOn;
    
    unsigned int m_uiVideoTime;
    unsigned int m_uiAudioTime;
    
    unsigned int m_uiVideoDiff;
    unsigned int m_uiAudioDiff;
}

-(BOOL) Connect :(char*) strUrl justAudio:(BOOL)justAudio;
-(void) Close;

-(BOOL) isConnected;

//-(BOOL) sendSPSAndPPS : (char*) pSPS SPSLen:(int) iSPSLen PPS : (char*) pPPS PPSLen :(int) iPPSLen;
//-(BOOL) sendH264 :(char*) pBuffer  Length:(int)iLength IsKeyFrame:(bool) bIsKeyFrame TimesTemp :(int)iTimestamp ;
//-(BOOL) sendAACConfig :(char*) pBuffer Length:(int) iLength;
//-(BOOL) sendAAC :(char*) pBuffer Length:(int) iLength TimesTemp :(int)iTimestamp;

-(BOOL) sendAACFrame :(char*) pBuffer Length:(int) iLength TimesTemp :(unsigned int)iTimestamp;
-(BOOL) sendH264Frame :(char*) pBuffer Length:(int) iLength TimesTemp :(unsigned int)iTimestamp FrameType :(int)iFrameType CTimesTemp :(int)icTimesTemp;

-(BOOL) sendFlvPacket : (int) iPacketType DataBody :(char*) pDataBody SizeBody:(int)iSizeBody TimesTemp :(unsigned int)iTimestamp HeaderType:(int) headertype;
@end
#endif

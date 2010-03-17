//-----------------------------------------------------------------------------
// name: mo_audio.h
// desc: MoPhO audio layer
//       - adapted from the smule audio layer & library (SMALL)
//         (see original header below)
//
// authors: Ge Wang (ge@ccrma.stanford.edu | ge@smule.com)
//          Spencer Salazar (spencer@smule.com)
//    date: October 2009
//    version: 0.2
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// name: small.h (original)
// desc: the smule audio layer & library (SMALL)
//
// created by Ge Wang on 6/27/2008
// re-implemented using Audio Unit Remote I/O on 8/12/2008
// updated for iPod Touch by Spencer Salazar and Ge wang on 8/10/2009
//
// copyright 2008 Smule. All rights reserved.
//-----------------------------------------------------------------------------
#ifndef __MO_AUDIO_H__
#define __MO_AUDIO_H__

// headers
#include "mo_def.h"
#include <AudioUnit/AudioUnit.h>

// type definition for audio callback function
typedef void (* MoCallback)( Float32 * buffer, UInt32 numFrames, void * userData );

// sample (TODO: verify consistent with MoAudio assumptions)
#define SAMPLE Float32


//-----------------------------------------------------------------------------
// name: struct MoAudioUnitInfo (was: SMuleAudioUnitInfo)
// desc: a data structure to manage information needed by audio unit
//-----------------------------------------------------------------------------
struct MoAudioUnitInfo
{
    AudioStreamBasicDescription     m_dataFormat;
    UInt32                          m_bufferSize; // # of frames
    UInt32                          m_bufferByteSize;
    Float32 *                       m_ioBuffer;
    bool                            m_done;
    
    // constructor
    MoAudioUnitInfo()
    {
        m_bufferSize = 4096; // max
        m_bufferByteSize = 0;
        m_ioBuffer = NULL;
        m_done = false;
    }
    
    // desctructor
    ~MoAudioUnitInfo()
    {
        m_bufferSize = 4096;
        m_bufferByteSize = 0;
        SAFE_DELETE_ARRAY( m_ioBuffer );
    }
};




//-----------------------------------------------------------------------------
// name: class MoAudicle (was: SMALL)
// desc: MoPhO Audio API (was: SMule Audio Layer & Library)
//-----------------------------------------------------------------------------
class MoAudio
{
public:
    static bool init( Float64 srate, UInt32 frameSize, UInt32 numChannels );
    static bool start( MoCallback callback, void * bindle );
    static void stop();
    static void shutdown();
    static Float64 getSampleRate() { return m_srate; }
    static void vibrate();
    
public: // sketchy public
    static void checkInput();

protected:
    static bool initOut();
    static bool initIn();
    
protected:
    static bool m_hasInit;
    static bool m_isRunning;

public: // ge: making this public was a hack
    static MoAudioUnitInfo * m_info;
    static MoCallback m_callback;
    // static Float32 * m_buffer;
    // static UInt32 m_bufferFrames;
    static AudioUnit m_au;
    static bool m_isMute;
    static bool m_handleInput;
    static Float64 m_hwSampleRate;
    static Float64 m_srate;
    static UInt32 m_frameSize;
    static UInt32 m_numChannels;
    static void * m_bindle;
    
    // audio unit remote I/O
    static AURenderCallbackStruct m_renderProc;
};




#endif

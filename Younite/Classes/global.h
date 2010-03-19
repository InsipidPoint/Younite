/*
 *  global.h
 *  Younite
 *
 *  Created by Ankit Gupta on 3/10/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#ifndef __GLOBAL_H__
#define __GLOBAL_H__

#import "mopho.h"

// defines
#define SRATE 8000
#define FRAMESIZE 256
#define NUM_CHANNELS 2

class Global {
public:
	static bool init();
	static bool playBuffer(Float32 *buffer);
	static void startRecording();
	static void setMode(int _mode);
	static int getMode();
	static int getRecSize();
	static Float32* getRecordingBuffer();
	static void loadPlaybackBuffer(Float32 *m_playbackBuffer, int arrayCount);
	static void startPlayback();
	static void stopPlayback();
	static void tick(Float32 value);

		
public:
	static int mode; // 1 = nothing, 2 = recording, 3 = playing, 4 = exploring
	static const int g_recordingSize;
	static int g_playbackSize;
	static int g_recSize;// True Size of the Recording Buffer
	static Float32 *g_recordingBuffer;
	static Float32 *g_playbackBuffer;
	static int g_index;
	static int g_playbackIndex;
	static int g_playbackLoadHead;

	
public:
	static void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData );

	
};

#endif
/*
 *  global.c
 *  Younite
 *
 *  Created by Ankit Gupta on 3/10/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#include "global.h"

int Global::mode; // 1 = nothing, 2 = recording, 3 = playing, 4 = exploring
const int Global::g_recordingSize = 160000;
int Global::g_playbackSize;
int Global::g_recSize;// True Size of the Recording Buffer
Float32 * Global::g_recordingBuffer;
Float32 * Global::g_playbackBuffer;
int Global::g_index;
int Global::g_playbackIndex;
int Global::g_playbackLoadHead;
stk::JCRev* Global::g_reverb;


// audio cb
void Global::audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{

	for(int i=0; i<numFrames; i++) {
		switch (mode) {
			case 1:
				buffer[2*i] = buffer[2*i+1] = 0;
				break;
			case 2:
				g_recordingBuffer[g_index++] = buffer[2*i];
				buffer[2*i] = buffer[2*i+1] = 0;
				g_recSize++;					
				break;
			case 3:
				if(g_index < g_recSize)
					buffer[2*i] = buffer[2*i + 1] = g_recordingBuffer[g_index++];
				else {
					buffer[2*i] = buffer[2*i + 1] = 0;
					if(mode != 1)
						mode = 1;
				}
				break;
			case 4:
				buffer[2*i] = buffer[2*i + 1] = 0.8*g_reverb->tick(g_playbackBuffer[g_playbackIndex]);
				//g_playbackBuffer[g_playbackIndex] = 0;
				g_playbackIndex++;
				g_playbackIndex = g_playbackIndex%g_playbackSize;
				break;
			default:
				break;
		}
	}
/*
	if(g_isRecording) {
		for(int i=0; i<numFrames; i++) {
			g_recordingBuffer[g_index++] = buffer[2*i];
			buffer[2*i] = buffer[2*i+1] = 0;
			g_recSize++;
		}
	}
	else {
		if(g_isPlaying) {
			for(int i=0; i<numFrames; i++) {
				if(g_index < g_recSize)
					buffer[2*i] = buffer[2*i + 1] = g_recordingBuffer[g_index++];
				else {
					buffer[2*i] = buffer[2*i + 1] = 0;
					g_isPlaying = false;
				}
			}
		}
		else {
			for(int i=0; i<numFrames; i++)
				buffer[2*i] = buffer[2*i + 1] = 0;
		}
		
		
	}
 */
	
}

bool Global::init() {
	// init audio
	bool result = MoAudio::init( SRATE, FRAMESIZE, NUM_CHANNELS );
	if(!result) {
		NSLog(@"Can't Initialize Audio");
		return false;
	}
	else {
		// start
		result = MoAudio::start( Global::audio_callback, NULL );
		if( !result )
		{
			NSLog(@"Can't Start Audio");
			return false;
		}			
		Global::mode = 1;
		//Global::g_recordingSize = 160000;
		Global::g_playbackSize = g_recordingSize*5;
		Global::g_recSize = 0;// True Size of the Recording Buffer
		Global::g_recordingBuffer = (Float32 *)malloc(sizeof(Float32)*g_recordingSize) ;
		Global::g_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*g_playbackSize) ;
		Global::g_index = 0;		
		Global::g_playbackIndex = 0;		
		Global::g_playbackLoadHead = 0;	
		Global::g_reverb = new stk::JCRev();
		g_reverb->setEffectMix(0.08);
	}
	return true;
}

void Global::startRecording() {
	g_index = 0;
	g_recSize = 0;
	mode = 2;	
}

void Global::startPlayback() {
	mode = 4;	
}

void Global::stopPlayback() {
	mode = 1;
	g_playbackIndex = 0;
	g_playbackLoadHead = 0;
}

void Global::setMode(int _mode) {
	mode = _mode;
}
int Global::getMode() {
	return mode;
}

int Global::getRecSize() {
	return g_recSize;
}
Float32* Global::getRecordingBuffer() {
	return g_recordingBuffer;
}
void Global::loadPlaybackBuffer(Float32 *m_playbackBuffer, int arrayCount) {
	for(int i=0;i<arrayCount; i++) {
		g_playbackBuffer[g_playbackLoadHead++] = m_playbackBuffer[i];
		g_playbackLoadHead %= g_playbackSize;
		if(g_playbackLoadHead == 0)
			NSLog(@"Rounded Back");
	}
}
void Global::tick(Float32 value) {
	g_playbackBuffer[g_playbackLoadHead++] = value;
	if (g_playbackLoadHead == 1) {
		NSLog(@"Pushed %f onto %d",value, 0);
	}
	g_playbackLoadHead %= g_playbackSize;
	if(g_playbackLoadHead == 0) {
		NSLog(@"Rounded Back");
	}
}

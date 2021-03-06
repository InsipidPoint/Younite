//
//  GlobeView.h
//  Younite
//
//  Created by Shiwei Song on 3/17/10.
//  Copyright 2010 Baren Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ES1Renderer.h"

@interface GlobeView : UIView {
@private
	ES1Renderer *renderer;
	
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *animationTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void) startAnimation;
- (void) stopAnimation;
- (void) drawView:(id)sender;
- (void) playingMessage:(NSDictionary *)message;

@end
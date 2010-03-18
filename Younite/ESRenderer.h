//
//  ESRenderer.h
//  HellOGLES2
//
//  Created by Ge Wang on 1/20/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end

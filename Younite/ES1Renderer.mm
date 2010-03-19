//
//  ES1Renderer.m
//  TexMess
//
//  Created by Ge Wang on 1/25/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "ES1Renderer.h"
#import "mo_gfx.h"
#import "mo_touch.h"
#import <vector>

using namespace std;

// global
GLuint g_texture[2];

// =========================================================
void getSolidSphere(GLfloat **triangleStripVertexHandle,
                    GLfloat **triangleStripNormalHandle,
                    GLfloat **triangleStripTexHandle,
                    GLuint *triangleStripVertexCount,
                    GLfloat **triangleFanVertexHandle,
                    GLfloat **triangleFanNormalHandle, 
                    GLfloat **triangleFanTexHandle, 
                    GLuint *triangleFanVertexCount,         // On return, will hold the number of vertices contained in
                    GLfloat radius,                         // The radius of the circle to be drawn
                    GLuint slices,                          // The number of slices, determines vertical "resolution"
                    GLuint stacks)                          // the number of stacks, determines horizontal "resolution"
// =========================================================
{
    
    GLfloat rho, drho, theta, dtheta;
    GLfloat x, y, z;
    GLfloat s, ds;
    GLfloat nsign = 1.0f;
    drho = M_PI / (GLfloat) stacks;
    dtheta = 2.0 * M_PI / (GLfloat) slices;
    
    GLfloat *triangleStripVertices, *triangleFanVertices;
    GLfloat *triangleStripNormals, *triangleFanNormals;
    GLfloat *triangleStripTex, *triangleFanTex;
    
    // Calculate the Triangle Fan for the endcaps
    *triangleFanVertexCount = slices+2;
    triangleFanVertices = (GLfloat*)calloc(*triangleFanVertexCount, sizeof(GLfloat)*3);
    triangleFanTex = (GLfloat*)calloc(*triangleFanVertexCount, sizeof(GLfloat)*2);
    triangleFanVertices[0] = 0.0;
    triangleFanVertices[1] = 0.0; 
    triangleFanVertices[2] = nsign * radius;
    int counter = 1;
    for (int j = 0; j <= slices; j++) 
    {
        theta = (j == slices) ? 0.0 : j * dtheta;
        x = -sin(theta) * sin(drho);
        y = cos(theta) * sin(drho);
        z = nsign * cos(drho);
        
        triangleFanTex[counter*2] = theta/(2*M_PI);
        triangleFanTex[counter*2+1] = drho/M_PI;
        
        triangleFanVertices[counter*3] = x * radius;
        triangleFanVertices[counter*3+1] = y * radius;
        triangleFanVertices[counter++*3+2] = z * radius;
    }
    
    
    // Normals for a sphere around the origin are darn easy - just treat the vertex as a vector and normalize it.
    triangleFanNormals = (GLfloat*)malloc(*triangleFanVertexCount * sizeof(GLfloat)*3);
    memcpy(triangleFanNormals, triangleFanVertices, *triangleFanVertexCount * sizeof(GLfloat)*3);
    for (int i = 0; i < *triangleFanVertexCount; i++) {
        double x = triangleFanNormals[i*3], y = triangleFanNormals[i*3+1], z = triangleFanNormals[i*3+2];
        double mag = sqrt(x*x+y*y+z*z);
        triangleFanNormals[i*3] /= mag;
        triangleFanNormals[i*3+1] /= mag;
        triangleFanNormals[i*3+2] /= mag;
    }
    
    // Calculate the triangle strip for the sphere body
    *triangleStripVertexCount = (slices + 1) * 2 * stacks;
    triangleStripVertices = (GLfloat*)calloc(*triangleStripVertexCount, sizeof(GLfloat)*3);
    triangleStripTex = (GLfloat*)calloc(*triangleStripVertexCount, sizeof(GLfloat)*2);
    counter = 0;
    for (int i = 0; i < stacks; i++) {
        rho = i * drho;
        
        s = 0.0;
        for (int j = 0; j <= slices; j++) 
        {
            theta = (j == slices) ? 0.0 : j * dtheta;
            x = -sin(theta) * sin(rho);
            y = cos(theta) * sin(rho);
            z = nsign * cos(rho);
            
            triangleStripTex[counter*2] = theta/(2*M_PI);
            triangleStripTex[counter*2+1] = rho/M_PI;
            
            // TODO: Implement texture mapping if texture used
            //                TXTR_COORD(s, t);
            triangleStripVertices[counter*3] = x * radius;
            triangleStripVertices[counter*3+1] = y * radius;
            triangleStripVertices[counter++*3+2] = z * radius;
            x = -sin(theta) * sin(rho + drho);
            y = cos(theta) * sin(rho + drho);
            z = nsign * cos(rho + drho);
            
            triangleStripTex[counter*2] = theta/(2*M_PI);
            triangleStripTex[counter*2+1] = (rho+drho)/M_PI;
            
            //                TXTR_COORD(s, t - dt);
            s += ds;
            triangleStripVertices[counter*3] = x * radius;
            triangleStripVertices[counter*3+1] = y * radius;
            triangleStripVertices[counter++*3+2] = z * radius;
        }
    }
    
    triangleStripNormals = (GLfloat*)malloc(*triangleStripVertexCount * sizeof(GLfloat)*3);
    memcpy(triangleStripNormals, triangleStripVertices, *triangleStripVertexCount * sizeof(GLfloat)*3);
    for (int i = 0; i < *triangleStripVertexCount; i++) {
        double x = triangleStripNormals[i*3], y = triangleStripNormals[i*3+1], z = triangleStripNormals[i*3+2];
        double mag = sqrt(x*x+y*y+z*z);
        triangleStripNormals[i*3] /= mag;
        triangleStripNormals[i*3+1] /= mag;
        triangleStripNormals[i*3+2] /= mag;
    }
    
    *triangleStripVertexHandle = triangleStripVertices;
    *triangleStripNormalHandle = triangleStripNormals;
    *triangleStripTexHandle = triangleStripTex;
    *triangleFanVertexHandle = triangleFanVertices;
    *triangleFanNormalHandle = triangleFanNormals;
    *triangleFanTexHandle = triangleFanTex;
}


GLfloat    *sphereTriangleStripVertices;
GLfloat    *sphereTriangleStripNormals;
GLfloat    *sphereTriangleStripTex;
GLuint      sphereTriangleStripVertexCount;

GLfloat    *sphereTriangleFanVertices;
GLfloat    *sphereTriangleFanNormals;
GLfloat    *sphereTriangleFanTex;
GLuint      sphereTriangleFanVertexCount;

float g_xrot = 0;
float g_yrot = 0;
float g_zoom = 0;

UITouch *g_touch1, *g_touch2;
UITouch *prev_touch = nil;
CGPoint prev_pos;
double g_distance = 0;
void touchCallback(NSSet *allTouches, UIView * view, const std::map<int, MoTouchTrack> & touchPts, void * data) {	
    NSMutableSet *touches = [NSMutableSet set];
    // remove ended touches
    for (UITouch *t in allTouches) {
        if ([t phase] != UITouchPhaseCancelled && [t phase] != UITouchPhaseEnded) {
            [touches addObject:t];
        }
    }
    
	long count = [touches count];
//    ES1Renderer *r = (ES1Renderer *)data;
    
    if (count == 0) {
        [prev_touch release];
        prev_touch = nil;
        g_touch1 = nil;
        g_touch2 = nil;
        g_distance = 0;
    } else if (count == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint pos = [touch locationInView:view];
        if (touch == prev_touch) {
            g_xrot += (pos.x - prev_pos.x)*0.3;
            g_yrot += (pos.y - prev_pos.y)*0.3;
            prev_pos = pos;
        } else {
            [prev_touch release];
            prev_touch = [touch retain];
            prev_pos = pos;
        }
    } else if (count == 2) {
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        
        CGPoint pt1 = [touch1 locationInView:view];
        CGPoint pt2 = [touch2 locationInView:view];        
        double distance = sqrt(pow(pt1.x-pt2.x,2) + pow(pt1.y-pt2.y,2));
        
        if ([touches containsObject:g_touch1] && [touches containsObject:g_touch2]) {
            if (distance > g_distance) {
                if (g_zoom < 3) {
                    g_zoom += 0.01*(distance-g_distance);
                }
            } else {
                if (g_zoom > -3) {
                    g_zoom -= 0.01*(g_distance-distance);
                }
            }
            g_distance = distance;
        } else {
            g_touch1 = touch1;
            g_touch2 = touch2;
            g_distance = distance;
        }
    }
}

#define CSIZE 15

// collision animation information
struct Collision {
    CGPoint p;
    NSTimeInterval startTime;
    int cause;
    BOOL enabled;
} g_collisions[CSIZE];
unsigned g_cindex = 0;

vector<Message> messages;

// draw
double d = 0;
void draw() {
    static const GLfloat squareVertices[] = {
        -0.5f,  -0.5f,
        0.5f,  -0.5f,
        -0.5f,   0.5f,
        0.5f,   0.5f,
    };
    
    static const GLfloat normals[] = {
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1
    };
    
    static const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
    };
    
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // rotate
    glRotatef(-50+g_yrot, 1, 0, 0);
    glRotatef(110+g_xrot, 0, 0, 1);
    
    // globe
    glPushMatrix();
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, g_texture[0] );
    
        glColor4f(1, 1, 1, 1);
        
        // scale
        glScalef(4+g_zoom, 4+g_zoom, 4+g_zoom);
        
        // vertex
        glEnableClientState(GL_VERTEX_ARRAY );
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
        glVertexPointer(3, GL_FLOAT, 0, sphereTriangleFanVertices);
        glNormalPointer(GL_FLOAT, 0, sphereTriangleFanNormals);
        glTexCoordPointer(2, GL_FLOAT, 0, sphereTriangleFanTex);
        glDrawArrays(GL_LINE_STRIP, 0, sphereTriangleFanVertexCount);
        
        glVertexPointer(3, GL_FLOAT, 0, sphereTriangleStripVertices);
        glNormalPointer(GL_FLOAT, 0, sphereTriangleStripNormals);
        glTexCoordPointer(2, GL_FLOAT, 0, sphereTriangleStripTex);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, sphereTriangleStripVertexCount);
        
        glDisable(GL_TEXTURE_2D);
    glPopMatrix();
    
    for (int i = 0; i < messages.size(); i++) {    
        glPushMatrix();
            if (messages[i].cause == 0) {
                glColor4f(1.0, 0.2, 0.2, 0.05);
            } else if (messages[i].cause == 1) {
                glColor4f(0.2, 1.0, 0.2, 0.05);
            } else {
                glColor4f(0.2, 0.2, 1.0, 0.05);
            }

            glRotatef(messages[i].position.y, 0, 0, 1);
            glRotatef(90-messages[i].position.x, 1, 0, 0);
            glTranslatef(0, 0, 2.0+g_zoom/2.0);
            glScalef(0.03, 0.03, 0.03);
            glVertexPointer(2, GL_FLOAT, 0, squareVertices);
            glNormalPointer(GL_FLOAT, 0, normals);
            glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glPopMatrix();
    }
    
    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
    for (int i = 0; i < CSIZE; i++) {
        // go through each enabled animation
        if (g_collisions[i].enabled) {
            NSTimeInterval diff = current-g_collisions[i].startTime;
            if (diff > 3) {
                g_collisions[i].enabled = NO;
                continue;
            }
            
            if (g_collisions[i].cause == 0) {
                glColor4f(1.0, 0.2, 0.2, 0.8);
            } else if (g_collisions[i].cause == 1) {
                glColor4f(0.2, 1.0, 0.2, 0.8);
            } else {
                glColor4f(0.2, 0.2, 1.0, 0.8);
            }
            
            glEnable(GL_TEXTURE_2D);
            glBindTexture( GL_TEXTURE_2D, g_texture[1] );
            
            glPushMatrix();
            
            glRotatef(g_collisions[i].p.y, 0, 0, 1);
            glRotatef(90-g_collisions[i].p.x, 1, 0, 0);
            glTranslatef(0, 0, 2.0+g_zoom/2.0+diff*.8);
            glScalef(0.03+diff*.5, 0.03+diff*.5, 0.03+diff*.5);
            glVertexPointer(2, GL_FLOAT, 0, squareVertices);
            glNormalPointer(GL_FLOAT, 0, normals);
            glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            glPopMatrix();
        }
    }
}


@implementation ES1Renderer

// Create an ES 1.1 context
- (id) init
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
		{
            [self release];
            return nil;
        }
        
        responseData = [[NSMutableData alloc] init];
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &defaultFramebuffer);
		glGenRenderbuffersOES(1, &colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
	}
    
    // enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    // glBlendFunc( GL_ONE, GL_ZERO );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
    // generate texture name
    glGenTextures( 1, &g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[0]);
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    // load the texture
    MoGfx::loadTexture( @"earthmap1k", @"jpg" );
    
    // generate texture name
    glGenTextures( 2, &g_texture[1] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[1] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    // load the texture
    MoGfx::loadTexture( @"texture", @"png" );
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glDepthMask( GL_TRUE );
    glClearDepthf(1.0f);
    
    glEnable( GL_CULL_FACE );
	glShadeModel( GL_SMOOTH );
    
    getSolidSphere(&sphereTriangleStripVertices, &sphereTriangleStripNormals, &sphereTriangleStripTex, &sphereTriangleStripVertexCount, &sphereTriangleFanVertices, &sphereTriangleFanNormals, &sphereTriangleFanTex, &sphereTriangleFanVertexCount, 0.5, 50, 50);
    
    MoTouch::addCallback( touchCallback, self );
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://youniteapp2.appspot.com/everything"]];
    [[NSURLConnection connectionWithRequest:request delegate:self] retain];
	return self;
}

- (void) playingMessage:(NSDictionary *)message {
    g_collisions[g_cindex].p.x = [[message objectForKey:@"lat"] floatValue];
    g_collisions[g_cindex].p.y = [[message objectForKey:@"lon"] floatValue];
    g_collisions[g_cindex].startTime = [NSDate timeIntervalSinceReferenceDate];
    g_collisions[g_cindex].cause = [[message objectForKey:@"Cause"] hash]%4;
    g_collisions[g_cindex].enabled = YES;
    
    g_cindex = (g_cindex+1)%CSIZE;
    
    NSLog(@"%@", message);
}

- (void) render
{
	// This application only creates a single context which is already set current at this point.
	// This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
	// This application only creates a single default framebuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    glMatrixMode(GL_PROJECTION);
    // perspective projection
    MoGfx::perspective( 70, 320./411., .01, 100 );
    
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    // look
    MoGfx::lookAt( 0, 0, 6, 0, 0, 0, 0, 1, 0 );
    
    // draw
    draw();
    
	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
	// Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)parseMessages:(NSString*)data {
    messages.clear();
    
    while (1) {
        NSRange r = [data rangeOfString:@"<Message>"];
        if (r.location == NSNotFound) {
            break;
        }
        
        Message m;
        
        NSRange r2 = [data rangeOfString:@"</Message>"];
        NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
        NSString *message = [data substringWithRange:r3];
        
        NSRange r4 = [message rangeOfString:@"<Cause>"];
        NSRange r5 = [message rangeOfString:@"</Cause>"];
        NSRange r6 = NSMakeRange(r4.location+r4.length, r5.location - r4.location-r4.length);
        NSString *cause = [message substringWithRange:r6];
        
        NSRange r7 = [message rangeOfString:@"<Location>"];
        NSRange r8 = [message rangeOfString:@"</Location>"];
        NSRange r9 = NSMakeRange(r7.location+r7.length, r8.location - r7.location-r7.length);
        NSString *location = [message substringWithRange:r9];
        NSArray *latlong = [location componentsSeparatedByString:@","];
        
        m.cause = [cause hash]%4;
        m.position.x = [[latlong objectAtIndex:0] floatValue];
        m.position.y = [[latlong objectAtIndex:1] floatValue];
        
        messages.push_back(m);
        
  //      NSLog(@"%@, %d, (%f,%f)", cause, m.cause, m.position.x, m.position.y);
        
        data = [data substringWithRange:NSMakeRange(r2.location+r2.length, [data length]-r2.location-r2.length)];
//        NSLog(data);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
 //   [connection release];
	//label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	//NSLog(@"Finished Connection %d",connection.tag);
//	[connection release];
	NSString *data =  [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];

//    NSLog(data);
    [self parseMessages:data];
    
    [connection release];
	//NSLog(rsltStr);
}

- (void) dealloc
{
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
    
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
    
    [responseData release];
	
	[super dealloc];
}

@end

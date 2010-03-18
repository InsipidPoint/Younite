//
//  ES1Renderer.m
//  TexMess
//
//  Created by Ge Wang on 1/25/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "ES1Renderer.h"
#import "mo_gfx.h"

// global
GLuint g_texture[1];
#define NUM_ENTITIES 64

GLfloat rand2f( float a, float b )
{
    GLfloat diff = b - a;
    return a + ((GLfloat)rand() / RAND_MAX)*diff;
}

class Entity
{
public:
    Entity() { bounce = 0.0f; }
    
public:
    Vector3D loc;
    Vector3D ori;
    Vector3D sca;
    Vector3D vel;
    Vector3D col;
    
    GLfloat bounce;
    GLfloat bounce_rate;
};

Entity g_entities[NUM_ENTITIES];

// draw
void draw()
{
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
    glClear(GL_COLOR_BUFFER_BIT);
    
    // for each entity
    for( int i = 0; i < NUM_ENTITIES; i++ )
    {
        glPushMatrix();
        
        // translate
        glTranslatef( g_entities[i].loc.x, g_entities[i].loc.y, g_entities[i].loc.z );
        g_entities[i].loc.z += .12f;
        GLfloat val = 1 - fabs(g_entities[i].loc.z)/4.1;
        if( g_entities[i].loc.z > 4 )
        {
            g_entities[i].loc.x = rand2f( -1.5, 1.5);
            g_entities[i].loc.y = rand2f( -2.5, 2.5);
            g_entities[i].loc.z = rand2f( -4, -3.5);
        }
        
        // rotate
        glRotatef( g_entities[i].ori.z, 0, 0, 1 );
        g_entities[i].ori.z += 1.5f;
        
        // scale
        glScalef( g_entities[i].sca.x, g_entities[i].sca.y, g_entities[i].sca.z );
        g_entities[i].sca.y = .8 + .2*::sin(g_entities[i].bounce);
        g_entities[i].bounce += g_entities[i].bounce_rate;
        
        // vertex
        glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
        glEnableClientState(GL_VERTEX_ARRAY );
        
        // color
        glColor4f( g_entities[i].col.x, g_entities[i].col.y, 
                  g_entities[i].col.z, val );
        
        // normal
        glNormalPointer( GL_FLOAT, 0, normals );
        glEnableClientState( GL_NORMAL_ARRAY );
        
        // texture coordinate
        glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );
        
        // triangle strip
        glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
        
        glPopMatrix();
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
    glBindTexture( GL_TEXTURE_2D, g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    // load the texture
    MoGfx::loadTexture( @"texture", @"png" );
    
    // init entities
    for( int i = 0; i < NUM_ENTITIES; i++ )
    {
        g_entities[i].loc.x = rand2f( -1, 1 );
        g_entities[i].loc.y = rand2f( -1.5, 1.5 );
        g_entities[i].loc.z = rand2f( -4, 4 );
        
        g_entities[i].ori.z = rand2f( 0, 180 );
        
        g_entities[i].col.x = rand2f( 0, 1 );
        g_entities[i].col.y = rand2f( 0, 1 );
        g_entities[i].col.z = rand2f( 0, 1 );
        
        g_entities[i].sca.x = rand2f( .5, 1 );
        g_entities[i].sca.y = rand2f( 1, 1 );
        g_entities[i].sca.z = rand2f( .5, 1 );
        
        g_entities[i].bounce_rate = rand2f( .25, .5 );
    }
    
	return self;
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
    MoGfx::perspective( 70, 2./3., .01, 100 );
    
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
	
	[super dealloc];
}

@end

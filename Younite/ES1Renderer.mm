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
        
//        triangleFanTex[i*2] = asin(triangleFanNormals[i*3])/M_PI + 0.5;
//        triangleFanTex[i*2+1] = asin(triangleFanNormals[i*3+1])/M_PI + 0.5;
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
        
//        triangleStripTex[i*2] = asin(triangleStripNormals[i*3])/M_PI + 0.5;
//        triangleStripTex[i*2+1] = asin(triangleStripNormals[i*3+1])/M_PI + 0.5;
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
double d = 0;
void draw() {
//    static const GLfloat squareVertices[] = {
//        -0.5f,  -0.5f,
//        0.5f,  -0.5f,
//        -0.5f,   0.5f,
//        0.5f,   0.5f,
//    };
//    
//    static const GLfloat normals[] = {
//        0, 0, 1,
//        0, 0, 1,
//        0, 0, 1,
//        0, 0, 1
//    };
//    
//    static const GLfloat texCoords[] = {
//        0, 1,
//        1, 1,
//        0, 0,
//        1, 0
//    };
    
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // for each entity
        glPushMatrix();
        
        // translate
//        glTranslatef( g_entities[i].loc.x, g_entities[i].loc.y, g_entities[i].loc.z );
        
        // rotate
    //    glRotatef(180, 1, 0, 0);
        glRotatef(d, 1, 0, 0);
        d += 0.5;
        
        // scale
        glScalef(4, 4, 4);
        
        // vertex
//        glVertexPointer(3, GL_FLOAT, 0, g_globe);
    glEnableClientState(GL_VERTEX_ARRAY );
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        // color
    //    glColor4f(1.0, 0, 0, 1);
    
    glVertexPointer(3, GL_FLOAT, 0, sphereTriangleFanVertices);
    glNormalPointer(GL_FLOAT, 0, sphereTriangleFanNormals);
    glTexCoordPointer(2, GL_FLOAT, 0, sphereTriangleFanTex);
    glDrawArrays(GL_LINE_STRIP, 0, sphereTriangleFanVertexCount);
    
    glVertexPointer(3, GL_FLOAT, 0, sphereTriangleStripVertices);
    glNormalPointer(GL_FLOAT, 0, sphereTriangleStripNormals);
    glTexCoordPointer(2, GL_FLOAT, 0, sphereTriangleStripTex);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, sphereTriangleStripVertexCount);
        
//        // normal
//        glNormalPointer( GL_FLOAT, 0, g_normal );
//        glEnableClientState( GL_NORMAL_ARRAY );
//        
        // texture coordinate
        
        
        
        // triangle strip
//        glDrawArrays( GL_TRIANGLE_STRIP, 0, g_globe_pts);
        
        glPopMatrix();
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
    glBindTexture( GL_TEXTURE_2D, g_texture[0]);
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    // load the texture
    MoGfx::loadTexture( @"earthmap1k", @"jpg" );
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glDepthMask( GL_TRUE );
    glClearDepthf(1.0f);
    
    glEnable   ( GL_CULL_FACE );
	glShadeModel( GL_SMOOTH );
    
    getSolidSphere(&sphereTriangleStripVertices, &sphereTriangleStripNormals, &sphereTriangleStripTex, &sphereTriangleStripVertexCount, &sphereTriangleFanVertices, &sphereTriangleFanNormals, &sphereTriangleFanTex, &sphereTriangleFanVertexCount, 0.5, 50, 50);
    
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
    MoGfx::perspective( 70, 320./411., 1, 100 );
    
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

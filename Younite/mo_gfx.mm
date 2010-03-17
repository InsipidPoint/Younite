//-----------------------------------------------------------------------------
// name: mo_gfx.cpp
// desc: MoPhO API for graphics
//
// authors: Ge Wang (ge@ccrma.stanford.edu)
//          Nick Bryan
//          Jieun Oh
//          Jorge Hererra
//
//    date: Fall 2009
//    version: 0.2.2
//
// Stanford Mobile Phone Orchestra
//     http://mopho.stanford.edu/
//-----------------------------------------------------------------------------
#include "mo_gfx.h"
#include <math.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>


// vector static
GLfloat Vector3D::nowhere = 0.0f;
GLfloat Vector3D::zero = 0.0;


//-----------------------------------------------------------------------------
// name: perspective()
// desc: set perspective projection
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::perspective( double fovy, double aspectRatio, double zNear, double zFar )
{
    double xmin, xmax, ymin, ymax;

    // projection
	glMatrixMode( GL_PROJECTION );
    // identity
	glLoadIdentity();

    // set field of view
    ymax = zNear * tan( fovy * M_PI / 360.0 );
    ymin = -ymax;
    xmin = ymin * aspectRatio;
    xmax = ymax * aspectRatio;

    // set the frustum
    glFrustumf( xmin, xmax, ymin, ymax, zNear, zFar );

    // set hint
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
    
    // modelview
    // glMatrixMode( GL_MODELVIEW );
    // enable depth mask
    // glDepthMask( GL_TRUE );
}




//-----------------------------------------------------------------------------
// name: ortho()
// desc: set ortho projection
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::ortho()
{
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();					   
	glOrthof( 0, 320, 480, 0, 1, 0 );

	// glMatrixMode( GL_MODELVIEW );
	// glLoadIdentity();
     // glDepthMask( GL_FALSE );
}




//-----------------------------------------------------------------------------
// name: lookAt()
// desc: set eye, at, up vector
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::lookAt( double eye_x, double eye_y, double eye_z,
                    double at_x, double at_y, double at_z,
                    double up_x, double up_y, double up_z )
{
    GLfloat m[16];
    GLfloat x[3], y[3], z[3];
    GLfloat mag;

    /* Make rotation matrix */

    /* Z vector */
    z[0] = eye_x - at_x;
    z[1] = eye_y - at_y;
    z[2] = eye_z - at_z;

    mag = sqrt( z[0] * z[0] + z[1] * z[1] + z[2] * z[2] );
    if( mag )
    {   /* mpichler, 19950515 */
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }

    /* Y vector */
    y[0] = up_x;
    y[1] = up_y;
    y[2] = up_z;

    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];

    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];

    /* mpichler, 19950515 */
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
    mag = sqrt( x[0] * x[0] + x[1] * x[1] + x[2] * x[2] );
    if( mag )
    {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
    mag = sqrt( y[0] * y[0] + y[1] * y[1] + y[2] * y[2] );
    if( mag )
    {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }

#define M(row,col)  m[col*4+row]
    M(0,0) = x[0];
    M(0,1) = x[1];
    M(0,2) = x[2];
    M(0,3) = 0.0;
    M(1,0) = y[0];
    M(1,1) = y[1];
    M(1,2) = y[2];
    M(1,3) = 0.0;
    M(2,0) = z[0];
    M(2,1) = z[1];
    M(2,2) = z[2];
    M(2,3) = 0.0;
    M(3,0) = 0.0;
    M(3,1) = 0.0;
    M(3,2) = 0.0;
    M(3,3) = 1.0;    
#undef M

    // multiply into m
    glMultMatrixf( m );

    // translate eye to origin
    glTranslatef( -eye_x, -eye_y, -eye_z );
}



bool MoGfx::loadTexture( NSString * name, NSString * ext )
{
    // load the resource
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
    {
        NSLog( @"error: cannot load file: %@.%@", name, ext );
        return FALSE;
    }
    
    // convert to RGBA
    GLuint width = CGImageGetWidth( image.CGImage );
    GLuint height = CGImageGetHeight( image.CGImage );
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( 
        imageData, width, height, 8, 4 * width, colorSpace, 
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    // load the texture
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, 
                  GL_RGBA, GL_UNSIGNED_BYTE, imageData );
    
    // free resource - OpenGL keeps image internally
    CGContextRelease(context);
    free(imageData);
    [image release];
    [texData release];
    
    return true;
}


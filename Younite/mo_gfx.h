//-----------------------------------------------------------------------------
// name: mo_gfx.h
// desc: MoPhO API for graphics routines
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
#ifndef __MO_GFX_H__
#define __MO_GFX_H__


#include "mo_def.h"
#include <math.h>
#include <OpenGLES/ES1/gl.h>

 


//-----------------------------------------------------------------------------
// name: class MoGfx
// desc: MoPhO graphics functions
//-----------------------------------------------------------------------------
class MoGfx
{
public: // GLU-like stuff
    // perspective projection
    static void perspective( double fovy, double aspectRatio, double zNear, double zFar );
    // orthographic projection
    static void ortho();
    // look at
    static void lookAt( double eye_x, double eye_y, double eye_z,
                        double at_x, double at_y, double at_z,
                        double up_x, double up_y, double up_z );
    
    // load texture (call this with a texture bound)
    static bool loadTexture( NSString * name, NSString * ext );
};


//-----------------------------------------------------------------------------
// name: class Vector3D
// desc: 3d vector
//-----------------------------------------------------------------------------
class Vector3D
{
public:
    Vector3D( ) { setAll( 0 ); }
    Vector3D( GLfloat _x, GLfloat _y, GLfloat _z ) { set( _x, _y, _z ); }
    Vector3D( const Vector3D & other ) { *this = other; }
    ~Vector3D() { }
    
public:
    void set( GLfloat _x, GLfloat _y, GLfloat _z ) { x = _x; y = _y; z = _z; }
    void setAll( GLfloat val ) { x = y = z = val; }

public:
    GLfloat & operator []( int index )
    { if( index == 0 ) return x; if( index == 1 ) return y; 
      if( index == 2 ) return z; return nowhere; }
    const GLfloat & operator []( int index ) const
    { if( index == 0 ) return x; if( index == 1 ) return y; 
      if( index == 2 ) return z; return zero; }
    const Vector3D & operator =( const Vector3D & rhs )
    { x = rhs.x; y = rhs.y; z = rhs.z; return *this; }
    
    Vector3D operator +( const Vector3D & rhs ) const
    { Vector3D result = *this; result += rhs; return result; }
    Vector3D operator -( const Vector3D & rhs ) const
    { Vector3D result = *this; result -= rhs; return result; }
    Vector3D operator *( GLfloat scalar ) const
    { Vector3D result = *this; result *= scalar; return result; }

    void operator +=( const Vector3D & rhs )
    { x += rhs.x; y += rhs.y; z += rhs.z; }
    void operator -=( const Vector3D & rhs )
    { x -= rhs.x; y -= rhs.y; z -= rhs.z; }
    void operator *=( GLfloat scalar )
    { x *= scalar; y *= scalar; z *= scalar; }
    
    // dot product
    GLfloat operator *( const Vector3D & rhs ) const
    { GLfloat result = x*rhs.x + y*rhs.y + z*rhs.z; return result; }
    // magnitude
    GLfloat magnitude() const
    { return ::sqrt( x*x + y*y + z*z ); }
    // normalize
    void normalize()
    { GLfloat mag = magnitude(); if( mag == 0 ) return; *this *= 1/mag; }
    // 2d angles
    GLfloat angleXY() const
    { return ::atan2( y, x ); }
    GLfloat angleYZ() const
    { return ::atan2( z, y ); }
    GLfloat angleXZ() const
    { return ::atan2( z, x ); }
    
public:
    GLfloat x;
    GLfloat y;
    GLfloat z;
    
public:
    static GLfloat nowhere;
    static GLfloat zero;
};


#endif

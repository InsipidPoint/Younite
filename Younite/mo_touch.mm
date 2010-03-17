//-----------------------------------------------------------------------------
// name: mo_touch.mm
// desc: MoPhO API for multi-touch
//
// authors: Jieun Oh
//          Nick Bryan
//          Jorge Herrera
//          Ge Wang
//
//    date: Fall 2009
//    version: 0.2.2
//
// Stanford Mobile Phone Orchestra
//     http://mopho.stanford.edu/
//-----------------------------------------------------------------------------
#include "mo_touch.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <objc/message.h>


//-----------------------------------------------------------------------------
// name: touchesBegan()
// desc: handles the start of a touch
//-----------------------------------------------------------------------------
void myTouchesBegan(id self, SEL _cmd, NSSet * touches, UIEvent * event)
{
    NSSet * allTouches = [event allTouches];
    MoTouch::update( allTouches, self );    
}


//-----------------------------------------------------------------------------
// name: touchesMoved()
// desc: handles the continuation of a touch
//-----------------------------------------------------------------------------
void myTouchesMoved(id self, SEL _cmd, NSSet * touches, UIEvent *event)
{   
    NSSet * allTouches = [event allTouches];
    MoTouch::update( allTouches, self );
}


//-----------------------------------------------------------------------------
// name: touchesEnded()
// desc: handles the end of a touch event when the touch is a tap
//-----------------------------------------------------------------------------
void myTouchesEnded(id self, SEL _cmd, NSSet *touches, UIEvent * event)
{
    NSSet * allTouches = [event allTouches];
    MoTouch::update( allTouches, self );
}


//-----------------------------------------------------------------------------
// name: touchesCancelled()
// desc: handles the end of a touch event
//-----------------------------------------------------------------------------
void myTouchesCancelled(id self, SEL _cmd, NSSet *touches, UIEvent * event)
{
    NSSet * allTouches = [event allTouches];
    MoTouch::update( allTouches, self );
}


// static initialization
std::vector< MoTouchCallback > MoTouch::m_clients;
std::vector<void *> MoTouch::m_clientData;
std::map<int, MoTouchTrack> MoTouch::m_touchPts;


//-----------------------------------------------------------------------------
// name: checkSetup()
// desc: idempotent set up
//-----------------------------------------------------------------------------
void MoTouch::checkSetup()
{
    // override the touches methods, so the user doesn't have to do it
    Method method = class_getInstanceMethod([UIView class], @selector(touchesBegan:withEvent:));
    method_setImplementation(method, (IMP)myTouchesBegan);
    
    method = class_getInstanceMethod([UIView class], @selector(touchesMoved:withEvent:));
    method_setImplementation(method, (IMP)myTouchesMoved);
    
    method = class_getInstanceMethod([UIView class], @selector(touchesEnded:withEvent:));
    method_setImplementation(method, (IMP)myTouchesEnded);
    
    method = class_getInstanceMethod([UIView class], @selector(touchesCancelled:withEvent:));
    method_setImplementation(method, (IMP)myTouchesCancelled);
}


void MoTouch::addCallback( const MoTouchCallback & callback, void * data )
{
    // set up, if necessary
    checkSetup();

    NSLog( @"adding MoTouch callback...");
    m_clients.push_back( callback );
    m_clientData.push_back( data );
}


//-----------------------------------------------------------------------------
// name:  removeCallback()
// desc:  unregisters a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void MoTouch::removeCallback( const MoTouchCallback & callback )
{
    // set up, if necessary
    checkSetup();
    
    NSLog( @"removing MoTouch callback...");
    // find the callback and remove
    // TODO: change to using iterators
    for( int i=0; i < m_clients.size(); i++ )
    {
        if( m_clients[i] == callback )
        {
            m_clients.erase( m_clients.begin()+i );
            m_clientData.erase( m_clientData.begin()+i );
        }
    }
    
    // TODO: would find work???
}


void MoTouch::update( NSSet * touches, UIView * view )
{
	// Set the view to be multi touch enabled
	[view setMultipleTouchEnabled:YES];
	
    CGRect bounds = [view bounds];
    for( UITouch * touch in touches )
    {
        CGPoint location;
        
        // convert touch point from UIView referential to OpenGL one (upside-down flip)
        location = [touch locationInView:view];
        location.y = bounds.size.height - location.y;
        
        // cast touch pointer to int
        long key = (long) touch;
        
        // began
        if( touch.phase == UITouchPhaseBegan )
        {
            // look up key
            if( m_touchPts.find( key ) == m_touchPts.end() )
            {
                m_touchPts[key].touch = touch; 
            }
        }
        // stationary
        else if( touch.phase == UITouchPhaseStationary )
        {
            m_touchPts[key].touch = touch; 
        }
        // moved
        else if( touch.phase == UITouchPhaseMoved )
        {
            // update location
            m_touchPts[key].touch = touch; 
        }
    }
    
    // call clients
    for (int i=0; i<m_clients.size(); i++) 
    {
        m_clients[i]( touches, view, m_touchPts, m_clientData[i] );
    }
    
    // remove afterwards
    for( UITouch * touch in touches )
    {
        // cast touch pointer to int
        long key = (long) touch;
        
        // ended or cancelled
        if( touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled )
        {
            // look up key
            if( m_touchPts.find( key ) != m_touchPts.end() )
            {
                m_touchPts.erase( key );
            }
        }
    }
}

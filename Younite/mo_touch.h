//-----------------------------------------------------------------------------
// name: mo_touch.h
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
#ifndef __MO_TOUCH_H__
#define __MO_TOUCH_H__

#import <UIKit/UIKit.h>

#include "mo_def.h"
#include <map>
#include <vector>




//-----------------------------------------------------------------------------
// name: class MoTouchTrack
// desc: one track associated with a touch gesture (from begin to end/cancel)
//-----------------------------------------------------------------------------
struct MoTouchTrack
{
    UITouch * touch;  
    void * data;
};


// type definition for general touch callback function
typedef void (* MoTouchCallback)( NSSet * touches, UIView * view, 
                                  const std::map<int, MoTouchTrack> & touchPts,
                                  void * data);


//-----------------------------------------------------------------------------
// name: class MoTouch
// desc: multi-touch stuff  (singleton)
//-----------------------------------------------------------------------------
class MoTouch
{
public:
    // updated by the system
    static void update( NSSet * touches, UIView * view );

public: // client-side stuff
    static void addCallback( const MoTouchCallback & callback, void * data );
    static void removeCallback( const MoTouchCallback & callback );

public:
    typedef std::map<int, MoTouchTrack>::const_iterator MoTouchMapIt;	
    
private:
    static void checkSetup();
    
    // queue of callbacks
    static std::vector< MoTouchCallback > m_clients;
    static std::vector<void *> m_clientData;
    static std::map<int, MoTouchTrack> m_touchPts;
};


#endif

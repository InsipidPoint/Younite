//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// name: mo_location.h
// desc: MoPhO API for compass 
//
// authors: Nick Bryan
//          Jieun Oh
//          Jorge Herrera
//          Ge Wang
//
//    date: Fall 2009
//    version: 0.2
//
// Stanford Mobile Phone Orchestra
//     http://mopho.stanford.edu/
//-----------------------------------------------------------------------------
#ifndef __MO_LOCATION_H__
#define __MO_LOCATION_H__

#include "mo_def.h"
#import <CoreLocation/CoreLocation.h>
#include <vector>


@interface LocationDelegate : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@property (nonatomic, retain) CLLocationManager *locationManager;

@end


// type definition for accelerometer callback function
typedef void (* MoLocationCallback)( CLLocation * newLocation, 
                                     CLLocation * oldLocation,
                                     void * data );

//-----------------------------------------------------------------------------
// name: class MoLocation
// desc: location stuff, GPS/Edge/Wifi + Compass (singleton)
//-----------------------------------------------------------------------------
class MoLocation
{
public: // getting values

    // register a callback to be invoked on subsequent updates
    static void addCallback( const MoLocationCallback & callback, void * data );
    // unregister a callback
    static void removeCallback( const MoLocationCallback & callback );

    // get the newest location
    static CLLocation * getLocation();
    // get the previous location
    static CLLocation * getOldLocation();

    /*
    Location Attributes
    coordinate  property
    altitude  property
    horizontalAccuracy  property
    verticalAccuracy  property
    timestamp  property
    – description
    Measuring the Distance Between Coordinates
    – getDistanceFrom:
    Getting Speed and Course Information
    speed  property
    course  property
    */

public: // setting values
    static void update( CLLocation * newLoc, CLLocation * oldLoc );
    
private:
    // set up the Location delegate
    static void checkSetup();

    // current values;
    static CLLocation * m_newLocation;
    static CLLocation * m_oldLocation;

    static LocationDelegate * locationDelegate;
    
    // queue of callbacks
    static std::vector< MoLocationCallback > m_clients;
    static std::vector<void *> m_clientData; 
    //TODO: update the add and remove functions with the void * data
};


#endif

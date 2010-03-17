//-----------------------------------------------------------------------------
// name: mo_compass.h
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
#ifndef __MO_COMPASS_H__
#define __MO_COMPASS_H__

#import "mo_def.h"
#import <vector>
#import <CoreLocation/CoreLocation.h>


@interface CompassDelegate : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
}
@property (nonatomic, retain) CLLocationManager *locationManager;

@end


// type definition for accelerometer callback function
typedef void (* MoCompassCallback)( CLHeading * heading, void * data );


//-----------------------------------------------------------------------------
// name: class MoLocation
// desc: location stuff, GPS/Edge/Wifi + Compass (singleton)
//-----------------------------------------------------------------------------
class MoCompass
{
public: // setting values

    static void update( CLHeading * heading );
    // set the current compass offset
    static void setOffset();
    // clear the current compass offset
    static void clearOffset();

    static double getMagneticOffset();
    static double getTrueOffset();

public: // getting values

    // get the magnetic heading of the compass
    static double getMagneticHeading();
    // get the magnetic heading of the compass
    static double getTrueHeading();
    // get the estimated accuracy of the compass
    static double getAccuracy();

    // register a callback to be invoked on subsequent updates
    static void addCallback( const MoCompassCallback & callback, void * data );
    // unregister a callback
    static void removeCallback( const MoCompassCallback & callback );

private:
    // current values;
    static CLHeading * m_heading;
    static double m_magneticHeading;
    static double m_trueHeading;
    static CLLocationDirection m_accuracy;
    // store an offset 
    static double m_trueOffset;
    static double m_magneticOffset;
    static CompassDelegate * compassDelegate;

    // queue of callbacks
    static std::vector< MoCompassCallback > m_clients;
    static std::vector<void *> m_clientData;
    //TODO: update the add and remove functions with the void * data

    // internal setup of the compass
    static void setup();
	static void checkSetup();
};


#endif

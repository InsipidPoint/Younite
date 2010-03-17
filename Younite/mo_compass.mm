//-----------------------------------------------------------------------------
// name: mo_compass.mm
// desc: MoPhO API for compass
//
// authors: Nick Bryan
//          Jorge Herrera
//          Jieun Oh
//          Ge Wang
//
//    date: Fall 2009
//    version: 0.2
//
// Stanford Mobile Phone Orchestra
//     http://mopho.stanford.edu/
//-----------------------------------------------------------------------------
#include "mo_compass.h"


@implementation CompassDelegate
@synthesize locationManager;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    // update the compass server data
    MoCompass::update( heading );
}

@end


// static initialization
CLHeading * MoCompass::m_heading;
double MoCompass::m_magneticHeading = 0.0;
double MoCompass::m_trueHeading = 0.0;
CLLocationDirection MoCompass::m_accuracy = 0.0;
double MoCompass::m_trueOffset = 0;
double MoCompass::m_magneticOffset = 0;
CompassDelegate * MoCompass::compassDelegate;
std::vector< MoCompassCallback > MoCompass::m_clients;
std::vector<void *> MoCompass::m_clientData;


//-----------------------------------------------------------------------------
// name: checkSetup()
// desc: idempotent one-time setup
//-----------------------------------------------------------------------------
void MoCompass::checkSetup()
{
    // no need
    if( compassDelegate != NULL )
        return;

    // allocate a location Delegate object
    compassDelegate = [CompassDelegate alloc];
    // sanity check
    assert( compassDelegate != NULL );
    
    compassDelegate.locationManager = [[[CLLocationManager alloc] init] autorelease];
    
    // check if the hardware has a compass
    if( compassDelegate.locationManager.headingAvailable == NO )
    {
        // No compass is available. This application cannot function without a compass, 
        // so a dialog will be displayed and no magnetic data will be measured.
        compassDelegate.locationManager = nil;
        UIAlertView *noCompassAlert = [[UIAlertView alloc] 
                                       initWithTitle:@"No Compass!" 
                                       message:@"This device does not have the ability to measure magnetic fields."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [noCompassAlert show];
        [noCompassAlert release];
    }
    else
    {
        // heading service configuration
        compassDelegate.locationManager.headingFilter = kCLHeadingFilterNone;
        // this is default anyway, but just to make sure
        compassDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // setup delegate callbacks
        compassDelegate.locationManager.delegate = compassDelegate;
        // start the compass
        [compassDelegate.locationManager startUpdatingHeading];
    }
}


//-----------------------------------------------------------------------------
// name: update()
// desc: update the internal accelerometer data and process any callbacks
//-----------------------------------------------------------------------------
void MoCompass::update( CLHeading * heading )
{
    // update the current heading
    m_heading = heading;

    m_magneticHeading = [heading magneticHeading];
    m_trueHeading = [heading trueHeading];
    m_accuracy = [heading headingAccuracy];

	// process all callbacks
    for( int i=0; i < m_clients.size(); i++ ) // TODO: Change to using iterators
        (m_clients[i])( m_heading, m_clientData[i]);  
}


//-----------------------------------------------------------------------------
// name: getMagneticHeading()
// desc: gets the magnetic heading of the compass
//-----------------------------------------------------------------------------
double MoCompass::getMagneticHeading()
{
    // one-time setup, if needed
    checkSetup();
    
    return m_magneticHeading;
}


//-----------------------------------------------------------------------------
// name: getTrueHeading()
// desc: gets the true heading of the compass
//-----------------------------------------------------------------------------
double MoCompass::getTrueHeading()
{
    // one-time setup, if needed
    checkSetup();

    return m_trueHeading;
}


//-----------------------------------------------------------------------------
// name: getAccuracy()
// desc: gets the accuracy in degress of the current heading value
//-----------------------------------------------------------------------------
double MoCompass::getAccuracy()
{
    // one-time setup, if needed
    checkSetup();

    return m_accuracy;
}


/*//-----------------------------------------------------------------------------
// name: getTimestamp()
// desc: gets the timestamp of the current heading value
//-----------------------------------------------------------------------------
NSDate * MoCompass::getTimestamp() const
{
	return [m_heading timestamp];
}*/


//-----------------------------------------------------------------------------
// name: setOffset()
// desc: stores an offset using the current magnetic heading of the compass to be used later
//-----------------------------------------------------------------------------
void MoCompass::setOffset()
{
    // one-time setup, if needed
    checkSetup();

    // NSLog(@"Seeing Offset\n");
    m_magneticOffset = getMagneticHeading();
    m_trueOffset = getTrueHeading();
}


//-----------------------------------------------------------------------------
// name: clearOffset()
// desc: stores an offset using the current magnetic heading of the compass to be used later
//-----------------------------------------------------------------------------
void MoCompass::clearOffset()
{
    // one-time setup, if needed
    checkSetup();

    m_magneticOffset = 0;
    m_trueOffset = 0;
}


double MoCompass::getMagneticOffset()
{
    // one-time setup, if needed
    checkSetup();

    return m_magneticOffset;
}

double MoCompass::getTrueOffset()
{
    // one-time setup, if needed
    checkSetup();

    return m_trueOffset;
}


//-----------------------------------------------------------------------------
// name:  add
// desc:  registers a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void  MoCompass::addCallback(const MoCompassCallback & callback, void * data )
{
    // one-time setup, if needed
    checkSetup();

    // NSLog(@"Adding MoCompassCallback\n");
    m_clients.push_back( callback );
    m_clientData.push_back(data);
}


//-----------------------------------------------------------------------------
// name:  add
// desc:  unregisters a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void  MoCompass::removeCallback(const MoCompassCallback & callback )
{
    // one-time setup, if needed
    checkSetup();

    // NSLog(@"Removing MoCompassCallback\n");
    // find the callback and remove
    // TODO: change to using iterators
    for( int i=0; i < m_clients.size(); i++ )
    {
        if(m_clients[i]==callback)
        {
            m_clients.erase(m_clients.begin()+i);
            m_clientData.erase(m_clientData.begin()+i);
        }
    }

    // TODO: would find work???
}

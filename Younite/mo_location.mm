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
#include "mo_location.h"


@implementation LocationDelegate
@synthesize locationManager;

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    // Update the Location data
    MoLocation::update(newLocation, oldLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // the location "unknown" error simply means the manager is currently unable to get the location.
    // if ([error code] != kCLErrorLocationUnknown) {
    //    [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    // }
}

@end


// static initialization
CLLocation * MoLocation::m_newLocation;
CLLocation * MoLocation::m_oldLocation;
LocationDelegate * MoLocation::locationDelegate;
std::vector< MoLocationCallback > MoLocation::m_clients;
std::vector<void *> MoLocation::m_clientData; 


//-----------------------------------------------------------------------------
// name: checkSetup()
// desc: returns the singelton instance
//-----------------------------------------------------------------------------
void MoLocation::checkSetup()
{
    // allocate a location Delegate object
    locationDelegate = [LocationDelegate alloc];
    locationDelegate.locationManager = [[[CLLocationManager alloc] init] autorelease];

    // heading service configuration
    locationDelegate.locationManager.distanceFilter = kCLDistanceFilterNone;
    //This is default anyway, but just to make sure
    locationDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // setup delegate callbacks
    locationDelegate.locationManager.delegate = locationDelegate;
    // start the location stuff
    [locationDelegate.locationManager startUpdatingLocation];
}


//-----------------------------------------------------------------------------
// name: update()
// desc: update the internal accelerometer data and process any callbacks
//-----------------------------------------------------------------------------
void MoLocation::update( CLLocation * newLoc, CLLocation * oldLoc )
{
    m_newLocation = (CLLocation *)newLoc;
    m_oldLocation = (CLLocation *)oldLoc;

    // process all callbacks
    for( int i=0; i < m_clients.size(); i++ ) // TODO: change to using iterators
        (m_clients[i])( m_newLocation, m_oldLocation, m_clientData[i]);  
}


CLLocation * MoLocation::getLocation()
{
    // one-time setup, if needed
    checkSetup();

    return m_newLocation;
}


CLLocation * MoLocation::getOldLocation()
{
    // one-time setup, if needed
    checkSetup();

    return m_oldLocation;
}



//-----------------------------------------------------------------------------
// name: add
// desc: registers a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void MoLocation::addCallback(const MoLocationCallback & callback, void * data )
{
    // one-time setup, if needed
    checkSetup();

    // NSLog(@"Adding MoLocationCallback\n");
    m_clients.push_back( callback );
    m_clientData.push_back(data);
}


//-----------------------------------------------------------------------------
// name: add
// desc: unregisters a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void MoLocation::removeCallback(const MoLocationCallback & callback )
{
    // one-time setup, if needed
    checkSetup();

    // NSLog(@"Removing MoLocationCallback\n");
    // find the callback and remove
    // TODO: Change to using iterators
    for(int i=0; i < m_clients.size(); i++) 	
    {
        if(m_clients[i]==callback)
        {
            m_clients.erase(m_clients.begin()+i);
            m_clientData.erase(m_clientData.begin()+i);
        }
    }
	
    // TODO: would find work???
}

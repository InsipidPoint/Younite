//-----------------------------------------------------------------------------
// name: mo_accel.mm
// desc: MoPhO API for accelerometer
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
#import "mo_accel.h"


@implementation AccelDelegate

-(void) accelerometer:(UIAccelerometer*)accelerometer
        didAccelerate:(UIAcceleration*)acceleration
{
    // update the Accelerometer server data
    MoAccel::update( acceleration.x, acceleration.y, acceleration.z );
}

@end


// static initialization
double MoAccel::m_x = 0.0;
double MoAccel::m_y = 0.0;
double MoAccel::m_z = 0.0;
const double MoAccel::MAX_ACCEL_RATE = .01;
double MoAccel::m_updateInterval = 0.0;
AccelDelegate * MoAccel::accelDelegate;
std::vector<MoAccelCallback> MoAccel::m_clients;
std::vector<void *> MoAccel::m_clientData;


//-----------------------------------------------------------------------------
// name: checkSetup()
// desc: idempotent one-time setup
//-----------------------------------------------------------------------------
void MoAccel::checkSetup()
{
    // only if delegate is null
    if( accelDelegate == NULL )
    {
        // make delegate
        accelDelegate = [AccelDelegate alloc];
        [[UIAccelerometer sharedAccelerometer] setDelegate:accelDelegate];
        // sanity check
        assert( accelDelegate != NULL );
        // set interval
        setUpdateInterval( .02 );
    }
}


//-----------------------------------------------------------------------------
// name: update()
// desc: update the internal accelerometer data and process any callbacks
//-----------------------------------------------------------------------------
void MoAccel::update( double x, double y, double z )
{
    m_x = x;
    m_y = y;
    m_z = z;
    
    // process all callbacks
    for( int i=0; i < m_clients.size(); i++ ) // TODO: Change to using iterators
        (m_clients[i])( m_x, m_y, m_z, m_clientData[i]);
}


//-----------------------------------------------------------------------------
// name: getXYZ()
// desc: polling function that writes the current accelerometer values to the 
//       given function input parameters
//-----------------------------------------------------------------------------
void MoAccel::getXYZ( double & px, double & py, double & pz )
{
    // setup if necessary
    checkSetup();
    
    px = m_x;
    py = m_y;
    pz = m_z;
}


//-----------------------------------------------------------------------------
// name: getX()
// desc: polling function that writes the current accelerometer values to the 
//       given function input parameters
//-----------------------------------------------------------------------------
double MoAccel::getX()
{
    // setup if necessary
    checkSetup();
    
    return m_x;
}


//-----------------------------------------------------------------------------
// name: getY()
// desc: polling function that writes the current accelerometer values to the 
//       given function input parameters
//-----------------------------------------------------------------------------
double MoAccel::getY()
{
    // setup if necessary
    checkSetup();
    
    return m_y;
}


//-----------------------------------------------------------------------------
// name: getZ
// desc: polling function that writes the current accelerometer values to the 
//       given function input parameters
//-----------------------------------------------------------------------------
double MoAccel::getZ()
{
    // setup if necessary
    checkSetup();
    
    return m_z;
}


//-----------------------------------------------------------------------------
// name: addCallback()
// desc: registers a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void MoAccel::addCallback( const MoAccelCallback & callback, void * data )
{
    // setup if necessary
    checkSetup();

    NSLog( @"adding MoAccel callback..." );
    m_clients.push_back( callback );
    m_clientData.push_back(data);
}


//-----------------------------------------------------------------------------
// name:  removeCallback()
// desc:  unregisters a callback to be invoked on subsequent updates       
//-----------------------------------------------------------------------------
void MoAccel::removeCallback( const MoAccelCallback & callback )
{
    // setup if necessary
    checkSetup();

    NSLog( @"removing MoAccel callback...");
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


//-----------------------------------------------------------------------------
// name:  setUpdateInterval()
// desc:  Sets the current update interval in seconds for the accelerometer      
//-----------------------------------------------------------------------------
void MoAccel::setUpdateInterval( double seconds )
{
    // setup if necessary
    checkSetup();

    // make sure seconds is within limits
    if( seconds > 1)
        seconds = 1;
    else if( seconds < MAX_ACCEL_RATE ) //fs = 100;
        seconds = MAX_ACCEL_RATE;
    else
    { }
    
    // update the ivar
    m_updateInterval = seconds;
    
    // set the accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval: m_updateInterval];
}


//-----------------------------------------------------------------------------
// name:  getUpdateInterval()
// desc:  Gets the current update interval in seconds for the accelerometer      
//-----------------------------------------------------------------------------
double MoAccel::getUpdateInterval()
{
    // setup if necessary
    checkSetup();

    return m_updateInterval;
}

/***************************************************/
/*! \class OnePole
 \brief STK one-pole filter class.
 
 This class implements a one-pole digital filter.  A method is
 provided for setting the pole position along the real axis of the
 z-plane while maintaining a constant peak filter gain.
 
 by Perry R. Cook and Gary P. Scavone, 1995 - 2009.
 */
/***************************************************/

#include "EnvelopeFollower.h"

namespace stk {
	
	EnvelopeFollower :: EnvelopeFollower( StkFloat decayRate )
	{
		b_.resize( 1 );
		a_.resize( 2 );
		inputs_.resize( 1, 1, 0.0 );
		outputs_.resize( 2, 1, 0.0 );
		
		//set the filter coeffs using a decay rate
		this->setDecayRate(decayRate);
	}
	
	EnvelopeFollower :: ~EnvelopeFollower()    
	{
	}
	
	void EnvelopeFollower :: setDecayRate(StkFloat decayRate)
	{
		StkFloat a1 = -pow(10, -decayRate/(20*sampleRate()));
		StkFloat b0 = 1+a1;
		this->setCoefficients( b0, a1, true );
	}
	
	
	void EnvelopeFollower :: setPole( StkFloat thePole )
	{
		// Normalize coefficients for peak unity gain.
		if ( thePole > 0.0 )
			b_[0] = (StkFloat) (1.0 - thePole);
		else
			b_[0] = (StkFloat) (1.0 + thePole);
		
		a_[1] = -thePole;
	}
	
	void EnvelopeFollower :: setCoefficients( StkFloat b0, StkFloat a1, bool clearState )
	{
		b_[0] = b0;
		a_[1] = a1;
		
		if ( clearState ) this->clear();
	}
	
} // stk namespace

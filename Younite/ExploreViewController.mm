//
//  ExploreViewController.m
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ExploreViewController.h"
#import "global.h"

static const int g_numTracks = 3;
Float32 *g_audioTracks[g_numTracks];
bool g_validAudioTracks[g_numTracks];
int g_index[g_numTracks];
int g_size[g_numTracks];
NSString* g_names[g_numTracks];

@implementation ExploreViewController

@synthesize nameLabel;
@synthesize globeView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	responseData = [[NSMutableData data] retain];
	messageIndex = 0;
	for(int i=0;i<g_numTracks;i++) {
		g_audioTracks[i] = (Float32*)malloc(sizeof(Float32)*Global::g_recordingSize);
		g_validAudioTracks[i] = false;
	}
	myLock = [[NSLock alloc] init];
	[NSThread detachNewThreadSelector:@selector(initialBuffering:)
							 toTarget:self withObject:nil];
	
	srand(time(NULL));
	//[self explore];
}

- (void)viewWillAppear:(BOOL)animated {
    [globeView startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [globeView stopAnimation];
	//Global::stopPlayback();
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)initialBuffering:(id)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Buffering ...");
	for(int i=0;i<g_numTracks;i++) {
		NSLog(@"Retrieving %d/%d", (i+1), g_numTracks);
		[self getAudioForArray:i];
	}
	NSLog(@"... Done");
//	[NSThread detachNewThreadSelector:@selector(exploreContinuously:)
//							 toTarget:self withObject:nil];	
	[pool release];
}

- (void)getAudioData:(id)someData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * index = (NSString *)someData;
	[self getAudioForArray:[index intValue]];
	[pool release];
}
// pick a random sample from a user. Returns the picked index. Inputs the last picked index
- (void) smooth:(Float32 *)audio ofSize:(int)size {
	int slew = size/30;
	int i = 0;
	while(i<size) {
		if(i<slew) {
			audio[i] = audio[i]*(i*1.0/slew);
		}
		if(i >= size - slew) {
			audio[i] = audio[i]*((size - i - 1)*1.0/slew);
		}
		i++;
	}
}
- (int) tick2:(int)last {
	int valid = 0;
	last++;
	last%=g_numTracks;
	[myLock lock];
	int index = last;
	int chosen = -1;
	for(int i=0;i<g_numTracks;i++) {
		index = index%g_numTracks;
		if(g_validAudioTracks[index]) {
			if(g_size[index] > 0 && chosen < 0) {
				
				int newsize = 12000;				
				int r = random()%4000;
				newsize += r - 2000;
				NSLog(@"Picked a newsize of %d from %d of total size %d with index %d", newsize, index, g_size[index], g_index[index]);
				if (newsize + g_index[index] >= g_size[index]) {
					newsize = g_size[index] - g_index[index];
				}
				//NSLog(@"Trying to allocate a buffer of size %d from %d of total size %d", newsize, index, g_size[index]);
				Float32 *m_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*newsize) ;
				for (int j = 0; j < newsize; j++) {
					m_playbackBuffer[j] = g_audioTracks[index][g_index[index]];
					g_index[index] = g_index[index] + 1;
				}
				[self smooth:m_playbackBuffer ofSize:newsize];
				Global::loadPlaybackBuffer(m_playbackBuffer, newsize);
				valid++;
				if(g_index[index] == g_size[index]) {
					g_validAudioTracks[index] = false;
					g_size[index] = 0;
					g_index[index] = 0;
				}
				chosen = index;
				free(m_playbackBuffer);
			}
		}
		else {
			NSString *s = [NSString stringWithFormat:@"%d", index];
			[NSThread detachNewThreadSelector:@selector(getAudioData:)
									 toTarget:self withObject:s];
			
			//[self getAudioForArray:index];
			g_validAudioTracks[index] = true;
		}
		index++;
	}
	[myLock unlock];
	//NSLog(@"chosen %d", chosen);
	return chosen;
	
}

// Average all values
- (void) tick1 {
	int val = 0;
	int valid = 0;
	[myLock lock];
	for(int i=0;i<g_numTracks;i++) {
		if(g_validAudioTracks[i]) {
			if(g_size[i] > 0) {
				val += g_audioTracks[i][g_index[i]];
				g_index[i] = g_index[i] + 1;
				valid++;
				if(g_index[i] == g_size[i]) {
					g_validAudioTracks[i] = false;
					g_size[i] = 0;
				}
			}
		}
		else {
			NSString *s = [NSString stringWithFormat:@"%d", i];
			[NSThread detachNewThreadSelector:@selector(getAudioData:)
									 toTarget:self withObject:s];
			
			//[self getAudioForArray:i];
			g_validAudioTracks[i] = true;
		}
	}
	if(valid > 0) {
		val /= valid;
		// push val onto global;
		Global::tick(val);
		//NSLog(@"%d",valid);
	}
	[myLock unlock];
	
}
- (void)exploreContinuously:(id)someData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int last = -1;
	for(int q=0;q<100000000;q++) {
		last = [self tick2:last];
		if (last >= 0) {
			nameLabel.text = g_names[last];
		}
		else {
			nameLabel.text = @"";
		}

		//NSLog(@"%d %d",last,g_index[last]);
	}
	// Message back to the main thread
//	[self performSelectorOnMainThread:@selector(allDone:)
//						   withObject:[someData result] waitUntilDone:NO];
	[pool release];
}
- (void)getAudioForArray:(int)index {
	//nameLabel.text = @"";
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://youniteapp2.appspot.com/get?id=%d", index]]];
	//NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//	NSURLResponse *response;
//	NSError *error;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString * message =  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	[self setAudiofromMessage:message];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)explore {
//	nameLabel.text = @"";
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://youniteapp.appspot.com/get"]];
//	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//	//conn.tag = messageIndex;
//	messageIndex++;
//	[self exploreContinuously];	
	
/*	
	Global::startPlayback();
	NSLog(@"%d %f",Global::g_playbackIndex, Global::g_playbackBuffer[Global::g_playbackIndex]);
 */
}

- (NSString*)getNamefromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Name>"];
	if(r.location == NSNotFound)
		return @"";
	NSRange r2 = [message rangeOfString:@"</Name>"];
	if(r2.location == NSNotFound)
		return @"";
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	return [message substringWithRange:r3];	
}
- (NSString*)getCausefromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Cause>"];
	if(r.location == NSNotFound)
		return @"";
	NSRange r2 = [message rangeOfString:@"</Cause>"];
	if(r2.location == NSNotFound)
		return @"";
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	return [message substringWithRange:r3];	
}
- (NSString*)getLocationfromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Location>"];
	if(r.location == NSNotFound)
		return @"";
	NSRange r2 = [message rangeOfString:@"</Location>"];
	if(r2.location == NSNotFound)
		return @"";
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	return [message substringWithRange:r3];	
}

- (int)getArrayIdfromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Id>"];
	if(r.location == NSNotFound) {
		return 0;	
	}
	NSRange r2 = [message rangeOfString:@"</Id>"];
	if(r2.location == NSNotFound) {
		return 0;
	}
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	NSString *identifier = [message substringWithRange:r3];
	return [identifier intValue];
}
- (void)setAudiofromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Audio>"];
	if(r.location == NSNotFound) {
		return;	
	}
	NSRange r2 = [message rangeOfString:@"</Audio>"];
	if(r2.location == NSNotFound) {
		return;
	}
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	NSString *audio = [message substringWithRange:r3];
	//NSLog(@"%@", audio);
	NSArray *chunks = [audio componentsSeparatedByString: @"\n"];
	int arrayCount = [chunks count];
	int index = [self getArrayIdfromMessage:message];
	//NSLog(@"%d %d",arrayCount, index);
	[myLock lock];

	g_size[index] = arrayCount;
	NSString *m_name = [[self getNamefromMessage:message] retain];
	g_names[index] = [m_name retain];
	//Float32 *m_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*arrayCount) ;
	
	for (int i = 0; i < arrayCount; i++) {
		g_audioTracks[index][i] = [[chunks objectAtIndex:i] floatValue];
	}
	g_validAudioTracks[index] = true;
	g_index[index] = 0;
	[myLock unlock];
	
	//double lats[5] = {37.788, 42.350, 52.375, -33.724, 19.020, 39.901};
	//double lons[5] = {-122.475, -71.0375, 4.877, 25.576, 72.839, 116.389};
	
	NSString *location = [self getLocationfromMessage:message];
	NSArray *loc = [location componentsSeparatedByString:@","];
	NSDictionary *dict;
	
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			m_name, @"Name", 
			[self getCausefromMessage:message], @"Cause", 
			[loc objectAtIndex:0], @"lat",
			[loc objectAtIndex:1], @"lon", nil];
	 
	[globeView playingMessage:dict];

//	Global::loadPlaybackBuffer(m_playbackBuffer, arrayCount);
//	Global::startPlayback();
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	//NSLog(@"Finished Connection %d",connection.tag);
	[connection release];
//	NSString * message =  [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
//	[self setNamefromMessage:message];
//	[self setAudiofromMessage:message];
	//NSLog(rsltStr);
}

- (void) dealloc {
	[nameLabel release];
	[globeView release];
	
	[super dealloc];
}

@end

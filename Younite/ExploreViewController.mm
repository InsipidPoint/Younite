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
	[NSThread detachNewThreadSelector:@selector(exploreContinuously:)
						   toTarget:self withObject:nil];
	srand(time(NULL));
	//[self explore];
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


- (void)dealloc {
    [super dealloc];
}
- (void)getAudioData:(id)someData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * index = (NSString *)someData;
	[self getAudioForArray:[index intValue]];
	[pool release];
}
// pick a random sample from a user. Returns the picked index. Inputs the last picked index
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
				
				int newsize = 24000;				
				int r = random()%4000;
				newsize += r - 2000;
				if (newsize + g_index[index] >= g_size[index]) {
					newsize = g_size[index] - g_index[index] - 1;
				}
				Float32 *m_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*newsize) ;
				
				for (int j = 0; j < newsize; j++) {
					m_playbackBuffer[j] = g_audioTracks[index][j];
				}
				Global::loadPlaybackBuffer(m_playbackBuffer, newsize);
				g_index[index] = g_index[index] + newsize + 1;
				valid++;
				if(g_index[index] == g_size[index]) {
					g_validAudioTracks[index] = false;
					g_size[index] = 0;
				}
				chosen = index;
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
	NSLog(@"chosen %d", chosen);
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

		NSLog(@"%d %d",last,g_index[last]);
	}
	// Message back to the main thread
//	[self performSelectorOnMainThread:@selector(allDone:)
//						   withObject:[someData result] waitUntilDone:NO];
	[pool release];
}
- (void)getAudioForArray:(int)index {
	//nameLabel.text = @"";
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://youniteapp.appspot.com/get?id=%d", index]]];
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
	Global::startPlayback();
	NSLog(@"%d %f",Global::g_playbackIndex, Global::g_playbackBuffer[Global::g_playbackIndex]);
}

- (NSString*)getNamefromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Name>"];
	NSRange r2 = [message rangeOfString:@"</Name>"];
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	return [message substringWithRange:r3];	
}
- (int)getArrayIdfromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Id>"];
	NSRange r2 = [message rangeOfString:@"</Id>"];
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	NSString *identifier = [message substringWithRange:r3];
	return [identifier intValue];
}
- (void)setAudiofromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Audio>"];
	NSRange r2 = [message rangeOfString:@"</Audio>"];
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	NSString *audio = [message substringWithRange:r3];
	//NSLog(@"%@", audio);
	NSArray *chunks = [audio componentsSeparatedByString: @"\n"];
	int arrayCount = [chunks count];
	int index = [self getArrayIdfromMessage:message];
	NSLog(@"%d %d",arrayCount, index);
	[myLock lock];

	g_size[index] = arrayCount;
	g_names[index] = [[self getNamefromMessage:message] retain];
	//Float32 *m_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*arrayCount) ;
	
	for (int i = 0; i < arrayCount; i++) {
		g_audioTracks[index][i] = [[chunks objectAtIndex:i] floatValue];
	}
	g_validAudioTracks[index] = true;
	g_index[index] = 0;
	[myLock unlock];
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
	NSString * message =  [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	[self setNamefromMessage:message];
	[self setAudiofromMessage:message];
	//NSLog(rsltStr);
}


@end

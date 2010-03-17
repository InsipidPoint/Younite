//
//  ExploreViewController.m
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ExploreViewController.h"
#import "global.h"

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

- (void)explore {
	nameLabel.text = @"";
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://youniteapp.appspot.com/get"]];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//conn.tag = messageIndex;
	messageIndex++;
}

- (void)setNamefromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Name>"];
	NSRange r2 = [message rangeOfString:@"</Name>"];
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	nameLabel.text = [message substringWithRange:r3];	
}

- (void)setAudiofromMessage:(NSString *)message {
	NSRange r = [message rangeOfString:@"<Audio>"];
	NSRange r2 = [message rangeOfString:@"</Audio>"];
	NSRange r3 = NSMakeRange(r.location+r.length, r2.location - r.location-r.length);
	NSString *audio = [message substringWithRange:r3];
	//NSLog(@"%@", audio);
	NSArray *chunks = [audio componentsSeparatedByString: @"\n"];
	int arrayCount = [chunks count];
	NSLog(@"%d",arrayCount);
	Float32 *m_playbackBuffer = (Float32 *)malloc(sizeof(Float32)*arrayCount) ;
	
	for (int i = 0; i < arrayCount; i++) {
		m_playbackBuffer[i] = [[chunks objectAtIndex:i] floatValue];
	}
	Global::loadPlaybackBuffer(m_playbackBuffer, arrayCount);
	Global::startPlayback();
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

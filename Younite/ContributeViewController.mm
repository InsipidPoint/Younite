//
//  ContributeViewController.m
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ContributeViewController.h"
#import "global.h"

@implementation ContributeViewController
@synthesize button, uploadButton, playButton, nameField;
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
	BOOL result = Global::init();
	if( !result )
	{
		NSLog(@"Can't Start Audio");
	}	
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

-(void)buttonPressed {
	NSLog(@"Start Recording!");
	switch (Global::mode) {
		case 1:
			// Start Recording
			Global::startRecording();
			[button setTitle:@"Stop Recording" forState:UIControlStateNormal];
			[button setTitle:@"Stop Recording" forState:UIControlStateSelected];
			[button setTitle:@"Stop Recording" forState:UIControlStateHighlighted];			
			break;
		case 3:
			// Start Recording
			Global::startRecording();
			[button setTitle:@"Stop Recording" forState:UIControlStateNormal];
			[button setTitle:@"Stop Recording" forState:UIControlStateSelected];
			[button setTitle:@"Stop Recording" forState:UIControlStateHighlighted];			
			break;			
		case 2:
			// Stop Recording
			Global::setMode(1);
			[button setTitle:@"Record Message" forState:UIControlStateNormal];
			[button setTitle:@"Record Message" forState:UIControlStateSelected];
			[button setTitle:@"Record Message" forState:UIControlStateHighlighted];
			
			if(Global::getRecSize() > 0) {
				uploadButton.hidden = NO;
				playButton.hidden = NO;
			}
			else {
				uploadButton.hidden = YES;
				playButton.hidden = YES;
			}			
			break;
		default:
			break;
	
	}
/*	
	g_index = 0;
	
	g_isRecording = !g_isRecording;
	if(g_isRecording) {
		g_recSize = 0;
		[button setTitle:@"Stop Recording" forState:UIControlStateNormal];
		[button setTitle:@"Stop Recording" forState:UIControlStateSelected];
		[button setTitle:@"Stop Recording" forState:UIControlStateHighlighted];
	}
	else {
		[button setTitle:@"Record Message" forState:UIControlStateNormal];
		[button setTitle:@"Record Message" forState:UIControlStateSelected];
		[button setTitle:@"Record Message" forState:UIControlStateHighlighted];
		if(g_recSize > 0) {
			uploadButton.hidden = NO;
			playButton.hidden = NO;
		}
		else {
			uploadButton.hidden = YES;
			playButton.hidden = YES;
		}

	}
 */

}
-(void)playButtonPressed {
	switch (Global::mode) {
		case 1:
			// Start Playing
			Global::mode = 3;
			Global::g_index = 0;
			break;
		case 3:
			// Stop Playing
			Global::mode = 1;			
			break;

		default:
			break;
	}
/*	
	if(!g_isRecording) {
		g_isPlaying = true;
		g_index = 0;
	}
 */
}
-(void)uploadButtonPressed {
	NSString *audioData = @"";
	NSMutableArray *audioArray = [NSMutableArray arrayWithCapacity:Global::getRecSize()];
	for(int i=0;i<Global::getRecSize();i++) {
		[audioArray addObject:[NSString stringWithFormat:@"%f", Global::getRecordingBuffer()[i]]];
	}
	audioData = [audioArray componentsJoinedByString:@"\n"];
	
	NSString *boundary = @"----BOUNDARY_IS_I";
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://youniteapp.appspot.com/add", [[UIDevice currentDevice] uniqueIdentifier] ]];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	
	[req setHTTPMethod:@"POST"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
		
	// adding the body
	NSMutableData *postBody = [NSMutableData data];
	
	
	// first parameter an image
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"audio\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",audioData] dataUsingEncoding:NSUTF8StringEncoding]];
	
//	// second parameter information
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",@"36.04"] dataUsingEncoding:NSUTF8StringEncoding]];
//	
//	// third parameter information
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"lon\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",@"-121.123"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// fourth parameter information
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[nameField.text dataUsingEncoding:NSUTF8StringEncoding]];
	
//	// fifth parameter information
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"cause\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"%@",@"Haiti"] dataUsingEncoding:NSUTF8StringEncoding]];
//	
//	// sixth parameter information
//	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//	[postBody appendData:[@"Content-Disposition: form-data; name=\"category\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//	[postBody appendData:[chosenCategory dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[req setHTTPBody:postBody];
	//NSLog(@"%@",postBody);
	//	NSURLResponse* response;
	//	NSError* error;
	//	NSData* result = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	//	NSString * rsltStr =  [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
	//	NSLog(rsltStr);
	
	//Start retrieving the data
	[[NSURLConnection alloc] initWithRequest:req delegate:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData*) data{
	//	[imageData appendData:data];
	//NSString * rsltStr =  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	//NSLog(rsltStr);
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Thanks for your thoughts! Message Uploaded :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
	uploadButton.hidden = YES;
	playButton.hidden = YES;
	// Reset Global Params
	Global::g_index = 0;
	Global::g_recSize = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == nameField) {
        [nameField resignFirstResponder];
    }
    return YES;
}
@end

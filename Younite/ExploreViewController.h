//
//  ExploreViewController.h
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobeView.h"

@interface ExploreViewController : UIViewController {
	int messageIndex;
	NSMutableData *responseData;
	NSError *error;
	NSString *name;
	UILabel *nameLabel;
	NSLock *myLock;
    GlobeView *globeView;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet GlobeView *globeView;

- (IBAction)explore;
- (void)exploreContinuously:(id)data;
- (void)getAudioForArray:(int)index;
- (NSString*)getNamefromMessage:(NSString *)message;
- (void)setAudiofromMessage:(NSString *)message;
- (void) dealloc;
@end

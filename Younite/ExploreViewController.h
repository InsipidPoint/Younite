//
//  ExploreViewController.h
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExploreViewController : UIViewController {
	int messageIndex;
	NSMutableData *responseData;
	NSError *error;
	NSString *name;
	UILabel *nameLabel;
	NSLock *myLock;
}
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

- (IBAction)explore;
- (void)exploreContinuously:(id)data;
- (void)getAudioForArray:(int)index;
- (NSString*)getNamefromMessage:(NSString *)message;
- (void)setAudiofromMessage:(NSString *)message;
@end

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
	NSString *name;
	UILabel *nameLabel;
    
    GlobeView *globeView;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet GlobeView *globeView;

- (IBAction)explore;

- (void) dealloc;
@end

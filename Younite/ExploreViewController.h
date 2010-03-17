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
	NSString *name;
	UILabel *nameLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

- (IBAction)explore;
@end

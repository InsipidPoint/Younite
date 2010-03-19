//
//  ContributeViewController.h
//  Younite
//
//  Created by Ankit Gupta on 3/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContributeViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
	UIButton *button;
	UIButton *uploadButton;
	UIButton *playButton;
	UITextField *nameField;
	NSMutableArray *arrayCauses;
	NSString *selectedCause;
}

@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UITextField *nameField;

-(IBAction)buttonPressed;

-(IBAction)uploadButtonPressed;
-(IBAction)playButtonPressed;

@end

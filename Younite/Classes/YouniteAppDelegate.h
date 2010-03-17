//
//  YouniteAppDelegate.h
//  Younite
//
//  Created by Ankit Gupta on 3/7/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouniteAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

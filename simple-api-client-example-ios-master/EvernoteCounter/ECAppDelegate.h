//
//  ECAppDelegate.h
//  EvernoteCounter
//
//  Created by Brett Kelly on 5/7/12.
//  Copyright (c) 2012 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECViewController;

@interface ECAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ECViewController *viewController;

@end

//
//  AppDelegate.h
//  OAuthTest
//
//  Created by Matthew McGlincy on 3/17/12.
//

#import <UIKit/UIKit.h>
#import "NearbyItemsViewController.h"
#import "SimpleShare.h"

#define kAppTintColor [UIColor colorWithRed:(float)255/255 green:(float)140/255 blue:0 alpha:1.0]

@interface AppDelegate : UIResponder <UIApplicationDelegate, SimpleShareDelegate>
{
    NearbyItemsViewController *_nearbyItemsController;
    NSMutableArray *_nearbyItems;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *myItemIDs;

@end

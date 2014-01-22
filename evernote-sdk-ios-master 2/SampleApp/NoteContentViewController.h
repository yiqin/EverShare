//
//  NoteContentViewController.h
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleShare.h"
#import "NearbyItemsViewController.h"

@interface NoteContentViewController : UIViewController <SimpleShareDelegate, NearbyItemsViewControllerDelegate>
{
    NearbyItemsViewController *_nearbyItemsController;
    NSMutableArray *_nearbyItems;
    IBOutlet UIBarButtonItem *_findItemsButton;
    IBOutlet UIBarButtonItem *_shareItemsButton;
    UIBarButtonItem *_findingItemsActivityIndicator;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *guid;

@property (nonatomic,assign) NSString *userID;
@property (nonatomic,assign) NSString *selectedUrl;

@property (nonatomic, retain) NSMutableArray *myItemIDs;

- (IBAction)shareMyItems:(id)sender;
- (IBAction)findNearbyItems:(id)sender;
- (IBAction)stopSharingMyItems:(id)sender;

@end

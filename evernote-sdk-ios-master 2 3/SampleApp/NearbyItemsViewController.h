//
//  NearbyItemsViewController.h
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  NearbyItemsViewController;

@protocol NearbyItemsViewControllerDelegate <NSObject>
// - (void)nearbyItemsViewControllerAddedItem:(NSString *)itemID;
- (void)nearbyItemsViewControllerDidCancel:(NearbyItemsViewController *)controller;
@end

@interface NearbyItemsViewController : UITableViewController
{
    UIBarButtonItem *_findingItemsActivityIndicator;
}

@property (nonatomic, assign) id <NearbyItemsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *nearbyItemIDs;

// - (IBAction)cancel:(id)sender;

@end

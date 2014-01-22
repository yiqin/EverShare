//
//  NoteContentViewController.m
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import "NoteContentViewController.h"
#import "EvernoteSDK.h"
#import "ENMLUtility.h"

@interface NoteContentViewController ()

@end

@implementation NoteContentViewController
@synthesize myItemIDs = _myItemIDs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationController *navigationController = [[self.tabBarController viewControllers] objectAtIndex:1];
    
    _nearbyItemsController = (NearbyItemsViewController *)[navigationController topViewController];
    [_nearbyItemsController setDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[EvernoteNoteStore noteStore] getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
        ENMLUtility *utltility = [[ENMLUtility alloc] init];
        [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
            if(error == nil) {
                [self.webView loadHTMLString:html baseURL:nil];
                //self.webView.scalesPageToFit = YES;
            }
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failed to get note : %@",error);
    }];
    
    // _findItemsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(findNearbyItems:)];
    // _findItemsButton = [[UIBarButtonItem alloc] initWithTitle:@"Find" style:UIBarButtonItemStylePlain target:self action:@selector(findNearbyItems:)];
    // self.navigationItem.rightBarButtonItems = @[_findItemsButton, _shareItemsButton];
    
    [SimpleShare sharedInstance].delegate = self;
    [SimpleShare sharedInstance].myItemIDs = _myItemIDs;
}

- (void)getUserShardId {
    //Get the User from userStore and return the user's shard ID
    [[EvernoteUserStore userStore] getUserWithSuccess:^(EDAMUser *user) {
        self.userID = [NSString stringWithFormat:@"%@", user.shardId];
        [self shareSingleNoteWithNoteGUID:self.guid withShardId:self.userID];
    } failure:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];
}

- (void)shareSingleNoteWithNoteGUID:(NSString*)noteGUID
                        withShardId:(NSString*)shardId {
    // Share a single note and return the public URL for the note
    [[EvernoteNoteStore noteStore] shareNoteWithGuid:noteGUID success:^(NSString *noteKey) {
        self.selectedUrl = [NSString stringWithFormat:@"%@/shard/%@/sh/%@/%@",[[EvernoteSession sharedSession] host], shardId, noteGUID, noteKey];
        
        /*
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYYMMddHHmmss"];
         [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:[NSDate date]]];
         */
         
        self.myItemIDs = [[NSMutableArray alloc] initWithObjects:self.selectedUrl, self.noteTitle, nil];
        // Tell SimpleShare the item IDs we are sharing
        [SimpleShare sharedInstance].delegate = self;
        [SimpleShare sharedInstance].myItemIDs = _myItemIDs;
        
        NSLog(@"my item ids: %@", [SimpleShare sharedInstance].myItemIDs);
        
    } failure:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];
}

#pragma mark - NearbyItemsViewController Delegate
- (void)nearbyItemsViewControllerDidCancel:(NearbyItemsViewController *)controller
{
    // update UI to show it is done looking for items
    [self.navigationItem setRightBarButtonItem:_findItemsButton];
    
    [self.tabBarController setSelectedIndex:0];
    
    // dismiss the nearby items view controller
    // [self dismissViewControllerAnimated:YES completion:nil];
    
    // stop finding nearby items
    [[SimpleShare sharedInstance] stopFindingNearbyItems:nil];
    
}

#pragma mark - SimpleShare Delegate

- (void)simpleShareFoundFirstItems:(NSArray *)itemIDs
{
    // get rid of old found nearby items
    //_nearbyItems = nil;
    
    //_nearbyItems = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _nearbyItems = [userDefaults objectForKey:@"NearbyItems"];
    
    if (_nearbyItems == nil) {
        _nearbyItems = [[NSMutableArray alloc] init];
        [_nearbyItems addObjectsFromArray:itemIDs];
        NSLog(@"lazy loading");
        [userDefaults setObject:_nearbyItems forKey:@"NearbyItems"];
        [userDefaults synchronize];
    } else {
        _nearbyItems = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:@"NearbyItems"]];
        [_nearbyItems addObjectsFromArray:itemIDs];
        [userDefaults setObject:_nearbyItems forKey:@"NearbyItems"];
        [userDefaults synchronize];
    }
    
    // add the first item to the array
    NSLog(@"here found: %@", _nearbyItems);
    
    // pop up nearby items controller to show found item
    // [self performSegueWithIdentifier:@"addNearbyItems" sender:self];
    [_nearbyItemsController setNearbyItemIDs:_nearbyItems];
    [_nearbyItemsController.tableView reloadData];
    [self.tabBarController setSelectedIndex:1];
}

- (void)simpleShareFoundMoreItems:(NSArray *)itemIDs
{
    NSLog(@"more item: %@", itemIDs);
    // add the new item to the array
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Only immutable NSArray is stored in NSUserDefaults, the following cast is not stable?
    // _nearbyItems = (NSMutableArray *)[userDefaults objectForKey:@"NearbyItems"];
    _nearbyItems = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:@"NearbyItems"]];
    [_nearbyItems addObjectsFromArray:itemIDs];
    [userDefaults setObject:_nearbyItems forKey:@"NearbyItems"];
    [userDefaults synchronize];
    
    // update nearby items controller
    // NSLog(@"%@", _nearbyItems);
    [_nearbyItemsController setNearbyItemIDs:_nearbyItems];
    [_nearbyItemsController.tableView reloadData];
    [self.tabBarController setSelectedIndex:1];
}

- (void)simpleShareFoundNoItems:(SimpleShare *)simpleShare
{
    // update UI to show it is done looking for items
    [self.navigationItem setRightBarButtonItem:_findItemsButton];
    
}

- (void)simpleShareDidFailWithMessage:(NSString *)failMessage
{
    // update UI to show it is not looking for items
    [self.navigationItem setRightBarButtonItem:_findItemsButton];
    
    // update UI to indicate it is not sharing items
    _shareItemsButton.title = @"Share";
    _shareItemsButton.action = @selector(shareMyItems:);
    
}

-(IBAction)findNearbyItems:(id)sender
{
    [[SimpleShare sharedInstance] findNearbyItems:self];
}

- (IBAction)shareMyItems:(id)sender
{
    // get user share ID
    [self getUserShardId];
    // generate share link
    
    [[SimpleShare sharedInstance] shareMyItems:self];
    // update UI to indicate it is sharing items
    _shareItemsButton.title = @"Stop Sharing";
    _shareItemsButton.action = @selector(stopSharingMyItems:);
    
//    UITabBarController *controller = self.tabBarController;
//    UINavigationController *navigationController = (UINavigationController *)[controller.viewControllers objectAtIndex:1];
//    self.nearbyController = (NearbyItemsViewController *)navigationController.topViewController;
    [self performSelector:@selector(nearbyControllerReloadData) withObject:self afterDelay:2];
    [self performSelector:@selector(nearbyControllerReloadData) withObject:self afterDelay:2];
}

- (void)nearbyControllerReloadData
{
    [[SimpleShare sharedInstance] findNearbyItems:nil];
    [_nearbyItemsController.tableView reloadData];
}

-(IBAction)stopSharingMyItems:(id)sender
{
    [[SimpleShare sharedInstance] stopSharingMyItems:self];
    
    // update UI to indicate it is not sharing items
    _shareItemsButton.title = @"Share";
    _shareItemsButton.action = @selector(shareMyItems:);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

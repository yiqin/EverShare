//
//  AppDelegate.m
//  OAuthTest
//
//  Created by Matthew McGlincy on 3/17/12.
//
//  A simple sample application that demonstrates authenticating to Evernote
//  via OAuth and using the resulting authentication token to make a simple
//  Evernote API call.
//
//  To get started, fill in your consumer key and secret below.
//

#import "AppDelegate.h"
#import "EvernoteSDK.h"
#import "SimpleShare.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize myItemIDs = _myItemIDs;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Initial development is done on the sandbox service
    // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
    // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
    // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"sjtu-qy";
    NSString *CONSUMER_SECRET = @"012fd51559e2a842";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET];
    
    //#warning add a unique UUID for your app here. you can create one here: http://www.uuidgenerator.net
    [SimpleShare sharedInstance].simpleShareAppID = @"10EDC04C-B4B8-4657-A8C3-D51B3725856C";

    // initiate a halt on sharing upon launching...
    // [[SimpleShare sharedInstance] stopSharingMyItems:nil];
    
    // initiate a start on monitoring upon lauching...
    [[SimpleShare sharedInstance] findNearbyItems:nil];
    NSLog(@"Happened?!");
    
    // define navbar appearance
    [[UINavigationBar appearance] setBarTintColor:kAppTintColor];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    // set status bar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [SimpleShare sharedInstance].delegate = self;
    [SimpleShare sharedInstance].myItemIDs = _myItemIDs;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[EvernoteSession sharedSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}

- (BOOL) canHandleSwitchProfileURL:(NSURL *)url {
    NSString *requestURL = [url path];
    NSArray *components = [requestURL componentsSeparatedByString:@"/"];
    if ([components count] < 2) {
        NSLog(@"URL:%@ has invalid component count: %i", url, [components count]);
        return NO;
    }
    [[EvernoteSession sharedSession] updateCurrentBootstrapProfileWithName:components[1]];
    return YES;
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
    
    UITabBarController *controller = (UITabBarController *)self.window.rootViewController;
    [controller setSelectedIndex:1];
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
    
    UITabBarController *controller = (UITabBarController *)self.window.rootViewController;
    [controller setSelectedIndex:1];
}

- (void)simpleShareFoundNoItems:(SimpleShare *)simpleShare
{
    // update UI to show it is done looking for items
    //[self.navigationItem setRightBarButtonItem:_findItemsButton];
    
}

- (void)simpleShareDidFailWithMessage:(NSString *)failMessage
{
    // update UI to show it is not looking for items
    //[self.navigationItem setRightBarButtonItem:_findItemsButton];
    
    // update UI to indicate it is not sharing items
    //_shareItemsButton.title = @"Share";
    //_shareItemsButton.action = @selector(shareMyItems:);
    
}

@end

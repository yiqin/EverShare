//
//  NearbyItemsViewController.m
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import "NearbyItemsViewController.h"
#import "SimpleShare.h"
#import "SharedNoteViewController.h"

@interface NearbyItemsViewController () {
    NSIndexPath *selectedIndexPath;
}

@end

@implementation NearbyItemsViewController

@synthesize nearbyItemIDs = _nearbyItemIDs, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.nearbyItemIDs = [userDefaults objectForKey:@"NearbyItems"];
    NSLog(@"%@", self.nearbyItemIDs);
    
    [[SimpleShare sharedInstance] findNearbyItems:nil];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // initiate listening mode from the beginning the app is open!  :)
    // [[SimpleShare sharedInstance] findNearbyItems:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_nearbyItemIDs count] / 2;
    // Because half of _nearbyItemIDs is noteTitle and half is about url

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nearbyItemCell"];
    
    // To display the transferred article title :)
    cell.textLabel.text = [_nearbyItemIDs objectAtIndex:2*indexPath.row+1];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showSharedNoteContent" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSharedNoteContent"]) {
        SharedNoteViewController *controller = segue.destinationViewController;
        controller.url = [NSString stringWithFormat:@"https://%@", [_nearbyItemIDs objectAtIndex:2*selectedIndexPath.row]];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *nearbyItems = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:@"NearbyItems"]];
        NSObject *firstObjectToDelete = nearbyItems[2*indexPath.row];
        NSObject *secondObjectToDelete = nearbyItems[2*indexPath.row+1];
        [nearbyItems removeObject:firstObjectToDelete];
        [nearbyItems removeObject:secondObjectToDelete];
        [userDefaults setObject:nearbyItems forKey:@"NearbyItems"];
        [userDefaults synchronize];
        self.nearbyItemIDs = [userDefaults objectForKey:@"NearbyItems"];
        [self.tableView reloadData];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

/*
- (IBAction)cancel:(id)sender {
    
    [delegate nearbyItemsViewControllerDidCancel:self];
    
    // update UI to indicate it is looking for items
    if (_findingItemsActivityIndicator == nil) {
        UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [activityView sizeToFit];
        [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
        [activityView startAnimating];
        _findingItemsActivityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityView];
        activityView = nil;
    }
    
    [self.navigationItem setLeftBarButtonItem:_findingItemsActivityIndicator];
}
 */
@end

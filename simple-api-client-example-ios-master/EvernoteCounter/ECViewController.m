//
//  ECViewController.m
//  EvernoteCounter
//
//  Created by Brett Kelly on 5/7/12.
//  Copyright (c) 2012 Personal. All rights reserved.
//

#import "ECViewController.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"

@implementation ECViewController

@synthesize usernameField, noteCountField, noteCountButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)logoutOfEvernoteSession:(id)sender
{
    [[EvernoteSession sharedSession] logout];
}

- (IBAction)retrieveUserNameAndNoteCount:(id)sender
{
    // Create local reference to shared session singleton
    EvernoteSession *session = [EvernoteSession sharedSession];
    
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        // Authentication response is handled in this block
        if (error || !session.isAuthenticated) {
            // Either we couldn't authenticate or something else went wrong - inform the user
            if (error) {
                NSLog(@"Error authenticating with Evernote service: %@", error);
            }
            if (!session.isAuthenticated) {
                NSLog(@"User could not be authenticated.");
            }
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                             message:@"Could not authenticate" 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        } else {
            // We're authenticated!
            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
            // Retrieve the authenticated user as an EDAMUser instance
            [userStore getUserWithSuccess:^(EDAMUser *user) {
                // Set usernameField (UILabel) text value to username
                [usernameField setText:[user username]];
                // Retrieve total note count and display it
                [self countAllNotesAndSetTextField];                
            } failure:^(NSError *error) {
                NSLog(@"Error retrieving authenticated user: %@", error);
            }];
        } 
    }];    
}

- (void)countAllNotesAndSetTextField
{
    // Allow access to this variable within the block context below (using __block keyword)
    __block int noteCount = 0;

    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        for (EDAMNotebook *notebook in notebooks) {
            if ([notebook guid]) {
                EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
                [filter setNotebookGuid:[notebook guid]];
                [noteStore findNoteCountsWithFilter:filter withTrash:NO success:^(EDAMNoteCollectionCounts *counts) {
                    if (counts) {
                        
                        // Get note count for the current notebook and add it to the displayed total
                        NSNumber *notebookCount = (NSNumber *)[[counts notebookCounts] objectForKey:[notebook guid]];
                        noteCount = noteCount + [notebookCount intValue];
                        NSString *noteCountString = [NSString stringWithFormat:@"%d", noteCount];
                        [noteCountField setText:noteCountString];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"Error while retrieving note counts: %@", error);
                }];
            }
        }        
    } failure:^(NSError *error) {
        NSLog(@"Error while retrieving notebooks: %@", error);
    }];
}

@end

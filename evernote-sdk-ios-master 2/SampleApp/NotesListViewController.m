//
//  NotesListViewController.m
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import "NotesListViewController.h"
#import "EvernoteSDK.h"
#import "ENMLUtility.h"
#import "EDAMNoteStore.h"
#import "EDAM.h"
#import "NoteContentViewController.h"

@interface NotesListViewController ()

@end

@implementation NotesListViewController
{
    EDAMNoteList *resultedList;
    EDAMNote *selectedNote;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // NSLog(@"%@", self.notebook);
    
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:YES words:nil notebookGuid:self.notebook.guid tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
    EDAMNotesMetadataResultSpec *resultSpec = [[EDAMNotesMetadataResultSpec alloc] initWithIncludeTitle:NO includeContentLength:NO includeCreated:NO includeUpdated:NO includeDeleted:NO includeUpdateSequenceNum:NO includeNotebookGuid:NO includeTagGuids:NO includeAttributes:NO includeLargestResourceMime:NO includeLargestResourceSize:NO];

    [[EvernoteNoteStore noteStore] findNotesMetadataWithFilter:filter offset:0 maxNotes:100000 resultSpec:resultSpec success:^(EDAMNotesMetadataList *metadata) {
	    // NSLog(@"Total notes : %d",metadata.totalNotes);
	    for (int i=0; i<metadata.totalNotes; i=i+50) {
		    [[EvernoteNoteStore noteStore] findNotesWithFilter:filter offset:i maxNotes:50 success:^(EDAMNoteList *list) {
			    // NSLog(@"Notes : %@",list.notes);
                resultedList = list;
                [self.tableView reloadData];
		    }failure:^(NSError *error) {
			    NSLog(@"Error : %@",error);
		    }];
	    }
    } failure:^(NSError *error) {
	    NSLog(@"Error : %@",error);
    }];
    
    self.navigationItem.title = self.notebook.name;
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
    return [resultedList.notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    EDAMNote *note = [resultedList.notes objectAtIndex:indexPath.row];
    cell.textLabel.text = note.title;
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedNote = [resultedList.notes objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showNoteContent" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showNoteContent"]) {
        NoteContentViewController *controller = segue.destinationViewController;
        controller.guid = selectedNote.guid;
        controller.navigationItem.title = selectedNote.title;
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

@end

//
//  NotesListViewController.h
//  evernote-sdk-ios
//
//  Created by yiqin on 1/18/14.
//  Copyright (c) 2014 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDAMNoteStore.h"

@interface NotesListViewController : UITableViewController
@property (nonatomic, strong) EDAMNotebook *notebook;

@end

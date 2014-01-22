//
//  ECViewController.h
//  EvernoteCounter
//
//  Created by Brett Kelly on 5/7/12.
//  Copyright (c) 2012 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *usernameField;
@property (strong, nonatomic) IBOutlet UILabel *noteCountField;
@property (strong, nonatomic) IBOutlet UIButton *noteCountButton;

- (IBAction)logoutOfEvernoteSession:(id)sender;
- (IBAction)retrieveUserNameAndNoteCount:(id)sender;

@end

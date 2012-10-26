//
//  TaskEditViewController.h
//  Tasker
//
//  Created by Sardor on 25.10.12.
//  Copyright (c) 2012 Eventegrate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskEditViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) Task *currentTask;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UIButton *dateSelector;
@property (strong, nonatomic) IBOutlet UIButton *categorySelector;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSManagedObject *selectedCategory;

- (IBAction)selectDate;
- (IBAction)selectCategory;

@end
//
//  TaskEditorViewController.m
//  TaskManager
//
//  Created by Eugene Romanishin on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "UNActionPicker.h"

#import "TaskEditViewController.h"
#import "Task.h"

@interface TaskEditViewController ()
- (void)updateInterface;
@end

@implementation TaskEditViewController

@synthesize currentTask;
@synthesize name;
@synthesize dateSelector;
@synthesize categorySelector;
@synthesize selectedDate;
@synthesize selectedCategory;

- (void)viewDidUnload
{
  [super viewDidUnload];
  self.name = nil;
  self.dateSelector = nil;
  self.categorySelector = nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                        target:self
                                                                        action:@selector(saveTask)];
  self.navigationItem.rightBarButtonItem = save;
  
  if (currentTask) {
    name.text = currentTask.name;
    self.selectedDate = currentTask.timeStamp;
    self.selectedCategory = currentTask.category;
  }
  
  [self updateInterface];
}

- (IBAction)selectDate {
  UNActionPicker *datePicker = [[UNActionPicker alloc] initWithItems:nil
                                                               title:@"Select date"
                                                                type:DateType];
  [datePicker setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
  [datePicker setCloseButtonTitle:@"Done" color:[UIColor blackColor]];
  datePicker.delegate = self;
  [datePicker showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)selectCategory
{
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  UNActionPicker *datePicker = [[UNActionPicker alloc] initWithItems:appDelegate.categories
                                                               title:@"Select Category"
                                                                type:SimpleType];
  [datePicker setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
  [datePicker setCloseButtonTitle:@"Done" color:[UIColor blackColor]];
  datePicker.delegate = self;
  [datePicker showFromTabBar:self.tabBarController.tabBar];
}

- (void)didSelectItem:(id)item {
  if ([item isKindOfClass:[NSDate class]]) {
    self.selectedDate = item;
  } else if ([item isKindOfClass:[NSManagedObject class]]) {
    self.selectedCategory = item;
  }
  
  [self updateInterface];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (void)updateInterface {
  if (selectedDate) {
    [dateSelector setTitle:[selectedDate description] forState:UIControlStateNormal];
  }
  
  if (selectedCategory) {
    [categorySelector setTitle:[selectedCategory valueForKey:@"name"] forState:UIControlStateNormal];
  }
}

- (void)saveTask {
//  NSString *alertText;
//  if (!name.text.length) {
//    alertText = @"Не указано имя задачи";
//  } else if (!selectedCategory) {
//    alertText = @"Не выбрана категория";
//  }
//  int length0=0;
  
  if (!name.text.length) {
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Не указано имя задачи"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    warning.delegate = self;
    [warning show];
    [warning release];
    return;
  }
  
//  if (alertText.length) {
//    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                      message:alertText
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    warning.delegate = self;
//    [warning show];
//    [warning release];
//    return;
//  }
  
  if (!currentTask) {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
    self.currentTask = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
  }
  
  currentTask.name = name.text;
  currentTask.isCompleted = [NSNumber numberWithBool:NO];
  currentTask.timeStamp = selectedDate? selectedDate:[NSDate date];
  currentTask.category = selectedCategory;
  
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Alert delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSLog(@"button index clicked %d", buttonIndex);
}

@end

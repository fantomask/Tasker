//
//  ViewController.m
//  Tasker
//
//  Created by Sardor on 25.10.12.
//  Copyright (c) 2012 Eventegrate. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Task.h"
#import "TaskEditViewController.h"

@interface ViewController ()
- (void)createFetchRequest;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ViewController

@synthesize taskResults;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(createTask)];
  self.navigationItem.rightBarButtonItem = addButton;
  
  [self createFetchRequest];
}

- (void)createFetchRequest {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  fetchRequest.entity = [NSEntityDescription entityForName:@"Task"
                                    inManagedObjectContext:managedObjectContext];
  
  NSPredicate *filterRequest = self.filterRequest;
  if (filterRequest) {
    fetchRequest.predicate = filterRequest;
  }
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
  fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  
  self.taskResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                         managedObjectContext:managedObjectContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:@"Master"];
  NSError *error = nil;
	if (![self.taskResults performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  self.taskResults.delegate = self;

}

- (void)createTask {
  TaskEditViewController *taskEditor = [[TaskEditViewController alloc]
                                          initWithNibName:@"TaskEditViewController"
                                          bundle:nil];
  [self.navigationController pushViewController:taskEditor animated:YES];}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIAlertView *question = [[UIAlertView alloc] initWithTitle:@"Task"
                                                     message:@"Выберите действие"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Complete", @"Edit", nil];
  [question show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
  [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
  
  if (buttonIndex == 1) {
    Task *task = [self.taskResults objectAtIndexPath:selectedIndexPath];
    task.isCompleted = [NSNumber numberWithBool:YES];
  } else if (buttonIndex == 2) {
    TaskEditViewController *taskEditor = [[TaskEditViewController alloc]
                                            initWithNibName:@"TaskEditViewController"
                                            bundle:nil];
    taskEditor.currentTask = [self.taskResults objectAtIndexPath:selectedIndexPath];
    [self.navigationController pushViewController:taskEditor animated:YES];
    
  }
}
- (NSPredicate*)filterRequest {
  if (![self.navigationItem.title isEqualToString:@"All"]) {
    return [NSPredicate predicateWithFormat:@"isCompleted==%i",
            [self.navigationItem.title isEqualToString:@"Completed"]];
  } else {
    return nil;
  }
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  Task *task = [self.taskResults objectAtIndexPath:indexPath];
  cell.textLabel.text = task.name;
  cell.detailTextLabel.text = [task.timeStamp description];
  cell.accessoryType = task.isCompleted.boolValue? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.taskResults.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.taskResults sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSManagedObjectContext *context = [self.taskResults managedObjectContext];
    [context deleteObject:[self.taskResults objectAtIndexPath:indexPath]];
    
    NSError *error = nil;
    if (![context save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}
#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  UITableView *tableView = self.tableView;
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView endUpdates];
}

@end
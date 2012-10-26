//
//  AppDelegate.m
//  Tasker
//
//  Created by Sardor on 25.10.12.
//  Copyright (c) 2012 Eventegrate. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
- (NSFetchedResultsController*)fetchedCategories;
- (void)setDefouldCategories;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  [self setDefouldCategories];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  ViewController *allTsaks = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
  allTsaks.navigationItem.title = @"All";
  UINavigationController *all = [[UINavigationController alloc] initWithRootViewController:allTsaks];
  all.title = allTsaks.navigationItem.title;
  all.navigationBar.barStyle = UIBarStyleBlackOpaque;
  
  ViewController *pendingTsaks = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
  pendingTsaks.navigationItem.title = @"Pending";
  UINavigationController *pending = [[UINavigationController alloc] initWithRootViewController:pendingTsaks];
  pending.title = pendingTsaks.navigationItem.title;
  pending.navigationBar.barStyle = UIBarStyleBlackOpaque;
  
  ViewController *completedTsaks = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
  completedTsaks.navigationItem.title = @"Completed";
  UINavigationController *completed = [[UINavigationController alloc] initWithRootViewController:completedTsaks];
  completed.title = completedTsaks.navigationItem.title;
  completed.navigationBar.barStyle = UIBarStyleBlackOpaque;
  
  self.tabBarController = [[UITabBarController alloc] init];
  self.tabBarController.viewControllers = [NSArray arrayWithObjects:all, pending, completed, nil];
  
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSFetchedResultsController*)fetchedCategories {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  fetchRequest.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setFetchBatchSize:20];
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
  fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  
  NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                   managedObjectContext:self.managedObjectContext
                                                                                     sectionNameKeyPath:nil
                                                                                              cacheName:@"Master"];
  NSError *error = nil;
	if (![fetchedResults performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  
  return fetchedResults;
}

- (void)setDefouldCategories {
  NSFetchedResultsController *fetchedCategories = self.fetchedCategories;
  if (!fetchedCategories.fetchedObjects.count) {
    NSArray *categoryNames = [NSArray arrayWithObjects:@"Personal", @"Business", @"Family", @"Travel", @"Other", nil];
    
    for (NSString *name in categoryNames) {
      NSEntityDescription *entity = [[fetchedCategories fetchRequest] entity];
      NSManagedObject *category = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                inManagedObjectContext:self.managedObjectContext];
      [category setValue:name forKey:@"name"];
    }
  }
}

- (NSArray*)categories {
  return self.fetchedCategories.fetchedObjects;
}


- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tasker" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tasker.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
   
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

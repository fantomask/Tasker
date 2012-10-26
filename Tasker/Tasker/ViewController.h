//
//  ViewController.h
//  Tasker
//
//  Created by Sardor on 25.10.12.
//  Copyright (c) 2012 Eventegrate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *taskResults;

@end

//
//  Task.h
//  Tasker
//
//  Created by Sardor on 25.10.12.
//  Copyright (c) 2012 Eventegrate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * isCompleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSManagedObject *category;

@end

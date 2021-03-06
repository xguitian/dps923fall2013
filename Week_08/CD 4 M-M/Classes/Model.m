//
//  Model.m
//  CD Simple
//
//  Created by Peter McIntyre on 2012/06/22.
//  Copyright (c) 2012 Seneca College. All rights reserved.
//

#import "Model.h"
#import "CDStack.h"
#import "DataCreator.h"

@interface Model ()
{
    // Core Data stack
    CDStack *_cdStack;
}

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation Model {}

#pragma mark - Model object lifecycle

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Is this the app's first launch? (object store file does not exist) 
        // If yes, then does the app include starter data (will be in the app bundle) 
        // If yes, then copy the store file from the bundle to the Documents directory
        // Otherwise, will have to create some new data (after the stack is initialized)
        
        // URL to the object store file in the app bundle
        NSURL *storeFileInBundle = [[NSBundle mainBundle] URLForResource:@"ObjectStore" withExtension:@"sqlite"];
        
        // URL to the object store file in the Documents directory
        NSURL *storeFileInDocumentsDirectory = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ObjectStore.sqlite"];
        
        // System file manager
        NSFileManager *fm = [[NSFileManager alloc] init];
        
        // Check whether this is the first launch of the app
        BOOL isFirstLaunch = ![fm fileExistsAtPath:[storeFileInDocumentsDirectory path]];
        
        // Check whether the app is supplied with starter data in the app bundle
        BOOL hasStarterData = [fm fileExistsAtPath:[storeFileInBundle path]];
        
        if (isFirstLaunch)
        {
            if (hasStarterData)
            {
                // Use the supplied starter data
                [fm copyItemAtURL:storeFileInBundle toURL:storeFileInDocumentsDirectory error:nil];
                // Create a Core Data stack object after copying file
                _cdStack = [[CDStack alloc] init];
            }
            else
            {
                // Create a Core Data stack object before creating new data
                _cdStack = [[CDStack alloc] init];
                // Create some new data
                [DataCreator create:self];
            }
        }
        else
        {
            _cdStack = [[CDStack alloc] init];
        }
    }
    return self;
}

#pragma mark - Managed object maintenance

- (id)addNew:(NSString *)entityName
{
    // Create and return the new managed object
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:_cdStack.managedObjectContext];
}

- (App *)addNewApp:(NSString *)appName withTheme:(NSString *)theme sequence:(int)sequence inWeek:(int)week
{
    // Create a new App object
    App *a = (App *)[self addNew:@"App"];
    // Configure it
    a.appName = appName;
    a.theme = theme;
    a.sequence = [NSNumber numberWithInt:sequence];
    a.week = [NSNumber numberWithInt:week];
    
    return a;
}

- (Topic *)addNewTopic:(NSString *)topicName withDescription:(NSString *)topicDescription andNumber:(int)number
{
    // Configure a new Topic object
    Topic *t = (Topic *)[self addNew:@"Topic"];
    // Configure it
    t.topicName = topicName;
    t.topicDescription = topicDescription;
    t.topicNumber = [NSNumber numberWithInt:number];
    
    return t;
}

- (void)saveChanges
{
    [_cdStack saveContext];
}

#pragma mark - Fetched results controller - Apps

// Use this as a template... copy it, paste it (into your Model class), and then edit it
- (NSFetchedResultsController *)frc_app
{
    // If the frc is already configured, simply return it
    if (_frc_app) return _frc_app;
    
    // Otherwise, create a new frc, and set it as the property (and return it below)
    _frc_app = [_cdStack frcWithEntityNamed:@"App" withPredicateFormat:nil predicateObject:nil sortDescriptors:@"week,YES,sequence,YES" andSectionNameKeyPath:@"week"];

    return _frc_app;
}    

#pragma mark - Fetched results controller - Topics

// Use this as a template... copy it, paste it (into your Model class), and then edit it
- (NSFetchedResultsController *)frc_topic
{
    // If the frc is already configured, simply return it
    if (_frc_topic) return _frc_topic;
    
    // Otherwise, create a new frc, and set it as the property (and return it below)
    _frc_topic = [_cdStack frcWithEntityNamed:@"Topic" withPredicateFormat:nil predicateObject:nil sortDescriptors:@"topicNumber,YES" andSectionNameKeyPath:nil];
    
    return _frc_topic;
}

/*
 
 #pragma mark - Fetched results controller (custom getter) creation template
 
 // Use this as a template... copy it, paste it (into your Model class), and then edit it
 - (NSFetchedResultsController *)frc_example
 {
 // If the frc is already configured, simply return it
 if (_frc_example) return _frc_example;
 
 // Otherwise, create a new frc, and set it as the property (and return it below)
 _frc_example = [_cdStack frcWithEntityNamed:@"Example" withPredicateFormat:nil predicateObject:nil sortDescriptors:@"exampleAttribute,YES" andSectionNameKeyPath:nil];
 
 return _frc_example;
 }    
 
 */

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

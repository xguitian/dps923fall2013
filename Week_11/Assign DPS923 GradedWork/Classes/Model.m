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
#import "Client907.h"

@interface Model ()
{
    // Core Data stack
    CDStack *_cdStack;
}

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation Model {}

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Check whether the app is being launched for the first time
        // If yes, check if there's an object store file in the app bundle
        // If yes, copy the object store file to the Documents directory
        // If no, create some new data if you need to
        
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

#pragma mark - Web service Program entity

- (NSArray *)programs
{
    // If the data exists, just return it
    if (_programs) return _programs;
    
    // Otherwise, go fetch the data...

    // Reference the app's network activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    // Send a message to the singleton AFHTTPClient subclass

    [[Client907 sharedClient] getPath:@"programs"
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id response) {

                                  // Cast the response
                                  _programs = (NSArray *)[response objectForKey:@"Collection"];
                                  
                                  // Reference the app's network activity indicator in the status bar
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  
                                  // Then, post a notification, so that a controller object can request the results
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"SuccessGetPrograms" object:nil];

                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"Error... %@", error);
                              }];
    return _programs;
}

#pragma mark - Web service Subject entity

- (NSArray *)subjects
{
    // If the data exists, just return it
    if (_subjects) return _subjects;
    
    // Otherwise, go fetch the data...
    
    // Reference the app's network activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Send a message to the singleton AFHTTPClient subclass
    
    [[Client907 sharedClient] getPath:@"subjects"
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id response) {
                                  
                                  // Cast the response
                                  _subjects = (NSArray *)[response objectForKey:@"Collection"];

                                  // Reference the app's network activity indicator in the status bar
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  
                                  // Then, post a notification, so that a controller object can request the results
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"SuccessGetSubjects" object:nil];
                                  
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"Error... %@", error);
                              }];
    return _programs;
}

#pragma mark - Managed object maintenance

- (id)addNew:(NSString *)entityName
{
    // Create and return the new managed object
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:_cdStack.managedObjectContext];
}

- (void)saveChanges
{
    [_cdStack saveContext];
}

#pragma mark - Fetched results controller - Events

// Use this as a template... copy it, paste it (into your Model class), and then edit it
- (NSFetchedResultsController *)frc_event
{
    // If the frc is already configured, simply return it
    if (_frc_event) return _frc_event;
    
    // Otherwise, create a new frc, and set it as the property (and return it below)
    _frc_event = [_cdStack frcWithEntityNamed:@"Event" withPredicateFormat:nil predicateObject:nil sortDescriptors:@"timeStamp,NO" andSectionNameKeyPath:nil];
    
    return _frc_event;
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

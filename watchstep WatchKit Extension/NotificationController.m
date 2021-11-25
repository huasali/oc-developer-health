//
//  NotificationController.m
//  watchstep WatchKit Extension
//
//  Created by Huasali on 2021/11/23.
//

#import "NotificationController.h"


@interface NotificationController ()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    NSLog(@"[app][NotificationController] willActivate");
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    NSLog(@"[app][NotificationController] didDeactivate");
    // This method is called when watch view controller is no longer visible
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSLog(@"[app][NotificationController] didReceiveNotification %@",notification);
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
}

@end




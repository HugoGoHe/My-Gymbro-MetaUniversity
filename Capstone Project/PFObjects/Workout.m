//
//  Workout.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import "Workout.h"

@implementation Workout

@dynamic date;
@dynamic name;
@dynamic author;

+ (nonnull NSString *)parseClassName {
    return @"Workout";
}

+ (void) newWorkout: ( NSString * _Nullable )name withDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    Workout *newWorkout = [Workout new];
    newWorkout.date = date;
    newWorkout.name = name;
    newWorkout.author = [PFUser currentUser];
    
    [newWorkout saveInBackgroundWithBlock:completion];
}

@end

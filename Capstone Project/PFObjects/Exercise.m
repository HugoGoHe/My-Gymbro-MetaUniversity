//
//  Exercise.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/20/22.
//

#import "Exercise.h"

@implementation Exercise

@dynamic  name;
@dynamic weight;
@dynamic exerciseSets;
@dynamic workout;


+ (nonnull NSString *)parseClassName {
    return @"Exercise";
}

+(void) newExercise: (NSString *_Nullable)name withWeight:(float)weight withSet1:(NSNumber *)set1 withSet2:(NSNumber *)set2 withSet3:(NSNumber *)set3 withSet4:(NSNumber *)set4 withSet5:(NSNumber *)set5 withWorkout:(Workout *_Nullable) workout withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    Exercise *newExercise = [Exercise new];
    newExercise.name = name;
    newExercise.weight = weight;
    newExercise.exerciseSets = [NSArray arrayWithObjects:set1,set2,set3,set4,set5, nil];
    newExercise.workout = workout;
    [newExercise saveInBackgroundWithBlock:completion];
}

@end

//
//  Exercise.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/20/22.
//

#import "Exercise.h"

@implementation Exercise

@dynamic name;
@dynamic weight;
@dynamic set1;
@dynamic set2;
@dynamic set3;
@dynamic set4;
@dynamic set5;
@dynamic workout;


+ (nonnull NSString *)parseClassName {
    return @"Exercise";
}

+(void) newExercise: (NSString *_Nullable)name withWeight:(float)weight withSet1:(int)set1 withSet2:(int)set2 withSet3:(int)set3 withSet4:(int)set4 withSet5:(int)set5 withWorkout:(Workout *_Nullable) workout withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    Exercise *newExercise = [Exercise new];
    newExercise.name = name;
    newExercise.weight = weight;
    newExercise.set1 = set1;
    newExercise.set2 = set2;
    newExercise.set3 = set3;
    newExercise.set4 = set4;
    newExercise.set5 = set5;
    newExercise.workout = workout;
    [newExercise saveInBackgroundWithBlock:completion];
}

@end

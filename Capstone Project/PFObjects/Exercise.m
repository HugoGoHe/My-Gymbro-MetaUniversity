//
//  Exercise.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/20/22.
//

#import "Exercise.h"

@implementation Exercise

@dynamic  name;
@synthesize weight;
@synthesize exerciseSet1;
@synthesize exerciseSet2;
@synthesize exerciseSet3;
@synthesize exerciseSet4;
@synthesize exerciseSet5;
@synthesize workout;


+ (nonnull NSString *)parseClassName {
    return @"Exercise";
}

+(void) newExercise: (NSString *_Nullable)name withWeight:(float)weight withSet1:(int)set1 withSet2:(int)set2 withSet3:(int)set3 withSet4:(int)set4 withSet5:(int)set5 withWorkout:(Workout *_Nullable) workout withCompletion:(PFBooleanResultBlock  _Nullable)completion{
    Exercise *newExercise = [Exercise new];
    newExercise.name = name;
    newExercise.weight = weight;
    newExercise.exerciseSet1 = set1;
    newExercise.exerciseSet2 = set2;
    newExercise.exerciseSet3 = set3;
    newExercise.exerciseSet4 = set4;
    newExercise.exerciseSet5 = set5;
    newExercise.workout = workout;
    [newExercise saveInBackgroundWithBlock:completion];
}

@end

//
//  Exercise.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/20/22.
//

#import <Parse/Parse.h>
#import "Workout.h"

NS_ASSUME_NONNULL_BEGIN

@interface Exercise : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) float weight;
@property (nonatomic) int exerciseSet1;
@property (nonatomic) int exerciseSet2;
@property (nonatomic) int exerciseSet3;
@property (nonatomic) int exerciseSet4;
@property (nonatomic) int exerciseSet5;
@property(nonatomic, strong) Workout *workout;

+(void) newExercise: (NSString *_Nullable)name withWeight:(float)weight withSet1:(int)set1 withSet2:(int)set2 withSet3:(int)set3 withSet4:(int)set4 withSet5:(int)set5 withWorkout:(Workout *_Nullable) workout withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

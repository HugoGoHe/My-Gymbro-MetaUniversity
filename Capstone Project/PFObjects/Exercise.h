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
@property (nonatomic) NSArray *exerciseSets;
@property(nonatomic, strong) Workout *workout;
@property(nonatomic, strong) PFUser *username;
@property (nonatomic, strong) NSDate *postedAt;


+(void) newExercise: (NSString *_Nullable)name withWeight:(float)weight withSet1:(NSNumber *)set1 withSet2:(NSNumber *)set2 withSet3:(NSNumber *)set3 withSet4:(NSNumber *)set4 withSet5:(NSNumber *)set5 withWorkout:(Workout *_Nullable) workout withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

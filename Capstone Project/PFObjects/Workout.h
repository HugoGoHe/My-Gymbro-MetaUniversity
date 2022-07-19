//
//  Workout.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Workout : PFObject<PFSubclassing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PFUser *author;

+ (void) newWorkout: ( NSString * _Nullable )name withDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

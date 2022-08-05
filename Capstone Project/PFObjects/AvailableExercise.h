//
//  AvailableExercise.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 8/1/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface AvailableExercise : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString * name;

@end

NS_ASSUME_NONNULL_END

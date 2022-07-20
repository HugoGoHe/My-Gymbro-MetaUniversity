//
//  CurrentWorkoutViewController.h
//  
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CurrentWorkoutViewControllerDelegate

- (void) getWorkouts;

@end

@interface CurrentWorkoutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *name;
@property (weak, nonatomic) IBOutlet UIDatePicker *date;
@property (nonatomic) Boolean exists;
@property(strong, nonatomic) Workout *selectedWorkout;
@property (strong, nonatomic) id<CurrentWorkoutViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END

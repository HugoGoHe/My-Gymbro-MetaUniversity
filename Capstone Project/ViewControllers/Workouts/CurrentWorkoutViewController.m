//
//  CurrentWorkoutViewController.m
//  
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import "CurrentWorkoutViewController.h"
#import "Workout.h"

@interface CurrentWorkoutViewController ()

@end

@implementation CurrentWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.exists){
        self.name.text = self.selectedWorkout.name;
        self.date.date = self.selectedWorkout.date;
    }
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(id)sender {
    //Existing Workout
    if(self.exists){
        self.selectedWorkout.date = self.date.date;
        self.selectedWorkout.name = self.name.text;
        [self.selectedWorkout saveInBackgroundWithBlock:nil];
    //New Workout
    }else{
        [Workout newWorkout:self.name.text withDate:self.date.date withCompletion:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end


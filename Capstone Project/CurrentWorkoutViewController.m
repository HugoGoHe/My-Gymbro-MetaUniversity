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
    // Do any additional setup after loading the
    NSLog(@"%hhu",self.exists);
}


- (IBAction)didTapCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(id)sender {
    
    if(self.exists){
        self.selectedWorkout.date = self.date.date;
        self.selectedWorkout.name = self.name.text;
        [self.selectedWorkout saveInBackgroundWithBlock:nil];
        [self dismissViewControllerAnimated:YES completion:nil];

        
    }else{
        [Workout newWorkout:self.name.text withDate:self.date.date withCompletion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


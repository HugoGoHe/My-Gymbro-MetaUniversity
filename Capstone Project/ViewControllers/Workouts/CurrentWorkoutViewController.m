//
//  CurrentWorkoutViewController.m
//  
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import "CurrentWorkoutViewController.h"
#import "Workout.h"
#import "Exercise.h"
#import "ExerciseCell.h"


@interface CurrentWorkoutViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) NSMutableArray *arrayOfExercises;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation CurrentWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.exists){
        self.name.text = self.selectedWorkout.name;
        self.date.date = self.selectedWorkout.date;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.arrayOfExercises = [[NSMutableArray alloc] init];
    [self getExercises];
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getExercises) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(id)sender {
    //Existing Workout
    if(self.exists){
        self.selectedWorkout.date = self.date.date;
        self.selectedWorkout.name = self.name.text;
        [self.selectedWorkout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
            if(!error){
                [self.delegate getWorkouts];
            }
        }];
    //New Workout
    }else{
        [Workout newWorkout:self.name.text withDate:self.date.date withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                [self.delegate getWorkouts];
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getExercises{
    //Performing query to get the exercises of the workout from newest to oldest
    PFQuery *exerciseQuery = [Exercise query];
    [exerciseQuery whereKey:@"workout" equalTo:self.selectedWorkout];
    [exerciseQuery orderByDescending:@"createdAt"];
    [exerciseQuery findObjectsInBackgroundWithBlock:^(NSArray<Exercise *> * _Nullable exercises, NSError * _Nullable error) {
        if (exercises) {
            //Storing the data in an array and reloading the tableView
            self.arrayOfExercises = (NSMutableArray *)exercises;
            [self.tableView reloadData];
        }
        else {
            // handle error
            NSLog(@"%@", error.localizedDescription);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Exercises"
                                                                           message:@"The internet connection appears to be offline."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        [self.refreshControl endRefreshing];
    }];
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ExerciseCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Exercise Cell" forIndexPath:indexPath];
    Exercise *exercise = self.arrayOfExercises[indexPath.row];
    cell.nameLabel.text = exercise.name;
    cell.weightLabel.text = [@(exercise.weight) stringValue];
    cell.set1Label.text = [@(exercise.set1) stringValue];
    cell.set2Label.text = [@(exercise.set2) stringValue];
    cell.set3Label.text = [@(exercise.set3) stringValue];
    cell.set4Label.text = [@(exercise.set4) stringValue];
    cell.set5Label.text = [@(exercise.set5) stringValue];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfExercises.count;

}

@end


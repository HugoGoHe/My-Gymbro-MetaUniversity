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
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *repsTextField;

@end

@implementation CurrentWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.arrayOfExercises = [[NSMutableArray alloc] init];
    
    if(self.exists){
        self.name.text = self.selectedWorkout.name;
        self.date.date = self.selectedWorkout.date;
    }else{
        //If the workout does not exists, we need to create it in the database
        self.selectedWorkout = [Workout new];
        self.selectedWorkout.author = [PFUser currentUser];
        self.selectedWorkout.name = self.name.text;
        self.selectedWorkout.date = self.date.date;
        [self.selectedWorkout saveInBackground];
    }
    [self getExercises];
}

- (IBAction)didTapSave:(id)sender {
    //Since the workout is already in the database, it is just saved in the background
    self.selectedWorkout.date = self.date.date;
    self.selectedWorkout.name = self.name.text;
    [self.selectedWorkout saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
        if(!error){
            [self.delegate getWorkouts];
        }
    }];
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
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"There are no exercises"
                                                                           message:@"Try adding some to your workout"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (IBAction)didTapAdd:(id)sender {
    NSArray *repsPerSet = [self.repsTextField.text componentsSeparatedByString:@"/"];
    [Exercise newExercise:self.searchBar.text withWeight:[self.weightTextField.text floatValue] withSet1:[[repsPerSet objectAtIndex:0] integerValue] withSet2:[[repsPerSet objectAtIndex:1] integerValue] withSet3:[[repsPerSet objectAtIndex:2] integerValue] withSet4:[[repsPerSet objectAtIndex:3] integerValue] withSet5:[[repsPerSet objectAtIndex:4] integerValue] withWorkout:self.selectedWorkout withCompletion:^(BOOL succeeded, NSError * _Nullable error){
        if(!error){
            [self getExercises];
        }
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


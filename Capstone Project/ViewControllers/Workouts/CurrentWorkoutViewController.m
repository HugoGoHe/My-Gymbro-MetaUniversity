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
    //Check for any blank fields
    if([self.searchBar.text isEqual:@""] || [self.weightTextField.text isEqual:@""] || [self.repsTextField.text isEqual:@""]){
        self.errorLabel.text = @"One or more fields are Blank";
    }
    else if ([self.weightTextField.text floatValue] <= 0){
        self.errorLabel.text = @"The weight is not valid";
    }
    else{
        //Getting the array of the sets
        NSArray *repsPerSet = [self.repsTextField.text componentsSeparatedByString:@"/"];
        //Checking if sets are valid
        if(![self areSetsValid:repsPerSet]){
            self.errorLabel.text = @"Input not valid";
        }else{
            //Need to make the array mutable to add ceros
            NSMutableArray *repsPerSetMut = [(NSArray *)repsPerSet mutableCopy];
            //Adding 0 if set is empty
            while(repsPerSetMut.count < 5){
                [repsPerSetMut addObject: @"0"];
            }
            [Exercise newExercise:self.searchBar.text withWeight:[self.weightTextField.text floatValue] withSet1:[[repsPerSetMut objectAtIndex:0] intValue] withSet2:[[repsPerSetMut objectAtIndex:1] intValue] withSet3:[[repsPerSetMut objectAtIndex:2] intValue] withSet4:[[repsPerSetMut objectAtIndex:3] intValue] withSet5:[[repsPerSetMut objectAtIndex:4] intValue] withWorkout:self.selectedWorkout withCompletion:^(BOOL succeeded, NSError * _Nullable error){
                if(!error){
                    [self getExercises];
                }
            }];
            self.searchBar.text = @"";
            self.weightTextField.text = @"";
            self.repsTextField.text = @"";
        }
    }
}

-(BOOL) areSetsValid:(NSArray*) repsPerSet{
    int maxNumSets = 5;
    if(repsPerSet.count > maxNumSets){
        return FALSE;
    }
    int i;
    for(i = 0; i < repsPerSet.count; i++){
        if (![self isSetValid: repsPerSet[i]]){
            return FALSE;
        }
    }
    return TRUE;
}

-(BOOL) isSetValid:(id) set{
    int maxNumReps = 99;
    
    //if intValue method returns 0 means it is either 0 or not a number
    //also we dont want negative numbers
    if ([set intValue] <= 0){
        return FALSE;
    }
    if ([set intValue]> maxNumReps){
        return FALSE;
    }
    return TRUE;
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


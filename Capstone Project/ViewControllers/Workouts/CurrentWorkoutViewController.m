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
#import "ExerciseListCell.h"


@interface CurrentWorkoutViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(strong, nonatomic) NSMutableArray *arrayOfExercises;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *repsTextField;
@property (weak, nonatomic) IBOutlet UITableView *suggestedTextTableView;
@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;
@property(strong, nonatomic) NSMutableArray *listOfExercises;
@property(strong, nonatomic) NSMutableArray *suggestedExercises;

@end

@implementation CurrentWorkoutViewController

static const int MAXNUMSETS = 5;
static const int MAXNUMREPS = 99;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.exerciseTextField.delegate = self;
    
    self.suggestedTextTableView.delegate = self;
    self.suggestedTextTableView.dataSource = self;
    self.suggestedTextTableView.scrollEnabled = YES;
    self.suggestedTextTableView.hidden = YES;
    self.suggestedTextTableView.rowHeight = 40;
    [self.view addSubview:self.suggestedTextTableView];
    
    if(self.exists){
        self.name.text = self.selectedWorkout.name;
        self.date.date = self.selectedWorkout.date;
    } else{
        //If the workout does not exists, we need to create it in the database
        self.selectedWorkout = [Workout new];
        self.selectedWorkout.author = [PFUser currentUser];
        self.selectedWorkout.name = self.name.text;
        self.selectedWorkout.date = self.date.date;
        [self.selectedWorkout saveInBackground];
    }
    [self getExercises];
    
   // NSArray *availableExercises = @[@"leg press", @"leg extensions", @"leg curls"];
    self.listOfExercises = [[NSMutableArray alloc] init];
    self.suggestedExercises = [[NSMutableArray alloc] init];
 //   self.listOfExercises = [availableExercises mutableCopy];;
  //  self.autocompleteExercises = [self.listOfExercises mutableCopy];
}
//Table view is hidden when the user finishes editing
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.suggestedTextTableView.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    //Performs a query only if it is the first letter typed
    if(substring.length == 1){
        //Fetch Data
        PFQuery *availableExercisesQuery = [PFQuery queryWithClassName:@"AvailableExercise"];
        [availableExercisesQuery whereKey:@"name" hasPrefix:substring];
        [availableExercisesQuery findObjectsInBackgroundWithBlock:^(NSArray *availableExercises, NSError *error) {
            if (!error) {
                if (availableExercises.count > 0){
                    self.listOfExercises = [availableExercises valueForKey:@"name"];
                    self.suggestedExercises = [self.listOfExercises mutableCopy];
                    [self.suggestedTextTableView reloadData];
                    [self.suggestedTextTableView sizeToFit];
                    self.suggestedTextTableView.hidden = NO;
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }else if (substring.length > 1){
        //Searches on the fetched array
        [self searchAutocompleteEntriesWithSubstring:substring];
    }else if (substring.length == 0){
        self.suggestedTextTableView.hidden = YES;
        [self.suggestedExercises removeAllObjects];
    }
    
    return YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [self.suggestedExercises removeAllObjects];
    for(NSString *exercise in self.listOfExercises) {
        NSRange substringRange = [exercise rangeOfString:substring];
        if (substringRange.location == 0){
            [self.suggestedExercises addObject:exercise];
        }
    }
    [self.suggestedTextTableView reloadData];
    self.suggestedTextTableView.hidden = NO;

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
        if (exercises && exercises.count > 0) { //if I check exercises.count > 0 then this happens when it is a past workout not only a new one.
            //Storing the data in an array and reloading the tableView
            self.arrayOfExercises = (NSMutableArray *)exercises;
            [self.tableView reloadData];
        } else {
            // handle error
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
    if([self.exerciseTextField.text isEqual:@""] || [self.weightTextField.text isEqual:@""] || [self.repsTextField.text isEqual:@""]){
        self.errorLabel.text = @"One or more fields are blank";
    }
    else if ([self.weightTextField.text floatValue] <= 0){
        self.errorLabel.text = @"The weight is not valid";
    }
    //Checking if the exercise is in the list of available exercise
    else if (![self.listOfExercises containsObject:self.exerciseTextField.text]){
        self.errorLabel.text = @"Exercise not valid";
    }
    else{
        self.errorLabel.text =@"";
        //Getting the array of the sets
        NSArray *repsPerSet = [self.repsTextField.text componentsSeparatedByString:@"/"];
        //Checking if sets are valid
        if(![self areSetsValid:repsPerSet]){
            self.errorLabel.text = @"Sets input is not valid";
        }else{
            //Need to make the array mutable to add ceros
            NSMutableArray *repsPerSetMut = [(NSArray *)repsPerSet mutableCopy];
            //Adding 0 if set is empty
            while(repsPerSetMut.count < 5){
                [repsPerSetMut addObject: @"0"];
            }
            [Exercise newExercise:self.exerciseTextField.text
                       withWeight:[self.weightTextField.text floatValue]
                         withSet1:[repsPerSetMut objectAtIndex:0]
                         withSet2:[repsPerSetMut objectAtIndex:1]
                         withSet3:[repsPerSetMut objectAtIndex:2]
                         withSet4:[repsPerSetMut objectAtIndex:3]
                         withSet5:[repsPerSetMut objectAtIndex:4]
                      withWorkout:self.selectedWorkout withCompletion:^(BOOL succeeded, NSError * _Nullable error)
             {
                if(!error) {
                    [self getExercises];
                }
            }];
            self.exerciseTextField.text = @"";
            self.weightTextField.text = @"";
            self.repsTextField.text = @"";
        }
    }
}

-(BOOL) areSetsValid:(NSArray*) repsPerSet{
    if(repsPerSet.count > MAXNUMSETS){
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
    //if intValue method returns 0 means it is either 0 or not a number
    //also we dont want negative numbers
    if ([set intValue] <= 0){
        return FALSE;
    }
    if ([set intValue]> MAXNUMREPS){
        return FALSE;
    }
    return TRUE;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.tableView){
        ExerciseCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Exercise Cell" forIndexPath:indexPath];
        Exercise *exercise = self.arrayOfExercises[indexPath.row];
        cell.nameLabel.text = exercise.name;
        cell.weightLabel.text = [NSString stringWithFormat:@"%.02f", exercise.weight];
        cell.exerciseSet1Label.text = [NSString stringWithFormat:@"%@", [exercise.exerciseSets objectAtIndex:0]];
        cell.exerciseSet2Label.text = [NSString stringWithFormat:@"%@", [exercise.exerciseSets objectAtIndex:0]];
        cell.exerciseSet3Label.text = [NSString stringWithFormat:@"%@", [exercise.exerciseSets objectAtIndex:0]];
        cell.exerciseSet4Label.text = [NSString stringWithFormat:@"%@", [exercise.exerciseSets objectAtIndex:0]];
        cell.exerciseSet5Label.text = [NSString stringWithFormat:@"%@", [exercise.exerciseSets objectAtIndex:0]];
        return cell;
    }else{
        //Calling observer for the contentSize property on the suggestedTextTableView
        [self.suggestedTextTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
        ExerciseListCell *cell = [self.suggestedTextTableView dequeueReusableCellWithIdentifier:@"Exercise List Cell" forIndexPath:indexPath];
        NSString *name = [self.suggestedExercises objectAtIndex:indexPath.row];
        cell.nameOfExerciseLabel.text = name;
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView){
        return self.arrayOfExercises.count;
    }else{
        if(self.suggestedExercises.count == 0){
            self.suggestedTextTableView.hidden = YES;
        }
        return self.suggestedExercises.count;
    }
}

//Deleting rows from tableView and database
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView){
        if (editingStyle == UITableViewCellEditingStyleDelete){
            [self.arrayOfExercises[indexPath.row] deleteInBackground];
            [self.arrayOfExercises removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.suggestedTextTableView){
        tableView.hidden = YES;
        self.exerciseTextField.text = [self.suggestedExercises objectAtIndex:indexPath.row];
    }
}

//Add an observer for the contentSize property on the table view, and adjust the frame size accordingly
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
         CGRect frame = self.suggestedTextTableView.frame;
         frame.size = self.suggestedTextTableView.contentSize;
         self.suggestedTextTableView.frame = frame;
    }

@end


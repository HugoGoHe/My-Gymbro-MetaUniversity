//
//  WorkoutsViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/8/22.
//

#import "WorkoutsViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"
#import "WorkoutCell.h"
#import "Workout.h"
#import "CurrentWorkoutViewController.h"

@interface WorkoutsViewController ()<UITableViewDelegate, UITableViewDataSource, CurrentWorkoutViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *arrayOfWorkouts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation WorkoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 4;
    self.tableView.sectionFooterHeight = 4;
    
    self.arrayOfWorkouts = [[NSMutableArray alloc] init];
    [self getWorkouts];
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getWorkouts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
    LoginViewController * loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.view.window.rootViewController = loginViewController;
}

- (void) getWorkouts{
    //Performing query to get the workouts of the user from newest to oldest
    PFQuery *workoutQuery = [Workout query];
    [workoutQuery whereKey:@"author" equalTo: [PFUser currentUser]];
    [workoutQuery orderByDescending:@"date"];
    [workoutQuery findObjectsInBackgroundWithBlock:^(NSArray<Workout *> * _Nullable workouts, NSError * _Nullable error) {
        if (workouts) {
            //Storing the data in an array and reloading the tableView
            self.arrayOfWorkouts = (NSMutableArray *)workouts;
            [self.tableView reloadData];
        }
        else {
            // handle error
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Workouts"
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

#pragma mark - TableView

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WorkoutCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Workout Cell" forIndexPath:indexPath];
    Workout *workout = self.arrayOfWorkouts[indexPath.section];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    cell.dateLabel.text = [dateFormatter stringFromDate:workout.date];
    cell.nameLabel.text = workout.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//Deleting rows from tableView and database
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.arrayOfWorkouts[indexPath.section] deleteInBackground];
        [self.arrayOfWorkouts removeObjectAtIndex:indexPath.section];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.arrayOfWorkouts.count;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //New Workout
    if([[segue identifier] isEqualToString: @"fromNew"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier: @"currentWorkout"];
        
        CurrentWorkoutViewController *cwvc = (CurrentWorkoutViewController *) nav.topViewController;
        cwvc.delegate = self;
        
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    //Existing Workout
    if([[segue identifier] isEqualToString: @"fromCell"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier: @"currentWorkout"];
        
        NSIndexPath *myIndexPath = [self.tableView indexPathForCell:sender];
        NSInteger index = myIndexPath.row;
        Workout *selectedWorkout = self.arrayOfWorkouts[index];
        CurrentWorkoutViewController *cwvc = (CurrentWorkoutViewController *) nav.topViewController;
        cwvc.selectedWorkout = selectedWorkout;
        cwvc.exists = TRUE;
        cwvc.delegate = self;
        
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}
@end

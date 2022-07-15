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

@interface WorkoutsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *arrayOfWorkouts;

@end

@implementation WorkoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the		 view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.arrayOfWorkouts = [[NSMutableArray alloc] init];
    [self getWorkouts];
}
- (IBAction)didTapLogout:(id)sender {

    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];

    LoginViewController * loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.view.window.rootViewController = loginViewController;
    
}


- (void) getWorkouts{
    
    PFQuery *workoutQuery = [Workout query];
    [workoutQuery whereKey:@"author" equalTo: [PFUser currentUser]];
    
    [workoutQuery findObjectsInBackgroundWithBlock:^(NSArray<Workout *> * _Nullable workouts, NSError * _Nullable error) {
        if (workouts) {
            // do something with the data fetched
            self.arrayOfWorkouts = (NSMutableArray *)workouts;
            [self.tableView reloadData];

        }
        else {
            // handle error
            NSLog(@"%@", error.localizedDescription);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Workouts"
                                           message:@"The internet connection appears to be offline."
                                           preferredStyle:UIAlertControllerStyleAlert];
             
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
             
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
      //  [self.refreshControl endRefreshing];
        NSLog(@"%@", self.arrayOfWorkouts);

    }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WorkoutCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Workout Cell" forIndexPath:indexPath];
    
    Workout *workout = self.arrayOfWorkouts[indexPath.row];
    cell.nameLabel.text = workout.name;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
       [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.dateLabel.text = [dateFormatter stringFromDate:workout.date];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfWorkouts.count;
}



@end

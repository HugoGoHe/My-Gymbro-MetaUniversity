//
//  WorkoutsViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/8/22.
//

#import "WorkoutsViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"

@interface WorkoutsViewController ()

@end

@implementation WorkoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapLogout:(id)sender {

    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];

    LoginViewController * loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.view.window.rootViewController = loginViewController;
    
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

//
//  LoginViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/8/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
            } else {
                NSLog(@"User logged in successfully");
                // display view controller that needs to shown after successful login
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
                self.view.window.rootViewController = tabBarController;
                //So it goes to the second item of the tab bar first
                [tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex:1]];
               
            }
        }];
}
@end

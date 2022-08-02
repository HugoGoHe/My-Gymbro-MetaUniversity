//
//  SignupViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/8/22.
//

#import "SignupViewController.h"
#import "Parse/Parse.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapSignUp:(id)sender {
    //Check for any blank fields
    if([self.passwordTextField.text isEqual:@""] || [self.confirmPasswordTextField.text isEqual:@""] || [self.usernameTextField.text isEqual:@""]){
        self.samePasswordLabel.text = @"One or more fields are Blank.";
    }else{
        //Check if password fields are not the same
        if (![self.passwordTextField.text isEqual:self.confirmPasswordTextField.text]) {
            self.samePasswordLabel.text = @"Passwords must be the same.";
        }else{
            self.samePasswordLabel.text = @"";
            PFUser *newUser = [PFUser user];
            newUser.username = self.usernameTextField.text;
            newUser.password = self.passwordTextField.text;
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                //Check for existing error
                if (error != nil) {
                    self.samePasswordLabel.text = error.localizedDescription;
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations"
                                                                                   message:@"Your account has been successfully created!"
                                                                            preferredStyle:(UIAlertControllerStyleAlert)];
                    // create an ok action
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                        // handle cancel response here.
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:^{
                        // optional code for what happens after the alert controller has finished presenting
                    }];
                }
            }];
        }
    }
}
@end

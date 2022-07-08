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
    // Do any additional setup after loading the view.

}
- (IBAction)didTapSignUp:(id)sender {
    
    if([self.passwordTextField.text isEqual:@""] || [self.confirmPasswordTextField.text isEqual:@""] || [self.usernameTextField.text isEqual:@""]){
        
        self.samePasswordLabel.text = @"One or more fields are Blank.";
    }else{
        if (![self.passwordTextField.text isEqual:self.confirmPasswordTextField.text]) {
            
            self.samePasswordLabel.text = @"Passwords must be the same.";
        }else{
            
            self.samePasswordLabel.text = @"";
            PFUser *newUser = [PFUser user];
            
            newUser.username = self.usernameTextField.text;
            newUser.password = self.passwordTextField.text;
            
            NSLog(@"SignUp completed :D!");
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                 if (error != nil) {
                     NSLog(@"Error: %@", error.localizedDescription);
                 } else {
                     NSLog(@"User registered successfully");

                     // manually segue to logged in view
                 }
             }];
            

            
            
    
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations"
                                                                                       message:@"Your account has been successfully created!"
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            // create a cancel action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle cancel response here. Doing nothing will dismiss the view.
                [self dismissViewControllerAnimated:YES completion:nil];
                                                              }];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
            
            
        }
        
        
        
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

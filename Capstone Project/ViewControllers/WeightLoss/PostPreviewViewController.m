//
//  PostPreviewViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import "PostPreviewViewController.h"
#import "ProgressPic.h"

@interface PostPreviewViewController ()

@property(nonatomic, strong) NSDate *currentDate;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation PostPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:self.currentDate];
    self.dateLabel.text = dateString;
    self.progressPic.image = self.selectedImage;
}

- (IBAction)didTapCheckMark:(id)sender {
    
    if (!([self.weightLabel.text intValue] > 0 && [self.weightLabel.text intValue] < 1000)){
        self.errorLabel.text = @"Type a valid weight";
        //Hide the keyboard
        [self.view endEditing:YES];
    }else{
        self.errorLabel.text = @"";
        self.selectedImage = [self resizeImage:self.selectedImage];
        [ProgressPic postUserImage:self.selectedImage withWeight:[self.weightLabel.text floatValue] withDate:self.currentDate withCompletion:^(BOOL succeeded, NSError * _Nullable error){
            if(!error){
                [self.delegate didPost];
            }
        }];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *nav = [storyboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [nav setSelectedViewController:[nav.viewControllers objectAtIndex:0]];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

//Method that resizes the images used by the user in order for them to be of an acceptable file size for the Parse database.
- (UIImage *)resizeImage:(UIImage *)image {
    // Set size for new images
    CGSize size = CGSizeMake(400, 400);
    // Create an image view with the desired size
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    // Fill the newly created imade view with the selected image
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    // Change the size of the image and store it in a new variable
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Return the resized image
    return newImage;
}

- (IBAction)didTapBack:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *nav = [storyboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [nav setSelectedViewController:[nav.viewControllers objectAtIndex:0]];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }
}
@end

//
//  WeightLossViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/10/22.
//

#import "WeightLossViewController.h"
#import "PostPreviewViewController.h"

@interface WeightLossViewController ()
@property(strong,nonatomic) UIImage *selectedImage;
@end

@implementation WeightLossViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapNewPost:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];

}


//Implementing UIImagePickerController's delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    // Get the image captured by the UIImagePickerController
    self.selectedImage = info[UIImagePickerControllerOriginalImage];

    // Do something with the images (based on your use case)
    
    // Dismiss UIImagePickerController to go back to your original view controller

    [self performSegueWithIdentifier:@"previewSegue" sender:nil];


    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString: @"previewSegue"]){
        UINavigationController *nav = [segue destinationViewController];
        PostPreviewViewController *ppvc = (PostPreviewViewController *) nav.topViewController;
        
        ppvc.selectedImage = self.selectedImage;
        
    }
}


@end

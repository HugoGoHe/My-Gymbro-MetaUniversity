//
//  PostPreviewViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import "PostPreviewViewController.h"
#import "Post.h"

@interface PostPreviewViewController ()

@property(nonatomic, strong) NSDate *currentDate;

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
    [Post postUserImage:self.selectedImage withWeight:[self.weightLabel.text floatValue] withDate:self.currentDate withCompletion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *nav = [storyboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [nav setSelectedViewController:[nav.viewControllers objectAtIndex:0]];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
    [self.delegate didPost];
}

- (IBAction)didTapBack:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *nav = [storyboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [nav setSelectedViewController:[nav.viewControllers objectAtIndex:0]];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
@end

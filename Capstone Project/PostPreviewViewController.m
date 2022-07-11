//
//  PostPreviewViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import "PostPreviewViewController.h"

@interface PostPreviewViewController ()

@end

@implementation PostPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
       [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    self.dateLabel.text = dateString;
 
    
    self.progressPic.image = self.selectedImage;
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

//
//  WeightLossViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/10/22.
//

#import "WeightLossViewController.h"
#import "PostPreviewViewController.h"
#import "Parse/Parse.h"
#import "ProgressPic.h"
#import "PictureGridCell.h"
#import "SlideshowViewController.h"

@interface WeightLossViewController () <UICollectionViewDelegate, UICollectionViewDataSource, PostPreviewViewControllerDelegate>

@property(strong,nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) NSMutableArray *arrayOfPosts;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSMutableArray <NSURL *> *urls;
@end

@implementation WeightLossViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.arrayOfPosts = [[NSMutableArray alloc] init];
    [self getProgressPics];
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getProgressPics) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.urls = [[NSMutableArray alloc] init];
}

- (IBAction)didTapNewPost:(id)sender {
    //Picking an image
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

//Implementing UIImagePickerController's delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    self.selectedImage = info[UIImagePickerControllerOriginalImage];
    [self performSegueWithIdentifier:@"previewSegue" sender:nil];
}

- (void) getProgressPics{
    //Performing query to get the posts of the user from newest to oldest
    PFQuery *getQuery = [ProgressPic query];
    [getQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [getQuery orderByDescending:@"createdAt"];
    [getQuery findObjectsInBackgroundWithBlock:^(NSArray<ProgressPic *> * _Nullable posts, NSError * _Nullable error) {
        if (!error) {
            //Storing the data in an array and reloading the collectionView
            self.arrayOfPosts = (NSMutableArray *)posts;
            [self.collectionView reloadData];
        }
        else {
            // handle error
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Posts"
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

- (void) didPost{
    [self getProgressPics];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PictureGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Picture Grid Cell" forIndexPath:indexPath];
    ProgressPic *progressPic = self.arrayOfPosts[indexPath.row];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:progressPic.image.url]];
    //Array for the slideshow
    [self.urls addObject:[NSURL URLWithString:progressPic.image.url]];
    
    cell.progressPic.image = [UIImage imageWithData:imageData];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width/3, 128);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //Passing data to the Post Preview View Controller
    if([[segue identifier] isEqualToString: @"previewSegue"]){
        UINavigationController *nav = [segue destinationViewController];
        PostPreviewViewController *ppvc = (PostPreviewViewController *) nav.topViewController;
        ppvc.selectedImage = self.selectedImage;
        ppvc.delegate = self;
    }
    
    if([[segue identifier] isEqualToString: @"Slideshow"]){
        UINavigationController *nav = [segue destinationViewController];
        SlideshowViewController *ssvc = (SlideshowViewController *) nav.topViewController;
        ssvc.urls = self.urls;
    }
    
}
@end

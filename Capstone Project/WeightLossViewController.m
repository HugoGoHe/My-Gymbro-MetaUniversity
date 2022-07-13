//
//  WeightLossViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/10/22.
//

#import "WeightLossViewController.h"
#import "PostPreviewViewController.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "PictureGridCell.h"


@interface WeightLossViewController () <UICollectionViewDelegate, UICollectionViewDataSource, PostPreviewViewControllerDelegate>

@property(strong,nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) NSMutableArray *arrayOfPosts;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;


@end

@implementation WeightLossViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.arrayOfPosts = [[NSMutableArray alloc] init];
    [self getPosts];
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getPosts) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
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
     //   ppvc.progressPic.image = self.selectedImage;
        ppvc.selectedImage = self.selectedImage;
   
    }
    

}

- (void) getPosts{
    PFQuery *postQuery = [Post query];
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            // do something with the data fetched
            self.arrayOfPosts = (NSMutableArray *)posts;

            [self.collectionView reloadData];

        }
        else {
            // handle error
            NSLog(@"%@", error.localizedDescription);
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
    
    [self getPosts];
    [self.collectionView reloadData];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PictureGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Picture Grid Cell" forIndexPath:indexPath];
    
    Post *post1 = self.arrayOfPosts[indexPath.row];
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:post1.image.url]];
    cell.progressPic.image = [UIImage imageWithData:imageData];
    
    
    return cell;
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        return self.arrayOfPosts.count;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width/3, 128);

}

@end

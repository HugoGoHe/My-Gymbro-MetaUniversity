//
//  SlideshowViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/28/22.
//

#import "SlideshowViewController.h"
#import "KASlideShow.h"
#import "Parse/Parse.h"
#import "ProgressPic.h"

@interface SlideshowViewController ()<KASlideShowDataSource, KASlideShowDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet KASlideShow *slideshow;
@property (strong, nonatomic) NSArray <ProgressPic *> *posts;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (strong, nonatomic) NSMutableArray <UIImage *> *uiImages;
@end

@implementation SlideshowViewController{
    NSMutableArray * _datasource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];

    _speedSlider.alpha = .5;
    [_speedSlider setUserInteractionEnabled:NO];

     _datasource = self.urls;
     // KASlideshow
    self.slideshow.datasource = self;
    self.slideshow.delegate = self;
    [self.slideshow setDelay:1]; // Delay between transitions
    [self.slideshow setTransitionDuration:.5]; // Transition duration
    [self.slideshow setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
    [self.slideshow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    [self.slideshow addGesture:KASlideShowGestureTap]; // Gesture to go previous/next directly on the image
    
    [_slideshow setTransitionType:KASlideShowTransitionFade];
    _slideshow.gestureRecognizers = nil;
    [_slideshow addGesture:KASlideShowGestureTap];
}

#pragma mark - KASlideShow datasource

- (NSObject *)slideShow:(KASlideShow *)slideshow objectAtIndex:(NSUInteger)index
{
    return _datasource[index];
}

- (NSUInteger)slideShowImagesNumber:(KASlideShow *)slideshow
{
    return _datasource.count;
}

#pragma mark - Actions

- (IBAction)selectChangeValue:(id)sender {
    UISlider * slider = (UISlider *) sender;
    [_slideshow setDelay: 4 - @(slider.value).floatValue]; // Delay between transitions
}

- (IBAction)startStop:(id)sender {
    UIButton * button = (UIButton *) sender;
    
    if(self.slideshow.state != KASlideShowStateStarted){
        _speedSlider.alpha = 1;
        [_speedSlider setUserInteractionEnabled:YES];
        [_slideshow start];
        [button setTitle:@"❚❚" forState:UIControlStateNormal];
    } else{
        _speedSlider.alpha = .5;
        [_speedSlider setUserInteractionEnabled:NO];
        [_slideshow stop];
        [button setTitle:@"▶" forState:UIControlStateNormal];
    }
}

- (IBAction)didTapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
     

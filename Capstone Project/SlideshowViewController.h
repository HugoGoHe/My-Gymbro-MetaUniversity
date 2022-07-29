//
//  SlideshowViewController.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlideshowViewController : UIViewController<KASlideShowDelegate>

@property (strong, nonatomic) NSMutableArray <NSURL *>  *urls;

@end

NS_ASSUME_NONNULL_END

//
//  CurrentWorkoutViewController.h
//  
//
//  Created by Hugo Gomez Herrera on 7/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrentWorkoutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *name;
@property (weak, nonatomic) IBOutlet UIDatePicker *date;

@end

NS_ASSUME_NONNULL_END

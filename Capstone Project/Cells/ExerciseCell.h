//
//  ExerciseCell.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/20/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExerciseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseSet1Label;
@property (weak, nonatomic) IBOutlet UILabel *exerciseSet2Label;
@property (weak, nonatomic) IBOutlet UILabel *exerciseSet3Label;
@property (weak, nonatomic) IBOutlet UILabel *exerciseSet4Label;
@property (weak, nonatomic) IBOutlet UILabel *exerciseSet5Label;

@end

NS_ASSUME_NONNULL_END

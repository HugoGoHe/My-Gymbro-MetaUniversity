//
//  StatsViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/25/22.
//

#import "StatsViewController.h"
#import "ChartCell.h"
#import "Highcharts/Highcharts.h"
#import "Parse/Parse.h"
#import "ProgressPic.h"
#import "Exercise.h"

@interface StatsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *WeightChartView;
//ProgressPics
@property (strong, nonatomic) NSArray *progressPics;
@property (strong, nonatomic) NSArray *weights;
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) NSMutableArray *formatedDates;

//Weight lifted in exercises
@property (strong, nonatomic) NSArray *availableExercises;
@property (strong, nonatomic) NSArray *userExercises;
@property (strong, nonatomic) NSMutableArray *weightsOfExercises;



@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 300;
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //Getting the data (Progress Pics)
    self.dates = [[NSMutableArray alloc] init];
    self.weights = [[NSMutableArray alloc] init];
    self.formatedDates = [[NSMutableArray alloc] init];
    
    self.availableExercises = [[NSArray alloc] init];
    self.userExercises = [[NSArray alloc] init];
    self.weightsOfExercises =[[NSMutableArray alloc] init];

    [self getData];

}

-(void)getData{
    //Body weight change over time
    PFQuery *progressPicQuery = [ProgressPic query];
    [progressPicQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [progressPicQuery orderByAscending:@"postedAt"];
    [progressPicQuery findObjectsInBackgroundWithBlock:^(NSArray<ProgressPic *>* _Nullable progressPics, NSError * _Nullable error){
        if (progressPics.count > 0) {
            self.progressPics = progressPics;
            //Checking postedAt column for testing, that way I can modify the date of the post
            //instead of createdAt column
            self.dates = [progressPics valueForKey:@"postedAt"];
            NSLog(@"%@", self.dates);
            self.weights = [progressPics valueForKey:@"weight"];
            NSLog(@"%@", self.weights);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            for (int i = 0; i < self.dates.count; i++) {
                [self.formatedDates addObject:[dateFormatter stringFromDate:self.dates[i]]];
            }
       //     NSLog(@"%@", self.formatedDates);
            [self irregularIntervalsChart:self.WeightChartView];
            [self.tableView reloadData];

        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    //Weight lifted in different exercises
    
    //Getting array of available exercises
    PFQuery *availableExercisesQuery = [PFQuery queryWithClassName:@"AvailableExercise"];
    [availableExercisesQuery findObjectsInBackgroundWithBlock:^(NSArray *availableExercises, NSError *error) {
        if (!error) {
            self.availableExercises = [availableExercises valueForKey:@"name"];
            }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    PFQuery *userExercises = [Exercise query];
    [userExercises whereKey:@"username" equalTo:[PFUser currentUser]];
    [userExercises orderByAscending:@"postedAt"];
    [userExercises findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userExercises, NSError * _Nullable error) {
        if (!error) {
            self.userExercises = userExercises;
            
            for (int i = 0; i < self.availableExercises.count; i++) {
                NSMutableArray *weightsOfExercise = [[NSMutableArray alloc] init];
                Exercise *exercise = [[Exercise alloc] init];
                for (int j = 0; j < self.userExercises.count; j++){
                    exercise = [self.userExercises objectAtIndex:j];
                    
                    if (exercise.name == self.availableExercises[i]) {
                        [weightsOfExercise addObject: [NSNumber numberWithFloat:exercise.weight]];
                    }
                }
                [self.weightsOfExercises addObject:weightsOfExercise];
            }
            
            [self.tableView reloadData];
            }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self.refreshControl endRefreshing];

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chart Cell" forIndexPath:indexPath];
    
    [self basicLineChart:cell.cellView ofExercise:self.availableExercises[indexPath.row] withData:self.weightsOfExercises[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.weightsOfExercises.count;
}

#pragma mark - Charts

-(void)irregularIntervalsChart:(UIView *) cellView {
    HIChartView *chartView = [[HIChartView alloc] initWithFrame:cellView.bounds];
    
    chartView.plugins = @[ @"series-label" ];
    
    HIOptions *options = [[HIOptions alloc]init];
    
    HIChart *chart = [[HIChart alloc]init];
    chart.type = @"spline";
    
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Body weight change over time";
    
    HISubtitle *subtitle = [[HISubtitle alloc]init];
    subtitle.text = @"Gym journey";
    
    HIXAxis *xaxis = [[HIXAxis alloc]init];
    xaxis.type = @"datetime";
    xaxis.dateTimeLabelFormats = [[HIDateTimeLabelFormats alloc] init];
    
    xaxis.dateTimeLabelFormats.month = [[HIMonth alloc] init];
    xaxis.dateTimeLabelFormats.month.main = @"%e. %b";
    xaxis.dateTimeLabelFormats.year = [[HIYear alloc] init];
    xaxis.dateTimeLabelFormats.year.main = @"%b";
    xaxis.title = [[HITitle alloc]init];
    xaxis.title.text = @"Date";
    
    
    HIYAxis *yaxis = [[HIYAxis alloc]init];
    yaxis.title = [[HITitle alloc]init];
    yaxis.title.text = @"Weight";
    yaxis.min = @0;
    
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.headerFormat = @"<b>{series.name}</b><br>";
    tooltip.pointFormat = @"{point.x:%e. %b}: {point.y:.2f}";
    
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc]init];
    plotoptions.spline = [[HISpline alloc]init];
    plotoptions.spline.marker = [[HIMarker alloc]init];
    plotoptions.spline.marker.enabled = [[NSNumber alloc] initWithBool:true];
    
    NSMutableArray *arrayOfPoints = [[NSMutableArray alloc] init];
    for (int i=0; i<self.weights.count; i++) {
        //        NSMutableArray *point = [[NSMutableArray alloc] init];
        NSInteger unixtime = [[NSNumber numberWithDouble: [[self.dates objectAtIndex:i] timeIntervalSince1970]] integerValue];
        
        
        NSNumber *unixtimeObject = [NSNumber numberWithInteger:unixtime];
        
        //Miliseconds since 1970
        long unixtimeMiliseconds =[unixtimeObject integerValue] * 1000;
        
        NSNumber *unixtimeMilisecondsObject = [NSNumber numberWithInteger:unixtimeMiliseconds];
        
        NSMutableArray * point = [[NSMutableArray alloc] init];
        
        [point addObject:unixtimeMilisecondsObject];
        [point addObject:[self.weights objectAtIndex:i]];
        
        [arrayOfPoints addObject:point];
        NSLog(@"%@", arrayOfPoints);
    }
    
    
    HISpline *spline1 = [[HISpline alloc]init];
    spline1.name = @"Bodyweight";
    spline1.data = arrayOfPoints;
    
    NSLog(@"%@", spline1);
    
    options.chart = chart;
    options.title = title;
    options.subtitle = subtitle;
    options.xAxis = [NSMutableArray arrayWithObjects:xaxis, nil];
    options.yAxis = [NSMutableArray arrayWithObjects:yaxis, nil];
    options.tooltip = tooltip;
    options.plotOptions = plotoptions;
    options.series = [NSMutableArray arrayWithObjects:spline1, nil];
    
    chartView.options = options;
    
    [cellView addSubview:chartView];
    
}

- (void)basicLineChart:(UIView *) cellView ofExercise:(NSString *)nameOfExercise withData:(NSMutableArray *)weights{
    HIChartView *chartView = [[HIChartView alloc] initWithFrame:cellView.bounds];
    chartView.theme = @"brand-light";
    
    HIOptions *options = [[HIOptions alloc]init];
    
    HITitle *title = [[HITitle alloc]init];
    title.text = nameOfExercise;
    
    HISubtitle *subtitle = [[HISubtitle alloc]init];
    subtitle.text = @"Weight progression";
    
    HIYAxis *yaxis = [[HIYAxis alloc]init];
    yaxis.title = [[HITitle alloc]init];
    yaxis.title.text = @"Weight";
    
    HILegend *legend = [[HILegend alloc]init];
    legend.layout = @"vertical";
    legend.align = @"right";
    legend.verticalAlign = @"middle";
    
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc] init];
    plotoptions.series = [[HISeries alloc] init];
    plotoptions.series.label = [[HILabel alloc] init];
    plotoptions.series.label.connectorAllowed = [[NSNumber alloc] initWithBool:false];
    plotoptions.series.pointStart = @1;
    
    HILine *line1 = [[HILine alloc]init];
    line1.name = @"Weight lifted";
    line1.data = weights;
    NSLog(@"%@", line1.data);
    
    HILine *line2 = [[HILine alloc]init];
    line2.name = @"Manufacturing";
    line2.data = [NSMutableArray arrayWithObjects:@0, @0.2, @0.43, @0.62,  nil];
    
    
    HIResponsive *responsive = [[HIResponsive alloc] init];
    
    HIRules *rules1 = [[HIRules alloc] init];
    rules1.condition = [[HICondition alloc] init];
    rules1.condition.maxWidth = @500;
    rules1.chartOptions = @{
        @"legend" : @{
            @"layout": @"horizontal",
            @"align": @"center",
            @"verticalAlign": @"bottom"
        }
        
    };
    
    responsive.rules = [NSMutableArray arrayWithObjects:rules1, nil];

    options.title = title;
    options.subtitle = subtitle;
    options.yAxis = [NSMutableArray arrayWithObject:yaxis];
    options.legend = legend;
    options.plotOptions = plotoptions;
    options.series = [NSMutableArray arrayWithObjects:line1, line2, nil];
    options.responsive = responsive;
    
    chartView.options = options;
    
    [cellView addSubview:chartView];
}


@end


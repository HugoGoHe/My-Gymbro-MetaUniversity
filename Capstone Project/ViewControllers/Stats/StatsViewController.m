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
#import "math.h"

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
@property (strong, nonatomic) NSMutableArray *userExercises;
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
    self.userExercises = [[NSMutableArray alloc] init];
    self.weightsOfExercises =[[NSMutableArray alloc] init];
    
    [self getAvailableExercises];
    
    [self getData];

}

-(void)getAvailableExercises{
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
            self.weights = [progressPics valueForKey:@"weight"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            for (int i = 0; i < self.dates.count; i++) {
                [self.formatedDates addObject:[dateFormatter stringFromDate:self.dates[i]]];
            }
       //     NSLog(@"%@", self.formatedDates);
//            [self irregularIntervalsChart:self.WeightChartView];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}



-(void)getData{

    
    //Weight lifted in different exercises
    
    //Getting array of available exercises
    PFQuery *availableExercisesQuery = [PFQuery queryWithClassName:@"AvailableExercise"];
    [availableExercisesQuery findObjectsInBackgroundWithBlock:^(NSArray *availableExercises, NSError *error) {
        if (!error) {
            self.availableExercises = [availableExercises valueForKey:@"name"];
            
            PFQuery *userExercises = [Exercise query];
            [userExercises whereKey:@"username" equalTo:[PFUser currentUser]];
            [userExercises orderByAscending:@"postedAt"];
            [userExercises findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userExercises, NSError * _Nullable error) {
                if (!error) {
                    [self.userExercises removeAllObjects];
                    [self.weightsOfExercises removeAllObjects];
                    self.userExercises = [userExercises mutableCopy];
                    
                    for (int i = 0; i < self.availableExercises.count; i++) {
                  //      NSLog(@"%@", self.availableExercises[i]);
                        NSMutableArray *weightsOfExercise = [[NSMutableArray alloc] init];
                        Exercise *exercise = [[Exercise alloc] init];
                        for (int j = 0; j < self.userExercises.count; j++){
                            exercise = [self.userExercises objectAtIndex:j];
                            
                            if ([exercise.name isEqualToString: self.availableExercises[i]]) {
                                [weightsOfExercise addObject: [NSNumber numberWithFloat:exercise.weight]];
                            }
                        }
                        [self.weightsOfExercises addObject:weightsOfExercise];
                        NSLog(@"weights for %@: %@", exercise.name, self.weightsOfExercises);
                    }
                    
             //       NSLog(@"%@", self.weightsOfExercises);
                    

                    [self.tableView reloadData];
                    [self irregularIntervalsChart:self.WeightChartView];
                    [self.refreshControl endRefreshing];

                    }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
     //   NSLog(@"%@", self.availableExercises);
    }];
    

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chart Cell" forIndexPath:indexPath];
    
    [self basicLineChart:cell.cellView ofExercise:self.availableExercises[indexPath.row] withData:self.weightsOfExercises[indexPath.row]];
    NSLog(@"%@", self.availableExercises[indexPath.row] );
    NSLog(@"%@", self.weightsOfExercises[indexPath.row] );

    
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
    //   NSLog(@"%@", arrayOfPoints);
    }
    
    
    HISpline *spline1 = [[HISpline alloc]init];
    spline1.name = @"Bodyweight";
    spline1.data = arrayOfPoints;
    
    
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
    
    HILine *line2 = [[HILine alloc]init];
    line2.name = @"Trendline";
    line2.data = [self logarithmicRegression:weights];
 //   line2.data = [NSMutableArray arrayWithObjects:@0, @0.2, @0.43, @0.62,  nil];
    
    
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


-(NSMutableArray *)logarithmicRegression:(NSMutableArray *)Y{
    // Y = A + BlnX
    // Y = A + BX'
    NSMutableArray *X = [[NSMutableArray alloc] init];
    
    for(int i = 0; i<Y.count; i++){
        [X addObject:[NSNumber numberWithInt:i + 1]];
    }
    
    double SumatoryX = 0;
    double SumatoryPrimeX = 0;
    double SumatoryPrimeXsquared = 0;
    double SumatoryY = 0;
    double SumatoryPrimeXTimesY = 0;

    for(int i=0; i < X.count; i++) {
        
        SumatoryX = [X[i] doubleValue];
        SumatoryPrimeX += log([X[i] doubleValue]);
        SumatoryPrimeXsquared +=pow(log([X[i] doubleValue]), 2);
        SumatoryY += [Y[i] doubleValue];
        SumatoryPrimeXTimesY += log([X[i] doubleValue]) * [Y[i] doubleValue];
        
    }
    
    int n = (int) X.count;
    double B =(n * SumatoryPrimeXTimesY - SumatoryPrimeX * SumatoryY)/(n * SumatoryPrimeXsquared - pow(SumatoryPrimeX,2));
    
    // A = Yprom - B * XPrimeprom
    
    double A = (SumatoryY/n) - B * (SumatoryPrimeX /n);
    double prediction = 0;
    
    NSMutableArray *logarithmicTrendline = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < (X.count + 3); i++){
        
//        prediction = A + B * log([X[i] doubleValue]);
        prediction = A + B * log(i + 1);

        [logarithmicTrendline addObject:[NSNumber numberWithDouble:prediction]];
    }

    return logarithmicTrendline;
}
@end


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
@property (strong, nonatomic) NSMutableArray *namesOfUserExercises;


@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(obtainData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //Bodyweight change over time
    self.dates = [[NSMutableArray alloc] init];
    self.weights = [[NSMutableArray alloc] init];
    self.formatedDates = [[NSMutableArray alloc] init];

    //Weight lifted in exercises
    self.userExercises = [[NSMutableArray alloc] init];
    self.weightsOfExercises =[[NSMutableArray alloc] init];
    self.namesOfUserExercises = [[NSMutableArray alloc] init];
    
    //Fetching available exercises
    [self obtainProgressPics];
    
    //Fetching data and creating charts
    [self obtainData];
}

-(void)obtainProgressPics{
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
        }else{
            [self showErrorMessage];
            
        }
    }];
}

-(void)obtainData{
    //Weight lifted in different exercises

    //Getting array of available exercises
    PFQuery *availableExercisesQuery = [PFQuery queryWithClassName:@"AvailableExercise"];
    [availableExercisesQuery findObjectsInBackgroundWithBlock:^(NSArray *availableExercises, NSError *error) {
        if (!error) {
            self.availableExercises = [availableExercises valueForKey:@"name"];
            //Getting the user's exercises
            PFQuery *userExercises = [Exercise query];
            [userExercises whereKey:@"username" equalTo:[PFUser currentUser]];
            [userExercises orderByAscending:@"postedAt"];
            [userExercises findObjectsInBackgroundWithBlock:^(NSArray * _Nullable userExercises, NSError * _Nullable error) {
                if (!error ) {
                    [self.userExercises removeAllObjects];
                    [self.weightsOfExercises removeAllObjects];
                    self.userExercises = [userExercises mutableCopy];
                    
                    //Getting an array of arrays with the weights lifted for every exercise
                    for (int i = 0; i < self.availableExercises.count; i++) {
                        NSMutableArray *weightsOfExercise = [[NSMutableArray alloc] init];
                        Exercise *exercise = [[Exercise alloc] init];
                        for (int j = 0; j < self.userExercises.count; j++){
                            exercise = [self.userExercises objectAtIndex:j];
                            if ([exercise.name isEqualToString: self.availableExercises[i]]) {
                                if (!([self.namesOfUserExercises containsObject:exercise.name])){
                                    [self.namesOfUserExercises addObject:exercise.name];
                                }
                                [weightsOfExercise addObject: [NSNumber numberWithFloat:exercise.weight]];
                            }
                        }
                        if (weightsOfExercise.count > 0){
                            [self.weightsOfExercises addObject:weightsOfExercise];
                        }
                    }
                    //Loading the data
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                    }
                else{
                    [self showErrorMessage];
                    
                }
            }];
            }
        else{
            [self showErrorMessage];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
            self.view.window.rootViewController = tabBarController;
            //So it goes to the second item of the tab bar first
            [tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex:1]];
        }
    }];
}

-(void)showErrorMessage{
    // Log details of the failure
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Charts"
                                                                   message:@"The internet connection appears to be offline."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
        self.view.window.rootViewController = tabBarController;
        //So it goes to the second item of the tab bar first
        [tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex:1]];
    }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chart Cell" forIndexPath:indexPath];
    if(indexPath.section == 0){
        [self irregularIntervalsChart:cell.cellView];
    }else if( self.userExercises.count > 0){
        [self basicLineChart:cell.cellView ofExercise:self.namesOfUserExercises[indexPath.section - 1] withData:self.weightsOfExercises[indexPath.section - 1]];
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    long sections = 0;
    
    if(self.weights.count > 0){
        sections ++;
    }
    if(self.weightsOfExercises.count > 0){
        sections = sections + self.weightsOfExercises.count;
    }
    return sections;
    
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
    //For a more significant data visualization, y axis starts in the last value minus 10
    double range =  [[self.weights objectAtIndex:(self.weights.count - 1)]doubleValue] - 10;
    yaxis.min = [NSNumber numberWithDouble:range];

    
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.headerFormat = @"<b>{series.name}</b><br>";
    tooltip.pointFormat = @"{point.x:%e. %b}: {point.y:.2f}";
    
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc]init];
    plotoptions.spline = [[HISpline alloc]init];
    plotoptions.spline.marker = [[HIMarker alloc]init];
    plotoptions.spline.marker.enabled = [[NSNumber alloc] initWithBool:true];
    
    NSMutableArray *arrayOfPoints = [[NSMutableArray alloc] init];
    for (int i=0; i<self.weights.count; i++) {
        NSInteger unixtime = [[NSNumber numberWithDouble: [[self.dates objectAtIndex:i] timeIntervalSince1970]] integerValue];
        
        
        NSNumber *unixtimeObject = [NSNumber numberWithInteger:unixtime];
        
        //Miliseconds since 1970
        long unixtimeMiliseconds =[unixtimeObject integerValue] * 1000;
        
        NSNumber *unixtimeMilisecondsObject = [NSNumber numberWithInteger:unixtimeMiliseconds];
        
        NSArray * point = [NSArray arrayWithObjects:unixtimeMilisecondsObject, [self.weights objectAtIndex:i], nil];
        
        [arrayOfPoints addObject:point];
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

#pragma mark - Logarithmic Regression

-(NSMutableArray *)logarithmicRegression:(NSMutableArray *)Y{
    if (Y.count <2) {
        return nil;
    }
   /*
    For logarithmic regression we have the following model:
    
                                      Y = A + BlnX

    Since it is not a linear model, we have to linearize it, so we make a change of variable
    
                                           lnX = X', then:
    
                                        Y = A + BX' -> (1)
    
    Now we have a linear model and by the method of Least squares we can estimate the parameters A and B, where:
    
    
                                         n(Σ X'Y) - (Σ X')(Σ Y)
                                    B = ------------------------   -> (2)
                                          n(Σ X'²) - (Σ X')²

                                                &
    
                                           _       _
                                       A = Y - B * X'  -> (3)
    
    
    Where:
                                            _
                                            Y: Y average,
                                            _
                                            X': X' average

    */
    
    int n = (int) Y.count;
    double SumatoryX = 0;              //Σ X
    double SumatoryPrimeX = 0;         //Σ X'
    double SumatoryPrimeXsquared = 0;  //Σ X'²
    double SumatoryY = 0;              //Σ Y
    double SumatoryPrimeXTimesY = 0;   //Σ X'Y

    // X =[1,2,3,4,.....,n]
    // so we can use i from 1 to n+1
    
    for(int i=1; i < n+1; i++) {
        SumatoryX += i;
        SumatoryPrimeX += log(i);
        SumatoryPrimeXsquared += pow(log(i), 2);
        SumatoryY += [Y[i-1] doubleValue];
        SumatoryPrimeXTimesY += log(i) * [Y[i-1] doubleValue];
    }
    
    // We substitute the values in (2)
    
    double B =(n * SumatoryPrimeXTimesY - SumatoryPrimeX * SumatoryY)/(n * SumatoryPrimeXsquared - pow(SumatoryPrimeX,2));
    
    // We substitute the values in (3)
    
    double A = (SumatoryY/n) - B * (SumatoryPrimeX /n);
    double prediction = 0;
    
    NSMutableArray *logarithmicTrendline = [[NSMutableArray alloc] init];
    
    for(int i = 1; i < ((n+1) + n/4); i++){
        
        // We substitute the values in (1)
        prediction = A + B * log(i);
        [logarithmicTrendline addObject:[NSNumber numberWithDouble:prediction]];
    }

    return logarithmicTrendline;
}
@end


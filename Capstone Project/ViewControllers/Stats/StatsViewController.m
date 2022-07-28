//
//  StatsViewController.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/25/22.
//

#import "StatsViewController.h"
#import "ChartCell.h"
#import "Highcharts/Highcharts.h"


@interface StatsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *WeightChartView;

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 300;

    [self createChart:self.WeightChartView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chart Cell" forIndexPath:indexPath];
    
    [self createChart: cell.cellView];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)createChart:(UIView *) cellView{
    HIChartView *chartView = [[HIChartView alloc] initWithFrame:cellView.bounds];
    chartView.theme = @"brand-light";
    
    HIOptions *options = [[HIOptions alloc]init];
    
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Weight";
    
//    HISubtitle *subtitle = [[HISubtitle alloc]init];
//    subtitle.text = @"some subtitle";
    
    HIYAxis *yaxis = [[HIYAxis alloc]init];
    yaxis.title = [[HITitle alloc]init];
    yaxis.title.text = @"Weight";
    
    HILegend *legend = [[HILegend alloc]init];
//    legend.layout = @"vertical";
//    legend.align = @"right";
//    legend.verticalAlign = @"middle";
    
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc] init];
    plotoptions.series = [[HISeries alloc] init];
    plotoptions.series.label = [[HILabel alloc] init];
    plotoptions.series.label.connectorAllowed = [[NSNumber alloc] initWithBool:false];
    plotoptions.series.pointStart = @0;
    
    HILine *line1 = [[HILine alloc]init];
    line1.name = @"Body weight";
    line1.data = [NSMutableArray arrayWithObjects:@0, @0.3, @0.47, @0.603, @0.7, @0.77, nil];
    
    HILine *line2 = [[HILine alloc]init];
    line2.name = @"Manufacturing";
    line2.data = [NSMutableArray arrayWithObjects:@0, @0.2, @0.43, @0.62,  nil];
//
//    HILine *line3 = [[HILine alloc]init];
//    line3.name = @"Sales & Distribution";
//    line3.data = [NSMutableArray arrayWithObjects:@11744, @17722, @16005, @19771, @20185, @24377, @32147, @39387, nil];
//
//    HILine *line4 = [[HILine alloc]init];
//    line4.name = @"Project Development";
//    line4.data = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], @7988, @12169, @15112, @22452, @34400, @34227, nil];
//
//    HILine *line5 = [[HILine alloc]init];
//    line5.name = @"Other";
//    line5.data = [NSMutableArray arrayWithObjects:@12908, @5948, @8105, @11248, @8989, @11816, @18274, @18111, nil];
    
    
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
//    options.subtitle = subtitle;
    options.yAxis = [NSMutableArray arrayWithObject:yaxis];
    options.legend = legend;
    options.plotOptions = plotoptions;
    options.series = [NSMutableArray arrayWithObjects:line1, line2, nil];
    options.responsive = responsive;
    
    
    
    chartView.options = options;

    
    
    
    [cellView addSubview:chartView];
}

@end

//
//  YAWASevenDayViewController.m
//  YAWA
//
//  Created by jl on 6/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "YAWASevenDayViewController.h"
#import "YAWAWeatherStore.h"
#import "YAWADayForecastItem.h"
#import "MBProgressHUD.h"

@interface YAWASevenDayViewController () <UIAlertViewDelegate, UITextFieldDelegate> {
    NSArray *cellArray;
    YAWAWeatherStore *itemStore;
    UIAlertView *changeCityAlertView;
}

@end

@implementation YAWASevenDayViewController

#pragma mark - NSNotification methods

- (void)didFetchSevenDayData
{
    NSLog(@"Did receive notification that data fetch happened");
    
    // Init cellArray
    cellArray = [NSArray arrayWithArray:[itemStore sevenDayResults]];
    NSLog(@"Cell array count: %lu", (unsigned long)cellArray.count);
    
    // Reload table with new data
    [self.tableView reloadData];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)errorWhileFetching
{
    NSLog(@"There was an error while fetching data");
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Alert user that an error occured
    UIAlertView *dataFetchErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"An error occured while fetching forecast data"
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil, nil];
    [dataFetchErrorAlert show];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for notifications
    // Set up NSNotification receiving
    NSString *notificationName = @"YAWADidFetchSevenDayData";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchSevenDayData)
                                                 name:notificationName
                                               object:nil];
    
    // Error notification
    NSString *notificationErrorName = @"YAWAErrorWhileFetching";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorWhileFetching)
                                                 name:notificationErrorName
                                               object:nil];
    
    // Init pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshPullView:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    // Init and show progress HUD
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.labelText = @"";
    
    // Init itemStore
    itemStore = [[YAWAWeatherStore alloc] init];
    
    // If there is data in cache then fetch data for that city,
    // else fetch data for Newcastle AU as a default city
    if ([itemStore isThereForecastDataInCache]) {
        [itemStore fetchSevenDayForecastDataForCity:[itemStore returnNameOfCityLastFetched]];
    } else {
        [itemStore fetchSevenDayForecastDataForCity:@"Newcastle"];
    }
}

#pragma mark - Pull to refresh method

- (void)refreshPullView:(id)sender
{
    NSLog(@"Refreshing view ..");
    
    // DEBUGGING: forcing cache to empty
    //NSString *lastCityName = [itemStore returnNameOfCityLastFetched];
    //[itemStore flushForecastCache];
    
    // Check if data in cache is older than 10mins and show progress accordingly
    if ([itemStore isThereForecastDataInCache]) {
        [itemStore fetchSevenDayForecastDataForCity:[itemStore returnNameOfCityLastFetched]];
    } else {
        // Show progress
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [itemStore fetchSevenDayForecastDataForCity:[itemStore returnNameOfCityLastFetched]];
    }
    
    // End refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayCell" forIndexPath:indexPath];
    YAWADayForecastItem *cellItem = [cellArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    // Set background colour of cell to 'Quill Gray'
    cell.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.77 alpha:1];
    
    // Init labels
    UILabel *dayNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *descLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *minLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *maxLabel = (UILabel *)[cell viewWithTag:104];
    UIImageView *weatherImageLabel = (UIImageView *)[cell viewWithTag:105];
    
    // Set text of labels to weather results
    dayNameLabel.text = cellItem.dayOfWeek;
    descLabel.text = [cellItem.longDescString capitalizedString];
    // TODO: allow for celsius and fahrenheit
    minLabel.text = [NSString stringWithFormat:@"Min: %@%@C", cellItem.minString, @"\u00B0"];
    maxLabel.text = [NSString stringWithFormat:@"Max: %@%@C", cellItem.maxString, @"\u00B0"];
    
    // Weather icon image
    weatherImageLabel.image = [UIImage imageNamed:cellItem.iconToUse];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect frame = tableView.frame;
    
    UILabel *lastUpdated = [[UILabel alloc] initWithFrame:CGRectMake(10, -2, 120, 25)];
    UIFont *footerFont = [UIFont fontWithName:@"HelveticaNeue-Condensed" size:12];
    lastUpdated.font = footerFont;
    lastUpdated.text = [NSString stringWithFormat:@"Last updated: %@", [itemStore returnLastForecastFetchTimeAsString]];
    lastUpdated.textColor = [UIColor darkGrayColor];
    // Make sure text fits in label
    lastUpdated.adjustsFontSizeToFitWidth = YES;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [footerView addSubview:lastUpdated];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.frame;
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(frame.size.width-95, 10, 100, 30)];
    UIFont *buttonFont = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [addButton setTitle:@"Change City" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    // TODO: fix this when button is tapped
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    addButton.titleLabel.font = buttonFont;
    [addButton addTarget:self action:@selector(changeCityButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 30)];
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
    title.font = titleFont;
    title.text = [itemStore returnNameOfCityLastFetched];
    title.textColor = [UIColor darkGrayColor];
    // Make sure text fits in label
    title.adjustsFontSizeToFitWidth = YES;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView addSubview:title];
    [headerView addSubview:addButton];
    
    return headerView;
}

#pragma mark - Change City button was tapped

- (void)changeCityButtonWasTapped
{
    NSLog(@"Change city button was tapped");
    
     changeCityAlertView = [[UIAlertView alloc] initWithTitle:@"Change City"
                                                                  message:@"Type the city or suburb you wish to get the forecast for"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Search", nil];
    
    [changeCityAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    // Set delegate of alertView's textfield so that return key will dismiss alert
    [[changeCityAlertView textFieldAtIndex:0] setDelegate:self];
    
    [changeCityAlertView show];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Button index pressed: %d", buttonIndex);
    
    // Search button is buttonIndex 1
    //NSLog(@"alertView text field length: %d", [[alertView textFieldAtIndex:0].text length]);
    
    // If Search button and alertView text field has text ..
    if (buttonIndex == 1 && [[alertView textFieldAtIndex:0].text length] > 0) {
        NSLog(@"City to search for: %@", [alertView textFieldAtIndex:0].text);
        
        // Show progress
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Fetch data for the given search term
        NSString *citySearchTerm = [alertView textFieldAtIndex:0].text;
        [itemStore fetchSevenDayForecastDataForCity:citySearchTerm];
    }
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Allow the return key in alertView to dismiss alert
    [changeCityAlertView dismissWithClickedButtonIndex:changeCityAlertView.firstOtherButtonIndex animated:YES];
    
    return YES;
}

@end

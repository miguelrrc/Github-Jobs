//
//  PCSTableViewController.m
//  Github Jobs
//
//  Created by Miguel Rodriguez Rubio on 23/1/15.
//  Copyright (c) 2015 EPCTracker. All rights reserved.
//

#import "PCSTableViewController.h"
#import <SVProgressHUD.h>

@interface PCSTableViewController ()
@property (nonatomic,strong) NSArray *jobs;
@end

@implementation PCSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *endpoint = [[NSBundle bundleForClass: [self class]] infoDictionary]
    [@"GithubJobsEndpoint"];
    NSURL *url = [NSURL URLWithString: [endpoint stringByAppendingString:
                                        @"?description=ios&location=NY"]];
   // NSURL *url = [NSURL URLWithString:
    //              @"https://jobs.github.com/positions.json?description=ios&location=NY"];
    [SVProgressHUD showWithStatus: @"Fetching jobs..."];
    NSURLSessionDataTask *jobTask = [[NSURLSession sharedSession] dataTaskWithURL:
                                     url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (error) {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An error occured"
                                                                                                 message: error.localizedDescription
                                                                                                delegate: nil
                                                                                       cancelButtonTitle: @"Dismiss"
                                                                                       otherButtonTitles: nil];
                                                 [alert show];
                                                 return;//Back
                                             };
                                             NSError *jsonError = nil;
                                             self.jobs = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &jsonError];
                                             [self.tableView reloadData];
                                         });
                                         [SVProgressHUD showSuccessWithStatus: [NSString stringWithFormat: @"%lu jobs fetched",
                                                                                (unsigned long)[self.jobs count]]];
                                     }];
    [jobTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.jobs[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *jobUrl = [NSURL URLWithString: self.jobs[indexPath.row][@"url"]];
    [[UIApplication sharedApplication] openURL: jobUrl];
}

@end

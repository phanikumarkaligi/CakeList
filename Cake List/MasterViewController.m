//
//  MasterViewController.m
//  Cake List
//
//  Created by Stewart Hart on 19/05/2015.
//  Copyright (c) 2015 Stewart Hart. All rights reserved.
//

#import "MasterViewController.h"
#import "CakeCell.h"

@interface MasterViewController ()
@property (strong, nonatomic) NSArray *objects;
@end

@implementation MasterViewController
@synthesize refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CakeCell *cell = (CakeCell*)[tableView dequeueReusableCellWithIdentifier:@"CakeCell" forIndexPath:indexPath];
    NSDictionary *object = self.objects[indexPath.row];
    cell.titleLabel.text = object[@"title"];
    cell.descriptionLabel.text = object[@"desc"];
    
    //cell.cakeImageView = assign a default image

    
    // Make a async call to fetch the image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *aURL = [NSURL URLWithString:object[@"image"]];
        NSData *data = [NSData dataWithContentsOfURL:aURL];
        UIImage *image = [UIImage imageWithData:data];
       // show the image in the main thread
        if(image) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //This is run on the main thread
                CakeCell *updatedCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                [updatedCell.cakeImageView setImage:image];
            });
        }
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getData{
    
NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/hart88/198f29ec5114a3ec3460/raw/8dd19a88f9b8d24c23d9960f3300d0c917a4f07c/cake.json"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@",error.localizedFailureReason);
            [refreshControl endRefreshing];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network Error" message:error.localizedFailureReason preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            NSError *jsonError;
            id responseData = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&jsonError];
            NSLog(@"response data = %@",responseData);
            self.objects = responseData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }
    }];
    [task resume];
}


- (void)refreshTable {
    [self getData];
}

@end

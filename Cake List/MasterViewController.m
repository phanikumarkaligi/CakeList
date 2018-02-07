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
    CakeCell *cell = (CakeCell*)[tableView dequeueReusableCellWithIdentifier:@"CakeCell"];
    
    NSDictionary *object = self.objects[indexPath.row];
    cell.titleLabel.text = object[@"title"];
    cell.descriptionLabel.text = object[@"desc"];
 
    
//    NSURL *aURL = [NSURL URLWithString:object[@"image"]];
//    NSData *data = [NSData dataWithContentsOfURL:aURL];
//    UIImage *image = [UIImage imageWithData:data];
//    [cell.cakeImageView setImage:image];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Run your loop here
        NSURL *aURL = [NSURL URLWithString:object[@"image"]];
        NSData *data = [NSData dataWithContentsOfURL:aURL];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //stop your HUD here
            //This is run on the main thread
            UIImage *image = [UIImage imageWithData:data];
            [cell.cakeImageView setImage:image];
            
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getData{
    
//    NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/hart88/198f29ec5114a3ec3460/raw/8dd19a88f9b8d24c23d9960f3300d0c917a4f07c/cake.json"];
//    
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    
//    NSError *jsonError;
//    id responseData = [NSJSONSerialization
//                       JSONObjectWithData:data
//                       options:kNilOptions
//                       error:&jsonError];
//    if (!jsonError){
//        self.objects = responseData;
//        [self.tableView reloadData];
//    } else {
//    }
    
    
    NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/hart88/198f29ec5114a3ec3460/raw/8dd19a88f9b8d24c23d9960f3300d0c917a4f07c/cake.json"];
    
    //  NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:error.localizedFailureReason delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            [alert show];
        } else {
            NSError *jsonError;
            id responseData = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&jsonError];
            self.objects = responseData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [task resume];
}


- (void)refreshTable {
    //TODO: refresh your data
    [refreshControl endRefreshing];
    [self getData];
    [self.tableView reloadData];
}

@end

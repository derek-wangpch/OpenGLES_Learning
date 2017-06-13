//
//  MainViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 11/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "MainViewController.h"
#import "TriangleViewController.h"
#import "TeapotViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"1 - Triangle";
            break;
        case 1:
            cell.textLabel.text = @"2 - Teapot";
            break;
        case 2:
            cell.textLabel.text = @"3 - Triangle with Shader";
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            TriangleViewController *vc = [TriangleViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default: {
            TeapotViewController *vc = [TeapotViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

@end

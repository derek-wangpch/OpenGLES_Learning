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
#import "TriangleShaderViewController.h"
#import "CubeViewController.h"
#import "TriangleRenderViewController.h"

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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"1 - Triangle";
            break;
        case 1:
            cell.textLabel.text = @"2 - Triangle with Shader";
            break;
        case 2:
            cell.textLabel.text = @"3 - Teapot";
            break;
        case 3:
            cell.textLabel.text = @"4 - Cube with texture";
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
        case 1: {
            /*
            TriangleShaderViewController *vc = [TriangleShaderViewController new];
            [self.navigationController pushViewController:vc animated:YES];
             */
            TriangleRenderViewController *vc = [TriangleRenderViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: {
            TeapotViewController *vc = [TeapotViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3: {
            CubeViewController *vc = [CubeViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        default:
            break;
    }
}

@end

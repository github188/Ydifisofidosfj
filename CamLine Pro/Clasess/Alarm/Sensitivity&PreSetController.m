//
//  Sensitivity&PreSetController.m
//  temptest
//
//  Created by apple  on 16/1/4.
//  Copyright © 2016年 jayzhou. All rights reserved.
//

#import "Sensitivity&PreSetController.h"

@interface Sensitivity_PreSetController ()
@property (nonatomic ,assign) NSInteger returnValue;
@end

@implementation Sensitivity_PreSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

-(void)setUI
{
    // bbntItme
        //1.1left btn
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
        //1.2.rightbtn
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];
    

}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    if (self.type == SENSTIVITY_TYPE) {
        if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectSensitivityValue:)]) {
            [_delegate didSelectSensitivityValue: self.returnValue];
        }
    }else if (self.type == PRESET_TYPE){
        if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectPresetValue:)])
            [ _delegate didSelectPresetValue: self.returnValue];
        
    }

     [self.navigationController popViewControllerAnimated:YES];
}
- (NSArray *) items
{
    if (!_items) {
        _items = [[NSMutableArray array] autorelease];
    }
    return _items;
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
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tableFooterView = [[UIView alloc] init];
    NSUInteger row = [indexPath row];
    static NSString *TableIdentifier = @"TableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier]
                autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (row == self.selectRow) {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [self.items objectAtIndex:row];
    
    return cell;
}

#pragma mark - Table view delegate M
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSInteger row = [indexPath row];
    
    if (self.type == SENSTIVITY_TYPE) {
            switch (row) {
                case 0:
                    self.returnValue = 25;
                    break;
                case 1:
                     self.returnValue = 50;
                    break;
                case 2:
                     self.returnValue = 75;
                    break;
                case 3:
                     self.returnValue = 100;
                    break;
                default:
                    break;
            }
    }else if (self.type == PRESET_TYPE){
        self.returnValue = row;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];


}
-(void)dealloc
{
    [super  dealloc];
    self.delegate = nil;
    [self.items release];
}

@end

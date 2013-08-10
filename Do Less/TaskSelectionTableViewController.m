//
//  TaskTableViewController.m
//  Do Less
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskSelectionTableViewController.h"
#import "Utility.h"

@interface TaskSelectionTableViewController ()

@property (strong, nonatomic) Task *model;
@property (strong, nonatomic) UIImage *sectionHeaderBackground;
@property (strong, nonatomic) UIImage *tableBackground;
@property (strong, nonatomic) UIImage *cellSelectedBackground;

@end

@implementation TaskSelectionTableViewController

#pragma mark - Getter & Setter

- (Task *)model
{
    if (!_model) {
        _model = [[Task alloc] init];
    }
    return _model;
}

- (UIImage *)sectionHeaderBackground
{
    if (!_sectionHeaderBackground) {
        _sectionHeaderBackground = [[UIImage imageNamed:@"ListHeaderBg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    }

    return _sectionHeaderBackground;
}

- (UIImage *)tableBackground
{
    if (!_tableBackground) {
        _tableBackground = [[UIImage imageNamed:@"ListPageBg"]resizableImageWithCapInsets:UIEdgeInsetsZero];
    }
    return _tableBackground;
}

- (UIImage *)cellSelectedBackground
{
    if (!_cellSelectedBackground) {
        _cellSelectedBackground = [[UIImage imageNamed:@"ListHover"]resizableImageWithCapInsets:UIEdgeInsetsZero];
    }
    return _cellSelectedBackground;
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configNavBarBackgroundImage];

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:self.tableBackground];
}

- (void)configNavBarBackgroundImage
{
    NSMutableString *imageFileName = [@"SelectBannerBg" mutableCopy];

    [imageFileName appendFormat:@"-%02d", self.navBarColorIndex + 1];

    NSString *portraitFileName = [imageFileName stringByAppendingString:@"-portrait"];
    NSString *landscapeFileName = [imageFileName stringByAppendingString:@"-landscape"];

    if (IS_WIDESCREEN) {
        landscapeFileName = [landscapeFileName stringByAppendingString:@"-568h"];
    }

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:portraitFileName] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:landscapeFileName] forBarMetrics:UIBarMetricsLandscapePhone];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model.lists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EKCalendar *list = self.model.lists[section];
    NSArray *tasks = [self.model tasksInList:list];
    return [tasks count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EKCalendar *list = self.model.lists[section];
    NSArray *tasks = [self.model tasksInList:list];
    return [tasks count] == 0 ? nil : list.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Task" forIndexPath:indexPath];
    EKReminder *task = [self.model taskWithIndexPath:indexPath];

    cell.textLabel.text = task.title;

    // Dispaly task's due date if available
    if (task.dueDateComponents) {
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *dueDate = [gregorian dateFromComponents:task.dueDateComponents];

        cell.detailTextLabel.text = [dateFormatter stringFromDate:dueDate];
    } else {
        cell.detailTextLabel.text = @"";
    }

    // Show the checkmark if the task has been selected
    if ([self.todayTasks indexOfObject:task] == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:self.cellSelectedBackground];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EKReminder *task = [self.model taskWithIndexPath:indexPath];

        NSError *error;
        if ([self.model removeTask:task commit:YES error:&error]) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [Utility alert:[error localizedDescription]];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    EKCalendar *list = self.model.lists[indexPath.section];
    NSArray *tasks = [self.model tasksInList:list];
    self.selectedTask = tasks[indexPath.row];

    [self performSegueWithIdentifier:@"BackToTasksToday" sender:self];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *header = [[UIImageView alloc] initWithImage:self.sectionHeaderBackground];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, header.bounds.size.width, header.bounds.size.height)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    title.font = [UIFont boldSystemFontOfSize:20];

    [header addSubview:title];


    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    EKCalendar *list = self.model.lists[section];
    NSArray *tasks = [self.model tasksInList:list];
    return [tasks count] == 0 ? 0 : self.sectionHeaderBackground.size.height;
}

@end

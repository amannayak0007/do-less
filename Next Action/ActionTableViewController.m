//
//  ActionTableViewController.m
//  Next Action
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "ActionTableViewController.h"
#import "Action.h"
#import "CurrentReminderViewController.h"

@interface ActionTableViewController ()
@property (strong, nonatomic, readonly) Action *model;
@property (strong, nonatomic) NSArray *lists;
@end

@implementation ActionTableViewController

- (NSArray *)lists
{
    if (!_lists) {
        _lists = [self.model.eventStore calendarsForEntityType:EKEntityTypeReminder];
    }
    return _lists;
}

- (NSArray *)actionsInList:(EKCalendar *)list
{
    __block NSArray *actions;

    dispatch_semaphore_t mutex = dispatch_semaphore_create(0);

    NSPredicate *predicate = [self.model.eventStore predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                          ending:nil
                                                                                       calendars:@[list]];

    [self.model.eventStore fetchRemindersMatchingPredicate:predicate
                                          completion:^(NSArray *reminders) {
                                              actions = reminders;
                                              dispatch_semaphore_signal(mutex);
                                          }];

    dispatch_semaphore_wait(mutex, DISPATCH_TIME_FOREVER);
    
    return actions;
}

- (Action *)model
{
    return [Action sharedInstance];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.model.eventStore];
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.lists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EKCalendar *list = self.lists[section];
    NSArray *actions = [self actionsInList:list];
    return [actions count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EKCalendar *list = self.lists[section];
    return list.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKCalendar *list = self.lists[indexPath.section];
    NSArray *actions = [self actionsInList:list];
    EKReminder *action = actions[indexPath.row];

    static NSString *CellIdentifier = @"action";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = action.title;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKCalendar *list = self.lists[indexPath.section];
    NSArray *actions = [self actionsInList:list];
    self.model.currentAction = actions[indexPath.row];

    return indexPath;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end

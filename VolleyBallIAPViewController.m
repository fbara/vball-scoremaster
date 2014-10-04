//
//  VolleyBallIAPViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 9/22/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "VolleyBallIAPViewController.h"
#import "GAIDictionaryBuilder.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wprotocol"

@interface VolleyBallIAPViewController () {
    NSArray* _products;
    NSNumberFormatter* _priceFormatter;
    BOOL isPurchased;
}

@property (strong, nonatomic) UIBarButtonItem* restorePurchases;
@property (strong, nonatomic) UIBarButtonItem* saveButton;
@property (weak, nonatomic) IBOutlet UITableViewCell* purchaseSocialCell;

@end

@implementation VolleyBallIAPViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.title = @"In-App Purchase";


    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // Wire up the pull-to-refresh code
    [self.refreshControl addTarget:self
                            action:@selector(refreshView)
                  forControlEvents:UIControlEventValueChanged];

    //Setup bar button items
    self.restorePurchases =
        [[UIBarButtonItem alloc] initWithTitle:@"Restore"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(restoreTapped:)];

    self.navigationItem.rightBarButtonItem = self.restorePurchases;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"purchasedSocial"]) {
        //No purchase so get the products and disable the buttons
        [self getIAPList];
    } else {
        //Purchase already made
        self.purchaseSocialCell.detailTextLabel.text = @"Paid";
        self.purchaseSocialCell.textLabel.text = @"Social sharing purchase";
        self.purchaseSocialCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.purchaseSocialCell.accessoryView = nil;
        self.restorePurchases.enabled = FALSE;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	
    // Setup Google Analytics tracker for this screen
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"In-App Purchase"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    // Setup a notification observer for IAP
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(productPurchased:)
               name:IAPHelperProductPurchaseNotification
             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Remove our observer for IAP
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:IAPHelperProductPurchaseNotification
                object:nil];

    [super viewWillDisappear:animated];
}

- (void)formatIAPPrice
{
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

- (void)productPurchased:(NSNotification*)notification
{
    // This will be called after the user completes a purchase, so
    // remove the 'buy' button and replace with a checkmark and do anything else
    NSString* productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct* product, NSUInteger idx,
                                            BOOL* stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self refreshView];
            self.purchaseSocialCell.detailTextLabel.text = @"Paid";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Social Buttons"
                                                            message:@"Don't forget to tap 'Send' on the social sharing buttons on the Settings page."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            *stop = YES;
        }
    }];
}

- (void)refreshView
{

    [self.refreshControl beginRefreshing];

    [self getIAPList];

    [self.refreshControl endRefreshing];
	
}

- (void)restoreTapped:(UIButton*)sender
{

    
    [[VolleyBallIAPHelper sharedInstance] restoreCompletedTransactions];
    [self refreshView];
    self.purchaseSocialCell.detailTextLabel.text = @"Paid";
    
}

- (BOOL)getIAPList
{
    // Get list of available IAP's
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    [[VolleyBallIAPHelper sharedInstance]
        requestProductsWithCompletionHandler:^(BOOL success, NSArray* products) {
         if (success) {
             _products = products;
             SKProduct *product = (SKProduct *)_products[0];
             self.purchaseSocialCell.textLabel.text = product.localizedTitle;
             
             [self formatIAPPrice];
             
             [_priceFormatter setLocale:product.priceLocale];
             self.purchaseSocialCell.detailTextLabel.text =
             [_priceFormatter stringFromNumber:product.price];
             
             if ([[VolleyBallIAPHelper sharedInstance]
                  productPurchased:product.productIdentifier]) {
                 //Product purchased, set accessory checkmark on purchase row
                 self.purchaseSocialCell.accessoryType =
                 UITableViewCellAccessoryCheckmark;
                 self.purchaseSocialCell.accessoryView = nil;
                 
                 [defaults setBool:TRUE forKey:@"purchasedSocial"];
                 self.purchaseSocialCell.detailTextLabel.text = @"Paid";
                 self.restorePurchases.enabled = FALSE;
                 isPurchased = TRUE;
                 
             } else {
                 UIButton *buyButton =
                 [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 if (IS_IPAD()) {
                     buyButton.frame = CGRectMake(5, 0, 220, 29);
                 } else {
                     buyButton.frame = CGRectMake(5, 0, 210, 29);
                 }
                 [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
                 buyButton.backgroundColor = FlatYellow;
                 buyButton.layer.borderWidth = 0.25f;
                 buyButton.layer.borderColor = [[UIColor grayColor] CGColor];
                 buyButton.layer.masksToBounds = YES;
                 buyButton.layer.cornerRadius = 5;
                 buyButton.tag = 0;
                 [buyButton addTarget:self
                               action:@selector(buyButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
                 self.purchaseSocialCell.accessoryType =
                 UITableViewCellAccessoryNone;
                 self.purchaseSocialCell.accessoryView = buyButton;
                 [defaults setBool:FALSE forKey:@"purchasedSocial"];
                 self.restorePurchases.enabled = TRUE;
                 isPurchased = FALSE;
             }
         }
        }];
    return isPurchased;
}

- (void)buyButtonTapped:(UIButton*)sender
{
	
	UIButton* buyButton = sender;
    SKProduct* product = _products[buyButton.tag];
	
	// Log the button press for analytics
	[self logButtonPress:(UIButton*)sender];
	
    //Buy the IAP
    [[VolleyBallIAPHelper sharedInstance] buyProduct:product];
}

#pragma mark - Google Analytics

- (void)logButtonPress:(UIButton*)button
{
	// Logs button presses, gets the title text of the button, and sends it
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	[tracker set:kGAIScreenName value:@"In-App Purchase"];
	[tracker send:[[GAIDictionaryBuilder
					createEventWithCategory:@"IAP"
					action:@"buy"
					label:[button.titleLabel text]
					value:nil] build]];
	[tracker set:kGAIScreenName value:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma clang diagnostic pop

@end

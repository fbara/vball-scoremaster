//
//  IAPHelper.h
//  IAPExample
//
//  Created by Frank Bara on 5/14/14.
//  Copyright (c) 2014 BaraLabs. All rights reserved.
//

@import StoreKit;

UIKIT_EXTERN NSString *const IAPHelperProductPurchaseNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);
@interface IAPHelper : UIViewController

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end

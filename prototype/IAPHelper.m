#import <Foundation/Foundation.h>

@import StoreKit;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// An array of product identifier NSStrings. This is set when we're first constructed.
@property NSArray *productIdentifiers;

// A map from a product identifier NSString to the corresponding project.
@property NSMutableDictionary *products;

// 1 if the queue is initialized, 0 otherwise.
@property int initialized_queue;

// 1 if an operation is in progress. 0 if no operation is in progress.
@property int finished;

// The set of identifiers for purchased products.
@property NSMutableSet *purchased;

// The set of identifiers for deferred products.
@property NSMutableSet *deferred;

- (id) init;
- (void) initQueue;
- (BOOL) canMakePayments;
- (void) validateProductIdentifiers;
- (void) beginPurchase: (NSString *) identifier;
- (BOOL) hasPurchased: (NSString *) identifier;
- (BOOL) isDeferred: (NSString *) identifier;
- (NSString *) formatPrice: (NSString *) identifier;
@end;


@implementation IAPHelper

- (id) init {
    self = [ super init ];
    self.products = [ [ NSMutableDictionary alloc] init];
    self.purchased = [ [ NSMutableSet alloc ] init ];
    self.deferred = [ [ NSMutableSet alloc ] init ];
    self.finished = 1;
    self.initialized_queue = 0;
    
    return self;
}

- (void) initQueue {
    if (self.initialized_queue) {
        return;
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    self.initialized_queue = 1;
    
    return;
}

- (BOOL) canMakePayments {
    [self initQueue];
    return [SKPaymentQueue canMakePayments];
}

- (void) validateProductIdentifiers {
 
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray: self.productIdentifiers]];
    self.finished = 0;
    productsRequest.delegate = self;
    [productsRequest start];

}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *prod in response.products) {
        [ self.products setObject: prod forKey: prod.productIdentifier ];
    }
    self.finished = 1;
}


- (void) beginPurchase: (NSString *) identifier {
    [self initQueue];
    
    SKProduct *product = [ self.products objectForKey: identifier ];
    
    if (product == nil) {
        return;
    }

    self.finished = 0;
    
    SKMutablePayment *payment = [ SKMutablePayment paymentWithProduct: product ];
    payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
}

- (void) restorePurchases {
    [self initQueue];
    
    self.finished = 0;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions ];
    printf("Restore started.\n");
}

- (void) paymentQueue: (SKPaymentQueue *) queue updatedTransactions: (NSArray *) transactions {
    for (SKPaymentTransaction *t in transactions) {
        NSString *identifier = t.payment.productIdentifier;
        
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchased:
                printf("Purchased %s\n", [ identifier UTF8String ]);
                [ self.deferred removeObject: identifier ];
                [ self.purchased addObject: identifier ];
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                self.finished = 1;
                break;

            case SKPaymentTransactionStateFailed:
                printf("Failed %s\n", [ identifier UTF8String ]);
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                self.finished = 1;
                break;

            case SKPaymentTransactionStateRestored:
                printf("Restored %s\n", [ identifier UTF8String ]);
                [ self.deferred removeObject: identifier ];
                [ self.purchased addObject: identifier ];
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                break;
            
            case SKPaymentTransactionStatePurchasing:
                printf("Purchasing %s\n", [ identifier UTF8String ]);
                break;
                
            case SKPaymentTransactionStateDeferred:
                printf("Deferred %s\n", [ identifier UTF8String ]);
                [ self.deferred addObject: identifier ];
                self.finished = 1;
                break;
        }
    }
}

- (void) paymentQueue: (SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError: (NSError *) error {
    printf("Restore failed with error.\n");
    self.finished = 1;
}

- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue *) queue {
    printf("Restore completed.\n");
    self.finished = 1;
}


- (BOOL) hasPurchased: (NSString *) identifier {
    return [ self.purchased member: identifier ] != nil;
}

- (BOOL) isDeferred: (NSString *) identifier {
    return [ self.deferred member: identifier ] != nil;
}

- (NSString *) formatPrice: (NSString *) identifier {
    SKProduct *product = [ self.products objectForKey: identifier ];
    
    if (product == nil) {
        return nil;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:product.price];
}

@end
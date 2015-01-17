#import <Foundation/Foundation.h>

@import StoreKit;

@interface IAPHelper : NSObject <SKProductsRequestDelegate>

@property NSArray *productIdentifiers;
@property NSMutableDictionary *products;

- (id) init;
- (BOOL) canMakePayments;
- (void) validateProductIdentifiers;

@end;


@implementation IAPHelper

- (id) init {
    self = [ super init ];
    self.products = [[ NSMutableDictionary alloc] init];
    return self;
}

- (BOOL) canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (void)validateProductIdentifiers {
 
    for (NSString *i in self.productIdentifiers) {
        printf("%s\n", [i UTF8String]);
    }
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray: self.productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    for (SKProduct *prod in response.products) {
        // printf("OK %s %f\n", [ prod.productIdentifier UTF8String ], prod.price.doubleValue);

        [ self.products setObject: prod forKey: prod.productIdentifier ];
    }
    
//    for (NSString *s in response.invalidProductIdentifiers) {
//        printf("INVALID %s\n", [ s UTF8String ]);
//    }
}

@end
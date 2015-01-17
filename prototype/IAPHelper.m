#import <Foundation/Foundation.h>

@import StoreKit;

@interface IAPHelper : NSObject {
    
}

- (BOOL) canMakePayments;

@end;


@implementation IAPHelper

- (BOOL) canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

@end
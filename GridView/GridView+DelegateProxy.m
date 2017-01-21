//
//  GridView+DelegateProxy.m
//  GridView
//
//  Created by Kyohei Ito on 2017/01/20.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GridView/GridView-Swift.h>

@implementation GridView (DelegateProxy)

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget: self.originDelegate];
}

@end

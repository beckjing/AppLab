//
//  KVOViewController.m
//  KVODemo
//
//  Created by yuecheng on 2019/8/9.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

#import "KVOViewController.h"
#import "NASSwizzleUtility.h"
#import <ObjC/runtime.h>

@interface KVOViewController ()

@end

@implementation KVOViewController


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NASSwizzleUtility swizzleInstanceMethodOriginalClass:UIViewController.class originalSelector:@selector(init) newClass:KVOViewController.class newSelector:@selector(kvo_init)];
        [NASSwizzleUtility swizzleInstanceMethodOriginalClass:UIViewController.class originalSelector:@selector(initWithNibName:bundle:) newClass:KVOViewController.class newSelector:@selector(kvo_initWithNibName:bundle:)];
        [NASSwizzleUtility swizzleInstanceMethodOriginalClass:UIViewController.class originalSelector:@selector(initWithCoder:) newClass:KVOViewController.class newSelector:@selector(kvo_initWithCoder:)];
    });
}

- (instancetype)kvo_initWithCoder:(NSCoder *)aDecoder {
    return [self kvo_initWithCoder:aDecoder];
}

- (instancetype)kvo_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self kvo_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)kvo_init {
    return [self kvo_init];
}

- (void)addPairClass {
    NSString *originalClassName = NSStringFromClass([self class]);
    NSString *pairClassName = [NSString stringWithFormat:@"kvo_%@", originalClassName];
    
    Class newClass = objc_allocateClassPair([self class], pairClassName.UTF8String, 0);
    
    class_addMethod(newClass, @selector(viewDidLoad), (IMP)viewDidLoad, nil);
}



- (void)kvo_viewDidLoad {
    [self kvo_viewDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  NASDemoStudentModel.h
//  NanoSparrow
//
//  Created by yuecheng on 12/28/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NASDemoStudentModel : NSObject

@property (nonatomic, assign) NSInteger sId;
@property (nonatomic,   copy) NSString *sName;
@property (nonatomic, assign) NSInteger *sAge;
@property (nonatomic, strong) NSMutableArray *sClassArray;

@end

@interface NASDemoStudentClassModel : NSObject

@property (nonatomic, assign) NSInteger scId;
@property (nonatomic,   copy) NSString *cName;

@end

//
//  User.h
//  
//
//  Created by lixu on 16/9/2.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnswerQuestion, Courses, Exam, Grade;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"

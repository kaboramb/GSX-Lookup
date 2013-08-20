//
//  PythonHandler.h
//  GSX Lookup
//
//  Created by Burgin, Thomas (NIH/NIMH) [C] on 3/22/13.
//  Copyright (c) 2013 Burgin, Thomas (NIH/NIMH) [C]. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PythonHandler : NSObject

+ (void) runPythonGSXWithAppleID: (NSString *) appleID
                 appleIDPassword: (NSString *) appleIDPassword
                          soldTo: (NSString *) soldTo
                serialNumberPath: (NSString *) serialNumberPath
                      outputPath: (NSString *) outputPath
                          format: (NSString *) format
                      scriptPath: (NSString *) scriptPath;
@end

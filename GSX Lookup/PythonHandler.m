//
//  PythonHandler.m
//  GSX Lookup
//
//  Created by Burgin, Thomas (NIH/NIMH) [C] on 3/22/13.
//  Copyright (c) 2013 Burgin, Thomas (NIH/NIMH) [C]. All rights reserved.
//

#import "PythonHandler.h"

@implementation PythonHandler

+ (void) runPythonGSXWithAppleID: (NSString *) appleID
                 appleIDPassword: (NSString *) appleIDPassword
                          soldTo: (NSString *) soldTo
                serialNumberPath: (NSString *) serialNumberPath
                      outputPath: (NSString *) outputPath
                          format: (NSString *) format
                      scriptPath: (NSString *) scriptPath
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/python"];
    [task setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle]
                                                  pathForResource:@"gsxLookup" ofType:@"py"], @"-u", appleID, @"-p", appleIDPassword,  @"-t", soldTo, @"-f", format, @"-s", serialNumberPath, @"-w", outputPath, @"-x", scriptPath, nil]];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog(@"%@", string);
    NSString* cleanedString = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *delimiter = @"#";
    NSArray *array = [cleanedString componentsSeparatedByString:delimiter];
    NSLog(@"%@", array);

    
}

@end

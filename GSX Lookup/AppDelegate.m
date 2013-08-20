//
//  AppDelegate.m
//  GSX Lookup
//
//  Created by Burgin, Thomas (NIH/NIMH) [C] on 3/16/13.
//  Copyright (c) 2013 Burgin, Thomas (NIH/NIMH) [C]. All rights reserved.
//

#import "AppDelegate.h"
#include "PythonHandler.h"

@implementation AppDelegate
@synthesize serialPath,progressBar,soldToAccount,appleIDEmail,appleIDPassword,outputFormat;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [progressBar setHidden:YES];
}

- (IBAction)chooseSerialList:(id)sender {
    // Create the File Open Dialog.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    if ( [openDlg runModal] == NSOKButton )
    {
        NSArray *serailFiles = [openDlg filenames];
        STRserialNumberPath = [[NSString alloc] initWithFormat:@"%@", [serailFiles objectAtIndex:0]];
        [serialPath setStringValue:STRserialNumberPath];
    }

}

- (IBAction)saveRun:(id)sender {
    [self setGSXinfo];
    STRscriptPath = [[NSBundle mainBundle] pathForResource:@"gsxcl" ofType:@"sh"];
    STRscriptPath = [STRscriptPath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    //NSLog(@"%@", STRscriptPath);
    // Create the Save Open Dialog.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    if ( [openDlg runModal] == NSOKButton )
    {
        NSArray *serailFiles = [openDlg filenames];
        STRoutputPath = [[NSString alloc] initWithFormat:@"%@", [serailFiles objectAtIndex:0]];
        [PythonHandler runPythonGSXWithAppleID:STRappleID appleIDPassword:STRappleIDPassword soldTo:STRsoldToAccountNumber serialNumberPath:STRserialNumberPath outputPath:STRoutputPath format:STRformat scriptPath:STRscriptPath];
    }

}

- (void)setGSXinfo{
    STRsoldToAccountNumber = [soldToAccount stringValue];
    STRappleID = [appleIDEmail stringValue];
    STRappleIDPassword = [appleIDPassword stringValue];
    STRformat = [outputFormat stringValue];
}

@end
//
//  AppDelegate.h
//  GSX Lookup
//
//  Created by Burgin, Thomas (NIH/NIMH) [C] on 3/16/13.
//  Copyright (c) 2013 Burgin, Thomas (NIH/NIMH) [C]. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSString *STRsoldToAccountNumber;
    NSString *STRappleID;
    NSString *STRappleIDPassword;
    NSString *STRserialNumberPath;
    NSString *STRformat;
    NSString *STRoutputPath;
    NSString *STRscriptPath;
}

@property (weak) IBOutlet NSTextField *soldToAccount;
@property (weak) IBOutlet NSTextField *appleIDEmail;
@property (weak) IBOutlet NSSecureTextField *appleIDPassword;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSComboBox *outputFormat;
@property (weak) IBOutlet NSTextField *serialPath;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressText;

- (IBAction)chooseSerialList:(id)sender;
- (IBAction)saveRun:(id)sender;

@end

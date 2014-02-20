#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <SpringBoard/SBIconController.h>
#import <CommonCrypto/CommonDigest.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.homeschooldev.iconlock.plist"

@interface SBIconController ()
- (NSString *)md5:(NSString*)textString;
@end

%hook SBIconController

-(void)iconHandleLongPress:(id)press {
	if ([[objc_getClass("SBIconController") sharedInstance] isEditing]) return %orig;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"IconLock" 
				message:@"No password exists. Please create a new password." 
				delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
		av.alertViewStyle = UIAlertViewStyleSecureTextInput;
		[av show];
		[av release];
	}
	else
	{
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"IconLock" 
			message:@"Enter a password to move the icons" 
			delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		av.alertViewStyle = UIAlertViewStyleSecureTextInput;
		[av show];
		[av release];
	}
}

%new
- (void)alertView:(UIAlertView *)av clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
			//new password
			NSString *md5Text = [self md5:[[av textFieldAtIndex:0] text]];
			NSDictionary *passwordDict = [NSDictionary dictionaryWithObject:md5Text forKey:@"Password"];
			[passwordDict writeToFile:PLIST_PATH atomically:YES];
		}
		else 
		{
			NSDictionary *passwordDict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
			NSString *md5Text = [self md5:[[av textFieldAtIndex:0] text]];
		
			if ([md5Text isEqualToString:[passwordDict objectForKey:@"Password"]]) {
				[[objc_getClass("SBIconController") sharedInstance] setIsEditing:YES];
			}
			else {
				UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You entered an incorrect password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[error show];
				[error release];
	    	}
		}
	}	
}

%new
- (NSString *)md5:(NSString*)textString
{
	const char *cstr = [textString UTF8String];
	    unsigned char result[16];
	    CC_MD5(cstr, strlen(cstr), result);

	    return [NSString stringWithFormat:
	        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
	        result[0], result[1], result[2], result[3], 
	        result[4], result[5], result[6], result[7],
	        result[8], result[9], result[10], result[11],
	        result[12], result[13], result[14], result[15]
	    ];  
}

%end



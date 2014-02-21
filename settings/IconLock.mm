#import <Preferences/PSListController.h>
#import <CommonCrypto/CommonDigest.h>

static NSString *PLIST_PATH = @"/User/Library/Preferences/com.homeschooldev.iconlock.plist";
#define TextFieldTag 1110102433
#define PassViewTag 1110102434
#define kOrigPassword 120
#define kNewPassword 121
#define kConfirmPassword 122

@interface ILAlertView : UIAlertView
@property (nonatomic, retain) NSString *text;
@end

@implementation ILAlertView
@synthesize text;

- (void)dealloc
{
	self.text = nil;
	[super dealloc];
}
@end

@interface IconLockListController : PSListController
- (void)changePassword:(id)sender;
- (void)donateButton:(id)arg;
- (void)twitterButton:(id)arg;
@end

@implementation IconLockListController

- (id)specifiers 
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
    
    if ([dict objectForKey:@"Password"]) 
	{
        UIView *passView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[self navigationController].view.frame.size.width,[self navigationController].view.frame.size.height)];
        
        passView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [passView setTag:PassViewTag];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0,
                        passView.frame.size.height/2 - (passView.frame.size.width - 10)/2,passView.frame.size.width,40)];
        [textField setTag:TextFieldTag];
		[textField setBackgroundColor:[UIColor whiteColor]];
		[textField setTextAlignment:NSTextAlignmentCenter];
		[textField setPlaceholder:@"Password"];
		[textField setSecureTextEntry:YES];
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [passView addSubview:textField];
		
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[acceptButton setBackgroundColor:[UIColor colorWithRed:0.063 green:0.486 blue:0.965 alpha:1.0]];
        acceptButton.frame = CGRectMake(0,textField.frame.origin.y + textField.frame.size.height + 10,textField.frame.size.width,40);
        [acceptButton setTitle:@"Unlock" forState:UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(acceptButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [passView addSubview:acceptButton];
        [textField release];
        
        [self.view addSubview:passView];
        [passView release];
    }
    
    if(!_specifiers) 
        _specifiers = [[self loadSpecifiersFromPlistName:@"IconLock" target: self] retain];

    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	UIView *passView = [self.view viewWithTag:PassViewTag];
	[passView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
}

- (void)acceptButtonTapped:(id)sender 
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:TextFieldTag];    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];

    if ([[self md5:textField.text] isEqualToString:[dict objectForKey:@"Password"]]) {
        [UIView animateWithDuration:0.3 animations:^{
            [[self.view viewWithTag:PassViewTag] setFrame:CGRectMake(0,481,320,460)];
            [textField resignFirstResponder];
        }
        completion:^(BOOL finished) {
            [[self.view viewWithTag:PassViewTag] removeFromSuperview];
        }];
    }
    else {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You entered an incorrect password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [error show];
        [error release];
    }
}

- (void)changePassword:(id)sender
{
	BOOL hasPassword = YES;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
		hasPassword = NO;
	}
	else
	{
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
		if (![dict objectForKey:@"Password"])
		{
			hasPassword = NO;
		}
	}
	
	if (hasPassword)
	{
		ILAlertView *av = [[ILAlertView alloc] initWithTitle:@"IconLock7" 
			message:@"Enter your current password" 
			delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		av.alertViewStyle = UIAlertViewStyleSecureTextInput;
		[av setTag:kOrigPassword];
		[av show];
		[av release];
	}
	else
	{
		ILAlertView *av = [[ILAlertView alloc] initWithTitle:@"IconLock7" 
			message:@"You don't have a password set yet. Set the password by holding down one of your icons on your home screen." 
			delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
	}
}

- (void)twitterButton:(id)sender 
{
    NSString *URL = @"twitter://user?screen_name=homeschooldev";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/homeschooldev"]];
    }
}

- (void)donateButton:(id)arg 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=C2VUW8ZXX3XFC"]];
}

- (void)showPasswordResetHint:(id)arg
{
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Password Reset" 
		message:@"To reset or delete the password you must delete the PLIST file at /User/Library/Preferences/com.homeschooldev.iconlock.plist. You can do so with iFile." 
		delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[av show];
	[av release];
}

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

//
// Delegation - UIAlertView
//

- (void)alertView:(ILAlertView *)av clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([av tag] == kOrigPassword)
	{
		if (buttonIndex == 1)
		{
			NSDictionary *passwordDict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
			NSString *md5Text = [self md5:[[av textFieldAtIndex:0] text]];
		
			if ([md5Text isEqualToString:[passwordDict objectForKey:@"Password"]]) 
			{
				//Orig password was correct. Show new password box
				ILAlertView *newpassword = [[ILAlertView alloc] initWithTitle:@"IconLock7" 
					message:@"Enter your new password" 
					delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
				newpassword.alertViewStyle = UIAlertViewStyleSecureTextInput;
				[newpassword setTag:kNewPassword];
				[newpassword show];
				[newpassword release];
			}
			else
			{
				//Orig password was incorrect
				ILAlertView *error = [[ILAlertView alloc] initWithTitle:@"Error" message:@"You entered an incorrect password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[error show];
				[error release];
			}
		}
	}
	else if ([av tag] == kNewPassword)
	{
		if (buttonIndex == 1)
		{
			if ([[[av textFieldAtIndex:0] text] isEqualToString:@""])
			{
				//New password was empty. Redisplay.
				ILAlertView *newpassword = [[ILAlertView alloc] initWithTitle:@"IconLock7" 
					message:@"Enter your new password" 
					delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
				newpassword.alertViewStyle = UIAlertViewStyleSecureTextInput;
				[newpassword setTag:kNewPassword];
				[newpassword show];
				[newpassword release];
			}
			else 
			{
				//New password was fine. Show the confirm box.
				ILAlertView *confirm = [[ILAlertView alloc] initWithTitle:@"Password Confirmation" 
					message:[NSString stringWithFormat:@"Please confirm that this password is correct: \n\n%@",[[av textFieldAtIndex:0] text]]
					delegate:self cancelButtonTitle:@"Incorrect" otherButtonTitles:@"Correct", nil];
				[confirm setText:[[av textFieldAtIndex:0] text]];
				[confirm setTag:kConfirmPassword];
				[confirm show];
				[confirm release];
			}
		}
	}
	else if ([av tag] == kConfirmPassword)
	{
		if (buttonIndex == 1)
		{
			//The user selected correct on the confirm box
			NSString *md5Text = [self md5:[av text]];
			NSDictionary *passwordDict = [NSDictionary dictionaryWithObject:md5Text forKey:@"Password"];
			[passwordDict writeToFile:PLIST_PATH atomically:YES];
		}
		else 
		{
			//The user select incorrect on the confirm box so re-present it
			ILAlertView *newpassword = [[ILAlertView alloc] initWithTitle:@"IconLock7" 
					message:@"Enter your new password" 
					delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
			newpassword.alertViewStyle = UIAlertViewStyleSecureTextInput;
			[newpassword setTag:kNewPassword];
			[newpassword show];
			[newpassword release];
		}
	}
}

@end
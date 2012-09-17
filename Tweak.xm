/**
 * LinkOpener - Opens links in 3rd party apps.
 *
 * By Adaminsull <http://jailbreak.h4ck.la>
 * Based on YTOpener by Ad@m <http://hbang.ws>
 * Licensed under the GPL license <http://www.gnu.org/copyleft/gpl.html>
 */

%hook SpringBoard
-(void)_openURLCore:(NSURL *)url display:(id)display publicURLsOnly:(BOOL)publicOnly animating:(BOOL)animated additionalActivationFlag:(unsigned int)flags {
	if (([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"])
		&& [[url host] isEqualToString:@"twitter.com"]
		&& [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]
                && [[url pathComponents] count] == 2) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:[[url pathComponents] objectAtIndex:1]]]];
		return;
	}
	%orig;
NSLog(@"Failed");
}
%end
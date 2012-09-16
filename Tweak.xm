/**
 * LinkOpener- Opens links in 3rd party apps.
 *
 * By Ad@m <http://hbang.ws and changed by adaminsull>
 * Licensed under the GPL license <(http://www.gnu.org/copyleft/gpl.html>
 */

%hook SpringBoard
-(void)_openURLCore:(NSURL *)url display:(id)display publicURLsOnly:(BOOL)publicOnly animating:(BOOL)animated additionalActivationFlag:(unsigned int)flags {
	if (([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"])
		&& ([[url host] isEqualToString:@"twitter.com"] || [[url host] isEqualToString:@"www.twitter.com"])
		&& [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.twitter://"]]) {
		NSArray *params = [[url query] componentsSeparatedByString:@"&"];
		for (NSString *i in params)
			if ([i rangeOfString:@"v="].location == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"vnd.twitter://" stringByAppendingString:
					[i stringByReplacingOccurrencesOfString:@"v=" withString:@""]]]];
				return;
			}
	} else if ([[url scheme] isEqualToString:@"twitter"]
		&& [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.twitter://"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"vnd." stringByAppendingString:[url absoluteString]]]];
		return;
	}
	%orig;
}
%end

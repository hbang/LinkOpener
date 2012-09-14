/**
 * YTOpener - open YouTube links in the new app
 *
 * By Ad@m <http://hbang.ws>
 * Licensed under the GPL license <(http://www.gnu.org/copyleft/gpl.html>
 */

%hook SpringBoard
-(void)_openURLCore:(NSURL *)url display:(id)display publicURLsOnly:(BOOL)publicOnly animating:(BOOL)animated additionalActivationFlag:(unsigned int)flags {
	if (([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"])
		&& ([[url host] isEqualToString:@"youtube.com"] || [[url host] isEqualToString:@"www.youtube.com"])
		&& [[url path] isEqualToString:@"/watch"]
		&& [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.youtube://"]]) {
		NSArray *params = [[url query] componentsSeparatedByString:@"&"];
		for (NSString *i in params)
			if ([i rangeOfString:@"v="].location == 0) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"vnd.youtube://" stringByAppendingString:
					[i stringByReplacingOccurrencesOfString:@"v=" withString:@""]]]];
				return;
			}
	} else if ([[url scheme] isEqualToString:@"youtube"]
		&& [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.youtube://"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"vnd." stringByAppendingString:[url absoluteString]]]];
		return;
	}
	%orig;
}
%end

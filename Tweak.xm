/**
 * LinkOpener - Opens links in 3rd party apps.
 *
 * By Adaminsull <http://h4ck.co.uk>
 * Edited by bensge
 * Licensed under the GPL license <http://www.gnu.org/copyleft/gpl.html>
 */

#import "HBLibOpener.h"
#import "JSONKit.h"

%group LOFacebook
%hook AppDelegate
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApp annotation:(id)annotation {
	if ([url.host isEqualToString:@"profileForLinkOpener"] && [url.pathComponents count] == 2) {
		// This is a terrible way to do this, however Facebook crashes if we do this asynchronously. Don't ever do this elsewhere.
		NSData *output = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://graph.facebook.com/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60] returningResponse:nil error:nil];
		if (output == nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			NSDictionary *json = [output objectFromJSONData];
			return %orig(application, [NSURL URLWithString:[@"fb://profile/" stringByAppendingString:[json objectForKey:@"id"]]], sourceApp, annotation);
		}
		return NO;
	} else {
		return %orig;
	}
}
%end
%end

%ctor {
	%init;
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
		[[HBLibOpener sharedInstance] registerHandlerWithName:@"LinkOpener" block:^(NSURL *url) {
			if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
				if ([url.host isEqualToString:@"twitter.com"] && [url.pathComponents count] == 2) {
					if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
						return [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
					} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
						return [NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
					}
				} else if ([url.host isEqualToString:@"www.facebook.com"] && [url.pathComponents count] == 2 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
					return [NSURL URLWithString:[@"fb://profileForLinkOpener/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
				} else if (([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) && [url.pathComponents count] == 3 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb://"]]) {
					// Edited by bensge to add imdb app support
					// You should've paid a million for this! I swear, if someone steals this and takes money for it, i swear i'll kill him....
					return [NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:[url.pathComponents objectAtIndex:2]]];
				} else if (([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) && [url.pathComponents count] == 4 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ebay://"]]) {
					return [NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:[url.pathComponents objectAtIndex:3]]];
				} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.youtube://"]]) {
					BOOL isMobile = NO;
					if (([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) && ([url.host isEqualToString:@"youtube.com"] || [url.host isEqualToString:@"www.youtube.com"] || (isMobile = [url.host isEqualToString:@"m.youtube.com"])) && isMobile ? [url.fragment rangeOfString:@"/watch"].length > 0 : [url.path isEqualToString:@"/watch"]) {
						NSArray *params = [(isMobile ? [url.fragment stringByReplacingOccurrencesOfString:@"/watch?" withString:@""] : url.query) componentsSeparatedByString:@"&"];
						for (NSString *i in params) {
							if ([i rangeOfString:@"v="].location == 0) {
								return [NSURL URLWithString:[@"vnd.youtube://" stringByAppendingString:[i stringByReplacingOccurrencesOfString:@"v=" withString:@""]]];
							}
						}
					} else if ([url.host isEqualToString:@"youtu.be"] && [url.pathComponents count] > 1) {
						return [NSURL URLWithString:[@"vnd.youtube://" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
					} else if ([url.scheme isEqualToString:@"youtube"]) {
						return [NSURL URLWithString:[@"vnd." stringByAppendingString:url.absoluteString]];
					}
				} else if (([url.scheme isEqualToString:@"maps"] || ([url.host hasPrefix:@"maps.google.co"] && [url.path isEqualToString:@"/maps"])) && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
					return [NSURL URLWithString:[@"comgooglemaps://search?" stringByAppendingString:[url.scheme isEqualToString:@"maps"] ? [url.absoluteString stringByReplacingOccurrencesOfString:@"maps:" withString:@""] : url.query]];
				}
			}
			return (objc_object *)nil;
		}];
	} else {
		%init(LOFacebook);
	}
}

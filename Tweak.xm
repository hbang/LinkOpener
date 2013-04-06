/**
 * LinkOpener - Opens links in 3rd party apps.
 *
 * By HASHBANG Productions <http://hbang.ws>
 *
 * Edited by bensge for IMDb support.
 *
 * Netbot support by Aehmlo - Riposte requires to query
 * ADN's API for user ID. If you want to implement this,
 * go ahead, but I don't use it enough to.
 * Twitter status support by Aehmlo.
 *
 * Licensed under the GPL license <http://hbang.ws/s/gpl>
 */

#import "HBLibOpener.h"
#import "JSONKit.h"

%group LOFacebook
%hook AppDelegate
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApp annotation:(id)annotation {
	if ([url.host isEqualToString:@"profileForLinkOpener"] && url.pathComponents.count == 2) {
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
				if ([url.host isEqualToString:@"twitter.com"]) {
					if (url.pathComponents.count == 2) {
						if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
							return [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
						} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
							return [NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
						} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:///"]]) {
							return [NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
						} else {
							return (id)nil;
						}
					} else if (url.pathComponents.count == 4 && ([[url.pathComponents objectAtIndex:3] isEqualToString:@"status"] || [[url.pathComponents objectAtIndex:3] isEqualToString:@"statuses"])) {
						if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
							return [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/status/%@", [url.pathComponents objectAtIndex:1], [url.pathComponents objectAtIndex:3]]];
						} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:///"]]) {
							return [NSURL URLWithString:[@"twitterrific:///tweet?id=" stringByAppendingString:[url.pathComponents objectAtIndex:3]]];
						} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
							return [NSURL URLWithString:[@"twitter:///status?id=" stringByAppendingString:[url.pathComponents objectAtIndex:3]]];
						} else {
							return (id)nil;
						}
					}
				} else if ([url.host isEqualToString:@"www.facebook.com"] && url.pathComponents.count == 2 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
					return [NSURL URLWithString:[@"fb://profileForLinkOpener/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
				} else if (([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) && url.pathComponents.count == 3 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb://"]]) {
					// Edited by bensge to add imdb app support
					return [NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:[url.pathComponents objectAtIndex:2]]];
				} else if (([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) && url.pathComponents.count == 4 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ebay://"]]) {
					return [NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:[url.pathComponents objectAtIndex:3]]];
				} else if ([url.host isEqualToString:@"alpha.app.net"] && url.pathComponents.count == 2 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"netbot://"]]) {
					return [NSURL URLWithString:[@"netbot:///user_profile/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]];
				}
			}
			return (id)nil;
		}];
	} else {
		%init(LOFacebook);
	}
}

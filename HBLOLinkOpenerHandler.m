/**
 * Edited by bensge for IMDb support.
 * Netbot support by Aehmlo - Riposte requires to query
 * ADN's API for user ID. If you want to implement this,
 * go ahead, but I don't use it enough to.
 * Twitter status support, Twitterrific support, and
 * Cydia support by Aehmlo.
 */

#import "HBLOLinkOpenerHandler.h"

@implementation HBLOLinkOpenerHandler

- (instancetype)init {
	self = [super init];

	if (self) {
		self.name = @"LinkOpener";
		self.identifier = @"LinkOpener";
	}

	return self;
}

- (NSURL *)openURL:(NSURL *)url sender:(NSString *)sender {
	if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
		return nil;
	}

	if ([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"mobile.twitter.com"]) {
		if (url.pathComponents.count == 2) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
				return [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:url.pathComponents[1]]];
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
				return [NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:url.pathComponents[1]]];
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:///"]]) {
				return [NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:url.pathComponents[1]]];
			} else {
				return (id)nil;
			}
		} else if (url.pathComponents.count == 4 && ([url.pathComponents[2] isEqualToString:@"status"] || [url.pathComponents[2] isEqualToString:@"statuses"])) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
				return [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/status/%@", url.pathComponents[1], url.pathComponents[3]]];
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:///"]]) {
				return [NSURL URLWithString:[@"twitterrific:///tweet?id=" stringByAppendingString:url.pathComponents[3]]];
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
				return [NSURL URLWithString:[@"twitter:///status?id=" stringByAppendingString:url.pathComponents[3]]];
			} else {
				return (id)nil;
			}
		}
	} else if (([url.host isEqualToString:@"www.facebook.com"] || [url.host isEqualToString:@"facebook.com"] || [url.host isEqualToString:@"fb.com"]) && url.pathComponents.count == 2 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
		return [NSURL URLWithString:[@"fb://profileForLinkOpener/" stringByAppendingString:url.pathComponents[1]]];
	} else if (([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) && url.pathComponents.count == 3 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb://"]]) {
		return [NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:url.pathComponents[2]]];
	} else if (([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) && url.pathComponents.count == 4 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ebay://"]]) {
		return [NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:url.pathComponents[3]]];
	} else if ([url.host isEqualToString:@"alpha.app.net"] && url.pathComponents.count == 2 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"netbot://"]]) {
		return [NSURL URLWithString:[@"netbot:///user_profile/" stringByAppendingString:url.pathComponents[1]]];
	} else if ([url.host isEqualToString:@"cydia.saurik.com"] && url.pathComponents.count == 3 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
		return [NSURL URLWithString:[@"cydia://package/" stringByAppendingString:url.pathComponents[2]]];
	} else if (([url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"]) && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ioc://"]]) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"ioc://%@%@", url.host, url.path]];
	} else if (((([url.host isEqualToString:@"reddit.com"] || [url.host hasSuffix:@".reddit.com"]) && ([url.pathComponents containsObject:@"comments"] || url.pathComponents.count == 3)) || [url.host isEqualToString:@"redd.it"]) && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alienblue://"]]) {
		// *groan*
		NSString *threadID = nil;

		if ([url.host isEqualToString:@"redd.it"] && url.pathComponents.count == 2) {
			// http://redd.it/:thread
			threadID = url.pathComponents[1];
		} else if ((url.pathComponents.count == 5 || url.pathComponents.count == 6) && [url.pathComponents[2] isEqualToString:@"r"] && [url.pathComponents containsObject:@"comments"]) {
			// https://www.reddit.com/r/:subreddit/comments/:thread/:name?/
			threadID = url.pathComponents[4];
		}

		if (threadID) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"alienblue://thread/%@", threadID]];
		} else if (url.pathComponents.count == 3 && [url.pathComponents[1] isEqualToString:@"r"]) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"alienblue://r/%@", url.pathComponents[2]]];
		}

		return [NSURL URLWithString:[@"alienblue://_linkopener_url?" stringByAppendingString:url.absoluteString]];
	}

	return nil;
}

@end

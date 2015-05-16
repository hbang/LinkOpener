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

- (id)openURL:(NSURL *)url sender:(NSString *)sender {
	if ([url.scheme isEqualToString:@"file"]) {
		return [NSURL URLWithString:[@"ifile://%@" stringByAppendingString:url.path]];
	}

	if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
		return nil;
	}

	if ([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"mobile.twitter.com"]) {
		if (url.pathComponents.count == 2) {
			return @[
				[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:url.pathComponents[1]]],
				[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:url.pathComponents[1]]],
				[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:url.pathComponents[1]]]
			];
		} else if (url.pathComponents.count == 4 && ([url.pathComponents[2] isEqualToString:@"status"] || [url.pathComponents[2] isEqualToString:@"statuses"])) {
			return @[
				[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/status/%@", url.pathComponents[1], url.pathComponents[3]]],
				[NSURL URLWithString:[@"twitterrific:///tweet?id=" stringByAppendingString:url.pathComponents[3]]],
				[NSURL URLWithString:[@"twitter:///status?id=" stringByAppendingString:url.pathComponents[3]]]
			];
		}
	} else if (([url.host isEqualToString:@"www.facebook.com"] || [url.host isEqualToString:@"facebook.com"] || [url.host isEqualToString:@"fb.com"]) && url.pathComponents.count == 2) {
		return [NSURL URLWithString:[@"fb://profileForLinkOpener/" stringByAppendingString:url.pathComponents[1]]];
	} else if (([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) && url.pathComponents.count == 3) {
		return [NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:url.pathComponents[2]]];
	} else if (([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) && url.pathComponents.count == 4) {
		return [NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:url.pathComponents[3]]];
	} else if ([url.host isEqualToString:@"alpha.app.net"] && url.pathComponents.count == 2) {
		return [NSURL URLWithString:[@"netbot:///user_profile/" stringByAppendingString:url.pathComponents[1]]];
	} else if ([url.host isEqualToString:@"cydia.saurik.com"] && url.pathComponents.count == 3) {
		return [NSURL URLWithString:[@"cydia://package/" stringByAppendingString:url.pathComponents[2]]];
	} else if ([url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"]) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"ioc://%@%@", url.host, url.path]];
	} else if ((([url.host isEqualToString:@"reddit.com"] || [url.host hasSuffix:@".reddit.com"]) && ([url.pathComponents containsObject:@"comments"] || url.pathComponents.count == 3)) || [url.host isEqualToString:@"redd.it"]) {
		return [NSURL URLWithString:[@"alienblue://_linkopener_url?" stringByAppendingString:url.absoluteString]];
	} else if ([url.host hasSuffix:@".tumblr.com"]) {
		NSString *blog = [url.host componentsSeparatedByString:@"."][0];

		if (url.pathComponents.count < 2) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"tumblr://x-callback-url/blog?blogName=%@", blog. url.pathComponents[2]]];
		} else if (url.pathComponents.count > 3 && [url.pathComponents[1] isEqualToString:@"post"]) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"tumblr://x-callback-url/blog?blogName=%@&postID=%@", blog. url.pathComponents[2]]];
		}
	} else if ([url.host isEqualToString:@"vine.co"]) {
		if (url.pathComponents.count > 2) {
			if ([url.pathComponents[1] isEqualToString:@"v"]) {
				return [NSURL URLWithString:[NSString stringWithFormat:@"vine://post/%@", url.pathComponents[2]]];
			} else if ([url.pathComponents[1] isEqualToString:@"u"]) {
				return [NSURL URLWithString:[NSString stringWithFormat:@"vine://user/%@", url.pathComponents[2]]];
			}
		}
	} else if ([url.host isEqualToString:@"instagram.com"]) {
		if (url.pathComponents.count == 2) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", url.pathComponents[1]]];
		} else if (url.pathComponents.length == 3 && [url.pathComponents[1] isEqualToString:@"p"]) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", url.pathComponents[1]]];
		} else if (url.pathComponents.length == 4 && [url.pathComponents[1] isEqualToString:@"explore"] && [url.pathComponents[2] isEqualToString:@"tags"]) {
			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://tag?name=%@", url.pathComponents[3]]];
		}
	}

	return nil;
}

@end

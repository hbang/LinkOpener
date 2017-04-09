#import <AlienBlue/AppSchemeCoordinator.h>
#import <AlienBlue/NavigationManager.h>
#import <AlienBlue/Post.h>

@interface NSData (JSONKit)

- (NSDictionary *)objectFromJSONData;

@end

#pragma mark - Facebook

%group Facebook
%hook AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApp annotation:(id)annotation {
	if ([url.host isEqualToString:@"profileForLinkOpener"] && url.pathComponents.count == 2) {
		// This is a terrible way to do this. Don't ever do this.
		// TODO: un-stupid this

		NSData *output = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://graph.facebook.com/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60] returningResponse:nil error:nil];

		if (output == nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];

			return NO;
		}

		NSDictionary *json = output.objectFromJSONData;

		if (json && [json objectForKey:@"id"]) {
			return %orig(application, [NSURL URLWithString:[@"fb://profile/" stringByAppendingString:[json objectForKey:@"id"]]], sourceApp, annotation);
		}

		return NO;
	} else {
		return %orig;
	}
}

%end
%end

#pragma mark - Alien Blue

%group AlienBlue
%hook AlienBlueAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	// we implement our own url handler for threads in alien blue, because there’s nothing built in,
	// which makes me sad. especially considering there’s built in support for opening subreddits but
	// not threads… urls are expected to look something like:
	// alienblue://_linkopener_url?https://www.reddit.com/r/pics/comments/92dd8/test_post_please_ignore/
	if ([url.host isEqualToString:@"_linkopener_url"]) {
		// TODO: ew, this is so hacky
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			// grab the url to open from the query of the url
			NSString *cleanedURL = url.query;

			// postSkeletonFromRedditUrl: chokes on urls that look like https://redd.it/92dd8 (or even
			// https://www.reddit.com/92dd8 but that seems uncommon enough to not bother attempting to
			// support). if we come across a redd.it url, insert /comments/ so it parses it successfully
			if ([cleanedURL rangeOfString:@"http://redd.it/"].location == 0) {
				cleanedURL = [@"http://redd.it/comments/" stringByAppendingString:[cleanedURL substringFromIndex:16]];
			}

			// get a Post object from the url, and get the NavigationManager to show it
			Post *post = [%c(Post) postSkeletonFromRedditUrl:cleanedURL];
			[[%c(NavigationManager) shared] showCommentsForPost:post contextId:post.contextCommentIdent fromController:nil];
		});

		return YES;
	} else {
		return %orig;
	}
}

%end
%end

#pragma mark - Constructor

%ctor {
	%init;

	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.facebook.Facebook"]) {
		%init(Facebook);
	} else if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.reddit.alienblue"] || [[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.reddit.alienbluehd"]) {
		%init(AlienBlue);
	}
}

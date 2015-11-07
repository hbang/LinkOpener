#import <AlienBlue/AppSchemeCoordinator.h>

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
			[alert release];

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
	if ([url.host isEqualToString:@"_linkopener_url"]) {
		[%c(AppSchemeCoordinator) openRedditThreadUrl:url.query];
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

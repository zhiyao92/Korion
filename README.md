# Korion

## Testing scenarios on real devices

[X] Implement a screen containing WKWebView and toolbar at the bottom

[X] Toolbar should have back and forward navigation actions

[X] WKWebView is hidden by default after initial app launch and the user should see a button in the center of the screen. 
Tapping this button will start any website load inside WKWebView and will also show WKWebView full screen (top to safe area, bottom to toolbar.topAnchor).

[X] Edit enabled state of back/forward actions accordingly to reflect an ability for the user to go either back or forward.

[X] Back navigation action should allow the user to go from a website loaded in WKWebView to the first state where 
WKWebView was hidden and the user could only see a button in the screen's center.

[X] If the website was loaded once and the user navigated to initial state, 
forward navigation action should allow them to move further to WKWebView with the loaded website

[X] Implement support for the same horizontal gesture to handle transition between WKWebView and initial state back and forward

[X] save and restore WKWebView navigation history between app launches, so having any website loaded into WKWebView and closed app at this state 
should restore an app with WKWebView history, state will contain loaded website and back navigation action 
will be enabled so user can either tap it or swipe left to right to go to start page.

[] Implement page zoom feature which behaves exactly like in iOS Safari.


## Improvements/comments in regards to the project

1. ViewModel should be used so all logics related should reside within ViewModel

2. CoreData or any local DB is preferred over `UserDefault` for scalability purpose. Additionally, iCloud can be enabled so the history can be synced across multiple different devices

3. `allowsBackForwardNavigationGestures` back and forward swipping navigation does not sync with pressing backward and forward button. 
Alternatively, we can disable that and use `UIPageViewController` for every new url to sync the behaviour between swipping and pressing the navigation button

4. No 3rd party was used to keep the project lightweight

5. Thinking outside of the box approach is made as WebKit lack certain features such as not saving/restoring session, 

6. UIPageViewController was used because of the native swipping behaviour and not sacrificing `allowsBackForwardNavigationGestures` native behaviour. Prefer to keep native behaviour/animation across the app

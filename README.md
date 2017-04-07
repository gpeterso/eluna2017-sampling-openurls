# Sampling OpenURLs from Primo+Alma
Details on how we capture and sample OpenURL access events as described at our [ELUNA 2017 presentation](https://elunaannualmeeting2017.sched.com/event/AKlT/testing-identifying-and-classifying-openurl-access-problems)

## Capturing OpenURLs
1. If you haven't already done so, [set up Google Analytics](https://support.google.com/analytics/answer/1008080?hl=en) for your Primo site. 
1. Make sure you have something like the following in your footer file. This will provide you with page view tracking in Google Analytics. 
```html
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'YOUR_GA_TRACKING_ID');
  ga('send', 'pageview');
  ga('set', 'anonymizeIp', true);
</script>
```
1. Optionally, if you want to track any time someone looks at an Alma Resolver menu as a [custom event](https://developers.google.com/analytics/devguides/collection/analyticsjs/events), you can add the following JavaScript: 
```javascript
(function() {
  var sent = [];
  var iframeSelector = "iframe[src*='alma.exlibrisgroup.com/view/uresolver/']:visible";
  var removeIp = function(url) {return url.replace(/user_ip=[\d.]+(&)?/g, '')};
  var sendResolverEvents = function() {
    var send = function(label, url) {
      url = removeIp(url);
      if ( $.inArray(label+url, sent) === -1 ) {
        ga('send', 'event', 'Alma Resolver', label, url);
        sent.push(label+url);
      }
    };
    $(".EXLContainer-requestTab "    + iframeSelector).each(function() {
      var url = $(this).attr('src');
      send('GetIt 1', url);
    });
    $(".EXLContainer-moreTab "       + iframeSelector).each(function() {
      var url = $(this).attr('src');
      send('GetIt 2', url);
    });
    $(".EXLContainer-viewOnlineTab " + iframeSelector).each(function() {
      var url = $(this).attr('src');
      send('ViewIt', url);
    });
  }
  sendResolverEvents();
  $(document).ajaxComplete(function(event, request, settings) {
    if (RegExp("expand\\.do").test(settings.url)) {
      sendResolverEvents();
    }
  });
})();
```

This will capture the Alma Resolver OpenURL for any "View It" or "Get It" tab that a user views.  

## Sampling OpenUrls
1. Clone this repository.
1. Make sure you have [Ruby](https://www.ruby-lang.org/en/documentation/installation/) and [Bundler](http://bundler.io/) installed.
1. Follow the "setup authentication" instructions [here](https://github.com/google/google-api-ruby-client-samples/tree/master/service_account#setup-authentication) to configure access to the Google Analytics API.
1. Run `bundle install`
1. To randomly sample OpenURL page views for a given day, run `bundle exec ./sample_openurl_pageviews.rb <date> <number>`. For example, run `bundle exec ./sample_openurl_pageviews.rb 2017-04-01 10` to sample ten page views from April 1st, 2017.
1. Similarly, run `bundle exec ./sample_viewit_events.rb <date> <number>` to randomly sample "View It" events for a given day. 

 

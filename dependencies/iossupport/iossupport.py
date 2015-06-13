def open_url(url):

    if url.startswith("file:"):
        raise Exception("Opening file urls is not supported: " + url)

    from pyobjus import autoclass, objc_str
    NSURL = autoclass('NSURL')
    UIApplication = autoclass("UIApplication")

    nsurl = NSURL.URLWithString_(objc_str(url))
    UIApplication.sharedApplication().openURL_(nsurl)

# Web browser support.
class IOSBrowser(object):
    def open(self, url, new=0, autoraise=True):
        open_url(url)
    def open_new(self, url):
        open_url(url)
    def open_new_tab(self, url):
        open_url(url)

import webbrowser
webbrowser.register('ios', IOSBrowser, None, -1)


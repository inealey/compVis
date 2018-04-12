import urllib.request
 
headers = {}
headers['User-Agent'] = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:48.0) Gecko/20100101 Firefox/48.0"
 
req = urllib.request.Request('http://192.168.0.100:5000', headers = headers)
#req = urllib.request.Request('http://s0.geograph.org.uk/photos/40/57/405725_b17937da.jpg', headers = headers)
html = urllib.request.urlopen(req).read()
print(html)

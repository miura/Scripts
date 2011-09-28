#!/usr/bin/env python
#
# Python script to download all linked PDF  in a web page

import urllib, re
from BeautifulSoup import BeautifulSoup

location = "http://www1.doshisha.ac.jp/~mjin/R/" 
#location = "http://x68000.q-e-d.net/~68user/unix/genre.html"
page = urllib.urlopen(location)
page1 = urllib.urlopen(location).read(20000)
soup = BeautifulSoup(page)
print page
# Find every occurrence of <a href="...">XLS</a> and download the file pointed to by href="...".
links = soup.findAll('a')
links = re.findall('<a href=(.*?)>.*?</a>',page1)
print len(links)
for link in links:
    #if link.string == 'XLS':
    #linkurl = link['href']
    print link
    #print linkurl
    #if linkurl.endswith('.pdf'):
        #filename = link.get('href')
        #print("Retrieving " + filename)
        ##url = location + filename
        ##urllib.urlretrieve(url,filename)


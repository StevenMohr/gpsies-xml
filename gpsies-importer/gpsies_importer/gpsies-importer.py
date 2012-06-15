'''
Created on 11.06.2012

@author: Steven Mohr
'''
from urllib2 import *

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=100&resultPage={page}&trackTypes=jogging&filetype=kml"

def main():
    api_key = sys.argv[1]
    for page in range(1, 10):
        connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page))
        print connection.read()
        connection.close()
    

if __name__ == "__main__":
    main()

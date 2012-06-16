'''
Created on 11.06.2012

@author: Steven Mohr
'''
from urllib2 import *
from threading import Thread

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=10&resultPage={page}&trackTypes=jogging&filetype=kml"

def parse_answer(answer):
    print answer

def main():
    threads = list()
    api_key = sys.argv[1]
    for page in range(1, 2):
        connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page, timeout=10))
        answer = connection.read()
        thread = Thread(target = parse_answer, args=(answer))
        threads.append(thread)
        thread.start()
        connection.close()
    print "Waiting for threads to join ..."    
    for thread in threads:
        thread.join()

if __name__ == "__main__":
    main()

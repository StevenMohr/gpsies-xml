'''
Created on 11.06.2012

@author: Steven Mohr
'''
from urllib2 import *
from threading import Thread
from lxml import etree
from extract.TrackExtract import TrackExtract
from gpsies_importer.extract.KMLExtract import KMLExtract

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=100&resultPage={page}&trackTypes=jogging&filetype=kml"

def parse_answer(answer):
    print answer

def main():
    threads = list()
    api_key = sys.argv[1]
    for page in range(500, 1000):
        connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page), timeout=10)
        answer = connection.read()
        
        print answer
        #answer.join()
        #if answer is not None:
        #    thread = Thread(target = parse_answer, args=(answer))
        #    threads.append(thread)
        #    thread.start()
        connection.close()
    #print "Waiting for threads to join ..."    
    #for thread in threads:
    #    thread.join()
      
def analyze_track(track):
    downloadLink = track.xpath("//downloadLink/text()") 
    trackXML = TrackExtract(track_element_xml = track ).analyze()   
    connection = urlopen(downloadLink[0], timeout=10)
    answer = connection.read()
    connection.close()
    waypoints = KMLExtract(answer).analyze()
    
    trackXML.getroot().append(waypoints)
    print etree.tostring(trackXML.getroot())
        
def mainFromFile():
    threadPool = ThreadPool(30)
    file = open("data.xml")
    root = etree.parse(file)
    tracks = root.xpath("//track")
    for track in tracks[0:10]:
        threadPool.add_task(analyze_track, track)
    threadPool.wait_completion()
        
    
from Queue import Queue
from threading import Thread

class Worker(Thread):
    """Thread executing tasks from a given tasks queue"""
    def __init__(self, tasks):
        Thread.__init__(self)
        self.tasks = tasks
        self.daemon = True
        self.start()
    
    def run(self):
        while True:
            func, args, kargs = self.tasks.get()
            try: func(*args, **kargs)
            except Exception, e: print e
            self.tasks.task_done()

class ThreadPool:
    """Pool of threads consuming tasks from a queue"""
    def __init__(self, num_threads):
        self.tasks = Queue(num_threads)
        for _ in range(num_threads): Worker(self.tasks)

    def add_task(self, func, *args, **kargs):
        """Add a task to the queue"""
        self.tasks.put((func, args, kargs))

    def wait_completion(self):
        """Wait for completion of all the tasks in the queue"""
        self.tasks.join()        

if __name__ == "__main__":
    mainFromFile()

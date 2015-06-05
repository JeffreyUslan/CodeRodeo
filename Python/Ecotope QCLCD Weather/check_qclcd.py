
# Import common libraries
import re
import time

# Import libraries for python2/python3 dependencies
try:
    # python3
    from urllib.request import urlopen
except ImportError:
    # python2
    from urllib2 import urlopen

# Define the two main paths I'll be working with: NOAA and server directory
urlpath = "http://cdo.ncdc.noaa.gov/qclcd_ascii/"
lclpath = "/fileserver/server/weatherData/qclcd/data/archive/"

# Go to the NOAA main page and get the html listing all the available files
u = urlopen(urlpath)
html = u.read()
u.close()

# Set up header for log
timenow = int(time.time())
logpath = lclpath + "../../log/check_qclcd_files_" + str(timenow) + ".csv"
f = open(logpath, "w")
f.write("file,serversize,localsize,difference,diffflag,newflag\n")
f.close()

# Use regular expression to get filenames from the raw html and loop through them
fnames = re.findall(r'^.*<[aA] [hH][rR][eE][fF]="(.+(?:\.tar\.gz|\.zip))".*$', html, re.MULTILINE)
result = ""
for fname in fnames:
	newflag = 0
	
	# Open the file on the server and get header information (filesize is in there)
	u = urlopen(urlpath + fname)
	meta = u.info()
	urlsize = meta.getheaders("Content-Length")[0]
	u.close()
	
	# Try opening local version to get size and if it doesn't exist return empty
	try: 
		f = open(lclpath + fname, "rb")
		lclsize = len(f.read())
		diff = int(urlsize) - int(lclsize)
		if diff == 0:
		    flag = 0
		else:
		    flag = 1
	except:
		lclsize = None
		diff = None
		flag = None
	
	# If size is different, download the server version
	if flag == 1 or flag == None :
		print "Downloading new file: " + fname
		
		# Open file on server and local file, then write to local file
		u = urlopen(urlpath + fname)
		f = open(lclpath + fname, "wb+")
		f.write(u.read())
		
		# Recalculate summary parameters
		lclsize = len(f.read())
		diff = int(urlsize) - int(lclsize)
		if diff == 0:
		    flag = 0
		else:
		    flag = 1
		newflag = 1
		
		# Close files
		f.close
		u.close
	
	# Write name and sizes to recursive variable
	r = fname + "," + str(urlsize) + "," + str(lclsize) + "," + str(diff) + "," + str(flag) + "," + str(newflag)
	print r
	result = result + r + "\n"
	
	# Write out text variable to file
	f = open(logpath, "a")
	f.write(r + "\n")
	f.close()


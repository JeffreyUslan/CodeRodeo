#!/usr/bin/python

#written by Nick Kvaltine, 2014.01.06
#The purpose of this script is to process a raw data file and remove a section from the beginning
#where the time interval is 5 minutes instead of one minute.  This is a problem with (at least) some of the Voltex data
#and will give erroneous calibrations.  The script as written does not limit itself to just sections in the beginning though

#It takes an argument from the command line which is the file to be checked
#for 5 minute intervals
import sys


if len(sys.argv) != 2:
	print("This script takes a single argument.")
	sys.exit(1)
	

datetime = ""
time = ""
minutes = ""

lastMinutes = ""
thisMinutes = ""

	
inFILE = open(sys.argv[1],"r")
outFILE = open(sys.argv[1] + "cut", "w")

#this is the line full of names
line = inFILE.readline()
outFILE.write(line)

#prime the test with another line
line = inFILE.readline()
datetime = line.split(',')[1]
time = datetime.split(' ')[1]
minutes = time.split(':')[1]

lastMinutes = int(minutes)

for line in inFILE:
	datetime = line.split(',')[1]
	time = datetime.split(' ')[1]
	minutes = time.split(':')[1]
	
	thisMinutes = int(minutes)
	
	if thisMinutes - lastMinutes == 1:
		outFILE.write(line)
	
	lastMinutes = thisMinutes
	
inFILE.close()
outFILE.close()

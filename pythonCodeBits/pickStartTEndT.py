#!/usr/bin/python

#written by Nick Kvaltine, 2014.01.06
#The purpose of this script is to process a raw data file and print the header
#and data from between the start and end times passed in as arguments 
#it prints to a file, which is the name of the input file with 'cut' appended to it


#It takes three arguments from the command line:
#the data file, the start time, in format yyyy.mm.dd, and the end time in the same format

import sys


if len(sys.argv) != 4:
	print("This script takes three arguments.")
	sys.exit(1)
	

datetime = ""
date = ""
year = ""
month = ""
day = ""


afterStart = False

(startYear, startMonth, startDay) = sys.argv[2].split('.')
(endYear, endMonth, endDay) = sys.argv[3].split('.')

	
inFILE = open(sys.argv[1],"r")
outFILE = open(sys.argv[1] + "cut", "w")

#this is the header line full of names
line = inFILE.readline()
outFILE.write(line)


for line in inFILE:
	afterStart = False
	
	datetime = line.split(',')[1]
	date = datetime.split(' ')[0]
	year = date.split('/')[2]
	month = date.split('/')[0]
	day = date.split('/')[1]

	
	if year > startYear:
		afterStart = True
	elif year == startYear:
		if month > startMonth:
			afterStart = True
		elif month == startMonth:
			if day >= startDay:
				afterStart = True
			else:
				afterStart = False
				continue
		else:
			afterStart = False
			continue
	else:
		afterStart = False
		continue
		
	
	if afterStart == True:
		if year < endYear:
			outFILE.write(line)
		elif year == endYear:
			if month < endMonth:
				outFILE.write(line)
			elif month == endMonth:
				if day <= endDay:
					outFILE.write(line)
				else:
					continue
			else:
				continue
		else:
			continue
			

inFILE.close()
outFILE.close()

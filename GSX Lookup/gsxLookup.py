#!/usr/bin/python
#Created by Burgin, Thomas (NIH/NIMH) [C]
import sys, getopt
from subprocess import Popen, PIPE, STDOUT

#Make sense of CLI arguments
def main(argv):
    serials = ''
    format = ''
    username = ''
    password = ''
    soldto = ''
    location = ''
    script = ''
    
    try:
        opts, args = getopt.getopt(argv,"hu:p:t:s:f:w:x:")
        #print opts
        if len(opts) == 0:
            print 'gsxLookup.py -u <Apple ID> -p <Password> -t <GSX Sold To Account> -f <Format [pdf, csv, text]> -w <Save To> -s <Path to Serial Number List>'
            sys.exit(2)
    except getopt.GetoptError:
        print 'gsxLookup.py -u <Apple ID> -p <Password> -t <GSX Sold To Account> -f <Format [pdf, csv, text]> -w <Save To> -s <Path to Serial Number List>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'gsxLookup.py -u <Apple ID> -p <Password> -t <GSX Sold To Account> -f <Format [pdf, csv, text]> -w <Save To> -s <Path to Serial Number List>'
            sys.exit()
        elif opt in ("-u"):
            username = arg
        elif opt in ("-p"):
            password = arg
        elif opt in ("-t"):
            soldto = arg
        elif opt in ("-s"):
            serials = arg
        elif opt in ("-f"):
            format = arg
        elif opt in ("-w"):
            location = arg
        elif opt in ("-x"):
            script = arg
    gsx(serials, format, username, password, soldto, location, script)

#Define GSXInfo Plugin
def gsx(serials, format, username, password, soldto, location, script):
	serailList=([i.strip().split() for i in open(serials).readlines()])
	
	#Set the Header for the CSV Doc
	csvHeader =  "echo serialNumber,warrantyStatus,coverageEndDate,coverageStartDate,daysRemaining,estimatedPurchaseDate,globalWarranty,purchaseCountry,registrationDate,imageURL,explodedViewURL,manualURL,productDescription,configDescription,slaGroupDescription,ecorathFlag,powerTrainFlag,triCareFlag,contractCoverageEndDate,contractCoverageStartDate,laborCovered,limitedWarranty,partCovered,acPlusFlag > %s" % location
	header = Popen(csvHeader, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
	output = header.communicate()
	
	#Run a loop on every serail
	i = 1
	for number in serailList:
		addGSXInfo = script + " -s " + soldto + " -u " + username + " -p " + password + " -f " + format + " -d " + number[0] + " status warranty | grep -v manualURL"
		event = Popen(addGSXInfo, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
		output = event.communicate()
        
		if 'GsxException' in output[0]:
			if 'obsolete' in output[0]:
				obsolete =  "echo %s,OBSOLETE, >> %s" % (number[0], location)
				event = Popen(obsolete, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
				obsoleteOutput = event.communicate()
			else:
				serialInvalid =  "echo %s,SerialInvalid, >> %s" % (number[0], location)
				event = Popen(serialInvalid, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
				serialInvalidOutput = event.communicate()
		else:
			finalGood = output[0].rstrip()
			print finalGood
			goodResult = "echo "'%s'" >> %s" % (finalGood, location)
			event = Popen(goodResult, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
			goodResultOutput = event.communicate()
		print "%s out of %s serials" % (i, len(serailList))
		i = i + 1
if __name__ == "__main__":
    main(sys.argv[1:])

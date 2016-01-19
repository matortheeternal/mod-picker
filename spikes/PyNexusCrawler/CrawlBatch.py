import sys
import PyNexusCrawler

# GET FILENAME FROM USER INPUT
filename = raw_input("Enter the filename of the file with the IDs you want to crawl: ")

# OPEN THE LIST OF NEXUS MOD IDS
with open(filename, 'r') as input:
	data = input.read()
	# CRAWL EACH ID
	for nm_id in data.splitlines():
		PyNexusCrawler.crawl_mod(nm_id)
		print("\n\n")

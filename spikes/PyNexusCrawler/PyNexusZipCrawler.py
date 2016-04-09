import urllib
import sys
import os
from bs4 import BeautifulSoup

def crawl_zip_content(f_id, g_id):
    # CONSTRUCT THE URL
	url = "http://www.nexusmods.com/skyrim/ajax/zipcontent/?f_id=" + f_id + "&g_id=" + g_id
	
	# GET WEB PAGE
	print("HTTP GET \""+url+"\"")
	page = urllib.urlopen(url).read()
	print("SUCCESS: Recieved "+str(sys.getsizeof(page))+" Bytes\n")
	
	# PARSE PAGE
	print("PARSING ZIP CONTENT...")
	soup = BeautifulSoup(page, "html.parser")
	soup = BeautifulSoup(soup.prettify(), "html.parser")
	text = soup.get_text()
	lines = text.split("\n")
	newlines = [];
	for line in reversed(lines):
		if (line.strip() != ""):
			newlines.insert(0, line);
	
	# RESULT
	newText = "\n".join(newlines)
	output = open('./zipcontent.txt', 'a')
	output.write(newText)
	
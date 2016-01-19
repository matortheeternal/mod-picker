import urllib
import sys
import os
from bs4 import BeautifulSoup

def crawl_mod(nm_id):
	# CONSTRUCT THE URL
	url = "http://www.nexusmods.com/skyrim/mods/" + nm_id
	
	# GET WEB PAGE
	print("HTTP GET \""+url+"\"")
	page = urllib.urlopen(url).read()
	print("SUCCESS: Recieved "+str(sys.getsizeof(page))+" Bytes\n")
	
	# PARSE PAGE
	print("PARSING STATS...")
	soup = BeautifulSoup(page, "html.parser")
	mainImage = soup.find(id="gallery-ul-0").li.a['href']
	name = soup.find("span", class_="header-name").text
	author = soup.find("span", class_="header-author").strong.text
	numEndorsements = soup.find(id="span_endors_number").text
	version = soup.find("p", class_="file-version").strong.text
	uniqueDownloads = soup.find("p", class_="file-unique-dls").strong.text
	totalDownloads = soup.find("p", class_="file-total-dls").strong.text
	totalViews = soup.find("p", class_="file-total-views").strong.text
	uploadedBy = soup.find("div", class_="uploader").a.text
	dates = soup.find("div", class_="header-dates")
	dateAdded = dates.contents[1].text.replace("Added: ", "")
	dateUpdated = dates.contents[3].text.replace("Updated: ", "")
	nexusCategory = soup.find("span", class_="header-cat").find_all("a")[1]['href'].split("src_cat=", 1)[1]
	isUtility = nexusCategory == "39"
	
	# tab stats
	numFiles = soup.find("a", class_="tab-files").strong.text.lstrip("0")
	numImages = soup.find("a", class_="tab-images").strong.text.lstrip("0")

	# attempt to get numArticles
	try:
		numArticles = soup.find("a", class_="tab-articles").strong.text.lstrip("0")
	except AttributeError:
		numArticles = "0"

	# attempt to get numPosts
	try:
		numPosts = soup.find("a", class_="tab-comments").strong.text.lstrip("0")
	except AttributeError:
		numPosts = "0"

	# attempt to get numForums
	try:
		numForums = soup.find("a", class_="tab-discussion").strong.text.lstrip("0")
	except AttributeError:
		numForums = "0"

	# attempt to get numVideos
	try:
		numVideos = soup.find("a", class_="tab-videos").strong.text.lstrip("0")
	except AttributeError:
		numVideos = "0"

	print("DONE.\n")

	# DOWNLOAD PRIMARY IMAGE
	urllib.urlretrieve(mainImage, nm_id + os.path.splitext(mainImage)[1])

	# PRINT STATS
	print("-- STATS -- ")
	print("ID: "+nm_id)
	print("Main image: "+mainImage)
	print("Mod Name: "+name)
	print("Author: "+author)
	print("Uploaded by: "+uploadedBy)
	print("Date Added: "+dateAdded)
	print("Date Updated: "+dateUpdated)
	print("Endorsements: "+numEndorsements)
	print("Version: "+version)
	print("Unique Downloads: "+uniqueDownloads)
	print("Total Downloads: "+totalDownloads)
	print("Views: "+totalViews)
	print("Articles Count: "+numArticles)
	print("Files Count: "+numFiles)
	print("Images Count: "+numImages)
	print("Posts Count: "+numPosts)
	print("Forums Count: "+numForums)
	print("Videos Count: "+numVideos)
	print("Nexus Category: "+nexusCategory);

	# EXPORT STATS FOR SEEDING
	output = open('./seeds.rb', 'a')
	output.write('Mod.create(\n')
	output.write('    name: "'+name+'",\n')
	output.write('    primary_category_id: Category.where(name: "").first.id,\n')
	output.write('    secondary_category_id: Category.where(name: "").first.id,\n')
	output.write('    is_utility: '+str(isUtility)+',\n')
	output.write('    has_adult_content: false,\n')
	output.write('    game_id: gameSkyrim.id\n')
	output.write(')\n\n')
	output.write('NexusInfo.create(\n')
	output.write('    nm_id: '+nm_id+',\n')
	output.write('    mod_id: Mod.last.id,\n')
	output.write('    uploaded_by: "'+uploadedBy+'",\n')
	output.write('    authors: "'+author+'",\n')
	output.write('    date_released: DateTime.strptime("'+dateAdded+'", nexusDateFormat),\n')
	output.write('    date_updated: DateTime.strptime("'+dateUpdated+'", nexusDateFormat),\n')
	output.write('    endorsements: '+numEndorsements.replace(',', '')+',\n')
	output.write('    total_downloads: '+totalDownloads.replace(',', '')+',\n')
	output.write('    unique_downloads: '+uniqueDownloads.replace(',', '')+',\n')
	output.write('    views: '+totalViews.replace(',', '')+',\n')
	output.write('    posts_count: '+numPosts+',\n')
	output.write('    videos_count: '+numVideos+',\n')
	output.write('    images_count: '+numImages+',\n')
	output.write('    files_count: '+numFiles+',\n')
	output.write('    articles_count: '+numArticles+',\n')
	output.write('    nexus_category: '+nexusCategory+'\n')
	output.write(')\n\n')

	# close output
	output.close()

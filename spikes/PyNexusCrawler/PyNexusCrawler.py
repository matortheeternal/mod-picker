import urllib
import sys
import os
from bs4 import BeautifulSoup

# GET USER INPUT
nm_id = raw_input("Enter the Nexus Mod ID you want to crawl: ")
url = "http://www.nexusmods.com/skyrim/mods/" + nm_id

# GET WEB PAGE
print("HTTP GET \""+url+"\"")
page = urllib.urlopen(url).read()
print("SUCCESS: Recieved "+str(sys.getsizeof(page))+" Bytes\n")

# ANALYZE DATA
print("PARSING DATA...")
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
numArticles = soup.find("a", class_="tab-articles").strong.text.lstrip("0")
numFiles = soup.find("a", class_="tab-files").strong.text.lstrip("0")
numImages = soup.find("a", class_="tab-images").strong.text.lstrip("0")
numPosts = soup.find("a", class_="tab-comments").strong.text.lstrip("0")
numForums = soup.find("a", class_="tab-discussion").strong.text.lstrip("0")
numVideos = soup.find("a", class_="tab-videos").strong.text.lstrip("0")
print("DONE.\n")

# DOWNLOAD MAIN IMAGE
urllib.urlretrieve(mainImage, nm_id + os.path.splitext(mainImage)[1])

# PRINT DATA
print("-- DATA -- ")
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
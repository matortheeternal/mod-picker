import sys
import PyNexusZipCrawler

# GET NEXUS MODS MOD ID FROM USER INPUT
f_id = raw_input("Enter the Nexus Mods File ID you want to crawl: ")

# CRAWL IT
PyNexusZipCrawler.crawl_zip_content(f_id, "110")

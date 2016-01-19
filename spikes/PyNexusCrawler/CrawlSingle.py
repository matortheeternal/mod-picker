import sys
import PyNexusCrawler

# GET NEXUS MODS MOD ID FROM USER INPUT
nm_id = raw_input("Enter the Nexus Mod ID you want to crawl: ")

# CRAWL IT
PyNexusCrawler.crawl_mod(nm_id)

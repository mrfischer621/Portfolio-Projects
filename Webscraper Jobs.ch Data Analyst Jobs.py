from selenium import webdriver
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import random
import time

joblist = []

def getjobs(page):
    '''
    DOCSTRING

    This function iterates trough all pages from the defines URL and append it to a joblist CSV.

    Parameters:
    page = Pagenumber for the URL, defined by the function "getpages"

    '''
    headers = {'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"}
    url = f"https://www.jobs.ch/en/vacancies/?page={page}&term=Data%20Analyst"
    proxies = {
  'http': 'http://10.10.1.10:3128'
}
    time.sleep(random.randint(2,15))
    r = requests.get(url, headers = headers, proxies = proxies)
    soup = BeautifulSoup(r.content, "html.parser")
    divs = soup.find_all('article', class_ = 'Div-sc-1cpunnt-0')
    entries_div = soup.find('span', class_ = 'Span-sc-1ybanni-0 Text__span-sc-1lu7urs-8 Text-sc-1lu7urs-9 kWokWp hMRSTW')   

    for item in divs:
        jobtitle = item.find('a')['title']
        publish_date = item.find('span', class_ = 'Span-sc-1ybanni-0 Text__span-sc-1lu7urs-8 Text-sc-1lu7urs-9 kpMMjn jkVlZH').text
        company_workplace = item.find_all('span', class_ = 'Span-sc-1ybanni-0 Text__span-sc-1lu7urs-8 Text-sc-1lu7urs-9 cwfjTS eubypz')
        company = company_workplace[0].text
        workplace = company_workplace[-1].text

        job = {
            'jobtitle' : jobtitle,
            'company' : company,
            'workplace' : workplace,
            'published' : publish_date
            }
        joblist.append(job)

def getpages():
    '''
    DOCSTRING

    This function defines the iterations and pages for the function "getjobs".
    It calculateds the amount of pages automatically. It just scrapps in the jobs.ch Title 
    the amount ob jobs and divides it trough 20, because there are 20 entries per page

    Parameters:
    none

    Start with this function to start the scrapper
    
    '''
    headers = {'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"}
    url = f"https://www.jobs.ch/en/vacancies/?page=1&term=Data%20Analyst"
    r = requests.get(url, headers)
    soup = BeautifulSoup(r.content, "html.parser")
    divs = soup.find_all('article', class_ = 'Div-sc-1cpunnt-0')
    entries_div = soup.find('span', class_ = 'Span-sc-1ybanni-0 Text__span-sc-1lu7urs-8 Text-sc-1lu7urs-9 kWokWp hMRSTW')
    entries_page = int(20)
    entries_txt = entries_div.find('span')['title']
    entries_total = [int(s) for s in entries_txt.split() if s.isdigit()]
    pages_total = int(np.ceil(entries_total[0] / entries_page) + 1)

    for i in range(1,pages_total):
        print(f'Getting page, {i}') #Check at which page the program is right now
        getjobs(i)
    
    return 

getpages()

df = pd.DataFrame(joblist)
df.to_csv('jobs_dataanalyst.csv')

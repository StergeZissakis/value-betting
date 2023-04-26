import time
from  PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from datetime import datetime, date, timedelta
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition
import SoccerStatsRow


def process_results_page(db, browser, page):
    pass



if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    ##browser = Browser()

    url = "https://www.oddsportal.com/football/greece/super-league/results/" # current year
    ##page = browser.get(url)
    # Click I Accept
    ##browser.accept_cookies("//button[text()='I Accept']")
    # Process the 1st page
    ##process_results_page(db, browser, page)

    # Process all years to 1999
    tmp_years = []
    for year in range(-2021, -2006):
        tmp_years.append(str(year))
    
    years = []
    i = 0
    for year in range(-2022, -2007):
        years.append((tmp_years[i], str(year)))
        i += 1

    for year_from, year_to in years:
        url = "https://www.oddsportal.com/football/greece/super-league" + year_from + year_to + "/results/"
        print(str(year_from) + str(year_to) + " " + url)
        ##page = browser.get(url)
        page = None
        ##process_results_page(db, browser, page)

    ##if browser.headless:
        ##browser.quit()

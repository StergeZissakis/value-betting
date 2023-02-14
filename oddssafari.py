import re
import time
import pprint
from  PGConnector import PGConnector
from Browser import Browser
from datetime import datetime
from collections import OrderedDict
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition

def process_over_under_tab(browser, page, tab_button):
    browser.move_to_element_and_left_click(tab_button)
    browser.sleep_for_millis_random(100)

    page = browser.reset_page_to_current()

    event_dates = page.find_elements(By.XPATH, '//div[@id="__next"]/div[2]/main/div[2]/div[3]/div[contains(@class, "league_date")]')
    event_tables = page.find_elements(By.XPATH, '//div*[@id="__next"]/div[2]/main/div[2]/div[3]/div[contains(@class, "eventTable_eventsTable")]')
    print(len(event_tables))
    print(len(event_dates))
    if len(event_dates) != len(event_tables):
        print("Event Datesa and Tables mismatch: [" + len(event_dates) + "] VS [" + len(event_tables) + "]")
    for i in range(0, len(event_dates)):
        event_date = event_date[i].get_attrbiute('innerHTML')

        event_table = event_table[i];
        event_time = event_table.find_element(By.XPATH, "/div[3]/div[1]/div[1]/a/div[1]").get_attribute('innerHTML')
        event_match = event_table.find_element(By.XPATH, "/div[3]/div[1]/div[1]/a/div[2]").get_attribute('innerHTML')

        tmp_date = datetime.strptime(event_date, "%A %d/%m")
        days_diff = tmp_date - datetime.datetime.today()
        print("day_diff=" + day_diff)
        event_date_with_year = datetime.today() + datetime.timedelta(days=days_diff) # to get the year! 
        print(event_date_with_year)
        



    
    

def process_Greek_Super_League_OverUnder(db, browser, page):
    browser.sleep_for_millis_random(500)

    #Find soccer
    soccer_link = page.find_element(By.XPATH, '//div/div[2]/aside[1]/div[2]/div/ul/li/button/span[text()="Soccer"]')
    browser.scroll_move_left_click(soccer_link)
    browser.sleep_for_millis_random(500)

    #Find Countries A-Z
    az = page.find_element(By.XPATH, '//div/div[2]/aside[1]/div[2]/div/ul/li/ul/li/button[text()="Countries A-Z"]')
    browser.move_to_element_and_left_click(az)
    browser.sleep_for_millis_random(400)

    #Find Greece
    greece_country_button = page.find_element(By.XPATH,   '//div/div[2]/aside[1]/div[2]/div/ul/li/ul/li/ul/li/button[text()="Greece"]')
    browser.scroll_move_left_click(greece_country_button) 
    browser.sleep_for_millis_random(300)

    #Find Super League
    greece_country_li = greece_country_button.find_element(By.XPATH, '..')
    super_league_a = greece_country_li.find_element(By.XPATH, '//ul/li/a[contains(text(), "Super League")]')
    browser.scroll_move_left_click(super_league_a)
    browser.sleep_for_millis_random(500)

    page = browser.reset_page_to_current()
    over_under_tab_buttons_xpath = '/html/body/div[2]/div[2]/main/div[2]/div[2]/button[contains(text(), "Ο/U")]'
    
    browser.wait_for_element_to_appear(over_under_tab_buttons_xpath)
    over_under_tab_buttons = page.find_elements(By.XPATH, over_under_tab_buttons_xpath)
    for tab_button in over_under_tab_buttons:
        process_over_under_tab(browser, page, tab_button)

if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        exit(-1)

    browser = Browser()
    page = browser.get("https://www.oddssafari.gr/en")
    
    # Click I Accept
    browser.accept_cookies('//div[@id="qc-cmp2-ui"]/div[2]/div/button[@mode="primary"]/span[text()="AGREE"]') 
    # //*[@id="qc-cmp2-ui"]/div[2]/div/button[3]
    process_Greek_Super_League_OverUnder(db, browser, page)


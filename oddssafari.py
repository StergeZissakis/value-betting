import re
import time
import pprint
from Browser import Browser
from PGConnector import PGConnector
from collections import OrderedDict
from dateutil.relativedelta import relativedelta
from datetime import datetime, date, time, timedelta
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition

def calculate_event_date(event_date):
    if event_date is None:
        return None

    today = datetime.today()

    tmp_date = datetime.strptime(event_date, "%A %d/%m")
    tmp_date = tmp_date.replace(year=today.year)
    if tmp_date < today - relativedelta(months=1): # in case of new year ahead
        tmp_date = tmp_date.replace(year=today.year + 1)

    return tmp_date

def add_time_to_date(event_date, event_time):
    (hour, minute) = str(event_time).split(":")
    return event_date.replace(hour=hour, minute=minute)

def find_max_bookie(page, max_odds, '//div[@id="__next"]/div[2]/main/div[2]/div[4]/div[2]/div/div[2]/ul'):
    ret = []
    
    

    return ret

def process_over_under_match(browser, page, match_id, event_date_time, click_element):

    # Click and wait for 'Full Time' to appear
    tab_buttons_panel_xapth = '//*[@id="__next"]/div[2]/main/div[2]/div[3]'
    browser.move_to_element_and_left_click(click_element, tab_buttons_panel_xapth)
    browser.sleep_for_millis_random(450)
    page = browser.page
    
    tab_buttons = page.find_elements(By.XPATH, '//*[@id="__next"]/div[2]/main/div[2]/div[3]/button')
    group_rows_xpath = '//*[@id="__next"]/div[2]/main/div[2]/div[4]/div[contains(@class, "groups_alternateViewCtn")]'

    for tab_button in tab_buttons:
        half = tab_button.text
        scroll_move_left_click(tab_button, group_rows_xpath) 
        page = browser.page
        browser.sleep_for_millis_random(350)

        groups = page.find_elements(By.XPATH, group_rows_xpath)
        for group in groups:
            group_bookies_ul_xpath = '//div[@id="__next"]/div[2]/main/div[2]/div[4]/div[2]/div/div[2]/ul'
            scroll_move_left_click(group, group_bookies_ul_xpath) 
            goal_container = group.find_element(By.XPATH, './div[contains(@class, "groups_goalCtn")]')

            goals = goal_container.find_element(By.XPATH, './div[contains(@class, "groups_goalItem")]').get_attribute('innerHTML').strip()

            max_over  = goal_container.find_element(By.XPATH, './div[3]').get_attribute('innerHTML').strip()
            max_under = goal_container.find_element(By.XPATH, './div[4]').get_attribute('innerHTML').strip()
            payout    = goal_container.find_element(By.XPATH, './div[5]/text()[1]').get_attribute('innerHTML').strip()
            
            max_over_bet_links = find_max_bookie(page, group, max_over)

        


    





    goals = event_table.find_element(By.XPATH, "./div[3]/div[1]/div[1]/div[contains(@class, 'eventTable_col')]").get_attribute('innerHTML').strip()
    print("Goals: " + goals) 

    over = event_table.find_element(By.XPATH, "./div[3]/div[1]/div[2]/a/div[2]").get_attribute('innerHTML').strip()
    

def process_over_under_tab(browser, page, tab_button):
    browser.move_to_element_and_left_click(tab_button)
    browser.sleep_for_millis_random(100)

    page = browser.reset_page_to_current()

    event_dates = page.find_elements(By.XPATH, '//div[@id="__next"]/div[2]/main/div[2]/div[3]/div[contains(@class, "league_date")]')
    event_tables = page.find_elements(By.XPATH, '//div[@id="__next"]/div[2]/main/div[2]/div[3]/div[contains(@class, "eventTable_eventsTable")]')
    if len(event_dates) != len(event_tables):
        print("Event Datesa and Tables mismatch: [" + len(event_dates) + "] VS [" + len(event_tables) + "]")
    for i in range(0, len(event_dates)):
        event_date = calculate_event_date(event_dates[i].get_attribute('innerHTML'))

        event_table = event_tables[i];

        event_time = event_table.find_element(By.XPATH, "./div[3]/div[1]/div[1]/a/div[1]").get_attribute('innerHTML')
        event_date_time = add_time_to_date(event_date, event_time) 
        print("DateTime: " + event_date_time)

        event_match_element = event_table.find_element(By.XPATH, "./div[3]/div[1]/div[1]/a/div[2]")
        event_match = event_match_element.get_attribute('innerHTML')
        (home_team, guest_team) = event_match.split('-').strip()
        print(home_team + "-VS-" + guest_team)

        match_id = db.insert_or_update_match('OddsSafariMatch', home_team, guest_team, event_date_time)
        print("Match ID: " + match_id)

        process_over_under_match(browser, page, match_id, event_date_time, event_match_element)
        


        

        
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


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

def find_max_bookie(max_over, max_under, ul_element):
    ret = { 'over': [], 'under': [] }

    lis = ul_element.find_elements(By.XPATH, './li[contains(@class, "bets_row")]')
    for li in lis:
        try:
            over_bet_link = li.find_element(By.XPATH, './a[1]').get_attribute('href').strip()
        except:
            continue # not all rows have links
        over = li.find_element(By.XPATH, './a[2]/div/span').get_attribute('innerHTML').strip()
        under_bet_link = li.find_element(By.XPATH, './a[3]').get_attribute('href').strip()
        under = li.find_element(By.XPATH, './a[3]/div/span').get_attribute('innerHTML').strip()

        if over >= max_over:
            ret['over'].append(over_bet_link)
        if under >= max_under:
            ret['under'].append(under_bet_link)

    return ret

def process_over_under_match(browser, db, match_id, event_date_time, click_element):

    # Click and wait for 'Full Time' to appear
    tab_buttons_panel_xapth = '//*[@id="__next"]/div[2]/main/div[2]/div[3]'
    browser.move_to_element_and_middle_click(click_element) #, tab_buttons_panel_xapth)
    browser.sleep_for_millis_random(450)
    page = browser.switch_to_tab(1, wait_for_elelemt_xpath = tab_buttons_panel_xapth)
    
    tab_buttons = page.find_elements(By.XPATH, '//*[@id="__next"]/div[2]/main/div[2]/div[3]/button')
    group_rows_xpath = '//*[@id="__next"]/div[2]/main/div[2]/div[4]/div[contains(@class, "groups_alternateViewCtn")]'
       
    for tab_button in tab_buttons:
        half = tab_button.text.strip()
        if half == "Full time":
            half = "Full Time"
        browser.scroll_move_left_click(tab_button, group_rows_xpath) 
        browser.sleep_for_millis_random(500)

        groups = page.find_elements(By.XPATH, group_rows_xpath)
        for group in groups:
            browser.scroll_move_left_click(group)
            browser.sleep_for_seconds_random(2)

            goal_container = group.find_element(By.XPATH, './a/div[contains(@class, "groups_goalCtn")]')

            goals = goal_container.find_element(By.XPATH, './div[contains(@class, "groups_goalItem")]').get_attribute('innerHTML').strip()

            max_over  = goal_container.find_element(By.XPATH, './div[3]').get_attribute('innerHTML').strip()
            max_under = goal_container.find_element(By.XPATH, './div[4]').get_attribute('innerHTML').strip()
            payout    = goal_container.find_element(By.XPATH, './div[5]').get_attribute('innerHTML').strip()

            ul_bookies = group.find_element(By.XPATH, './div/div[2]/ul[contains(@class, "bets_rowCnt")]')
            bet_links = find_max_bookie(max_over, max_under, ul_bookies )
            db.insert_or_update_over('OddsSafariOverUnder', match_id, half, goals, max_over, bet_links['over'], payout, sql_checked = False)
            db.insert_or_update_under('OddsSafariOverUnder', match_id, half, goals, max_under, bet_links['under'], payout, sql_checked = False)
            break;
       
    browser.driver.close()
    browser.page = browser.switch_to_tab(0)


def process_over_under_events(browser, page, db, tab_button):
    browser.move_to_element_and_left_click(tab_button)
    browser.sleep_for_millis_random(100)

    for event_table in page.find_elements(By.XPATH, '//div[@id="__next"]/div[2]/main/div[2]/div[3]/div[contains(@class, "eventTable_eventsTable")]'): 
        event_date = event_table.find_element(By.XPATH, './div/div').text.split('\n')[0]
        for event_table_row in event_table.find_elements(By.XPATH, './div[3]/div[contains(@class, "eventTable_row")]'):
            year_event_date = calculate_event_date(event_date)

            browser.sleep_for_seconds_random(2)
            event_time = event_table_row.find_element(By.XPATH, './div/a/div[contains(@class, "eventTable_date")]').get_attribute('innerHTML')
            event_date_time = browser.add_time_to_date(year_event_date, event_time) 

            event_match_element = event_table_row.find_element(By.XPATH, './div/a/div[contains(@class, "eventTable_name")]')
            event_match = event_match_element.get_attribute('innerHTML')
            (home_team, guest_team) = event_match.split('-')
    
            match_id = db.insert_or_update_match('OddsSafariMatch', home_team.strip(), guest_team.strip(), str(event_date_time))

            process_over_under_match(browser, db, match_id, event_date_time, event_match_element)
            browser.sleep_for_seconds_random(2)
    

def process_Greek_Super_League_OverUnder(db, browser, page):
    browser.sleep_for_millis_random(700)

    #Find soccer
    soccer_link = page.find_element(By.XPATH, '//div/div[2]/aside[1]/div[2]/div/ul/li/button/span[text()="Soccer"]')
    browser.scroll_move_left_click(soccer_link)
    browser.sleep_for_millis_random(600)

    #Find Countries A-Z
    az = page.find_element(By.XPATH, '//div/div[2]/aside[1]/div[2]/div/ul/li/ul/li/button[text()="Countries A-Z"]')
    browser.move_to_element_and_left_click(az)
    browser.sleep_for_millis_random(500)

    #Find Greece
    greece_country_button = page.find_element(By.XPATH,   '//div/div[2]/aside[1]/div[2]/div/ul/li/ul/li/ul/li/button[text()="Greece"]')
    browser.scroll_move_left_click(greece_country_button) 
    browser.sleep_for_seconds_random(2)

    #Find Super League
    greece_country_li = greece_country_button.find_element(By.XPATH, '..')
    super_league_a = greece_country_li.find_element(By.XPATH, '//ul/li/a[contains(text(), "Super League")]')
    browser.scroll_move_left_click(super_league_a)
    browser.sleep_for_millis_random(1000)

    page = browser.reset_page_to_current()
    over_under_tab_buttons_xpath = '/html/body/div[2]/div[2]/main/div[2]/div[2]/button[contains(text(), "Ο/U")]'
    
    browser.wait_for_element_to_appear(over_under_tab_buttons_xpath)
    over_under_tab_buttons = page.find_elements(By.XPATH, over_under_tab_buttons_xpath)
    over_under_tab_button = over_under_tab_buttons[0]
    process_over_under_events(browser, page, db, over_under_tab_button)

if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        exit(-1)

    browser = Browser()
    page = browser.get("https://www.oddssafari.gr/en")
    
    # Click I Accept
    browser.accept_cookies('//div[@id="qc-cmp2-ui"]/div[2]/div/button[@mode="primary"]/span[text()="AGREE"]') 
    process_Greek_Super_League_OverUnder(db, browser, page)


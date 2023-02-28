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

def extract_common_event_details(browser):
    tab = browser.driver

    event = OrderedDict()

    event['home_team']  = tab.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]/div[1]/div/div[1]/p').text
    event['guest_team'] = tab.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]/div[3]/div[1]/p').text
    event_date_time = tab.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[2]/div[1]/div[2]').text

    (str_dat, str_date, str_time) = [part.strip() for part in event_date_time.split(',')]
    date_time = datetime.strptime(str_date + " " + str_time, "%d %b %Y %H:%M")
    event['date_time'] = str(date_time)

    return event

def process_over_under_tab(browser, half, db):
    tab = browser.driver
    event = extract_common_event_details(browser)
    
    match_id = db.insert_or_update_match('OddsPortalMatch', event['home_team'], event['guest_team'], event['date_time'])
    if match_id is None:
        print("Failed to insert match data.")
        return

    event['half'] = half
    event['goals'] = []

    rows = tab.find_elements(By.XPATH,     '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[@set="0"]')
    for row in rows:
        str_goals = row.find_element(By.XPATH, './div/div[2]/p[1]').text
        over_under_goal = float(str_goals.split(' ')[-1])
        over = row.find_element(By.XPATH,  './div/div[3]/div[1]/button/p').text
        under = row.find_element(By.XPATH, './div/div[3]/div[2]/button/p').text
        probability = row.find_element(By.XPATH, './div/div[3]/div[3]/button/p').text
        bet_links = []
        event['goals'].append([over_under_goal, over, under, probability, bet_links])

    db.insert_or_update_over_under('OddsPortalOverUnder', match_id, half, event['goals'])

def process_over_under_values(browser, page, div_set):
    event_div = div_set.find_elements(By.XPATH, './div')[-1]
    event_inner_div = event_div.find_elements(By.XPATH, './div')[0]
            
    event_a = event_inner_div.find_elements(By.XPATH, './a')[0]
    browser.move_to_element_and_left_click(event_a)
    
    over_under = page.find_element(By.XPATH, "//li[contains(@class, 'odds-item')]//span[@class='flex']//div[contains(text(), 'Over/Under')]")
    browser.move_to_element_and_left_click(over_under, '//div[@set="0"]')

    ou_full_time = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[1]')
    ou_1st_half = page.find_element(By.XPATH,  '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[2]')
    ou_2nd_half = page.find_element(By.XPATH,  '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[3]')

    browser.sleep_for_seconds_random(2)

    browser.move_to_element_and_left_click(ou_full_time, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[@set="0"]')
    process_over_under_tab(browser,ou_full_time.text, db) 
    browser.move_to_element_and_left_click(ou_1st_half, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[@set="0"]')
    process_over_under_tab(browser, ou_1st_half.text, db)
    browser.move_to_element_and_left_click(ou_2nd_half, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[@set="0"]')
    process_over_under_tab(browser, ou_2nd_half.text, db)

def process_Greek_Super_League_OverUnder(db, browser, page):
    #Find soccer
    soccer_link = page.find_element(By.XPATH, "//p[text()='soccer']")
    browser.scroll_to_visible(soccer_link)
    browser.move_to_element_and_left_click(soccer_link)

    #Find Greece
    browser.sleep_for_millis(400)
    greece_link = page.find_element(By.XPATH, "//h2[text()='Greece']")
    browser.scroll_to_visible(greece_link)
    browser.move_to_element_and_left_click(greece_link)

    # get Greece li children links (h3)
    greece_ul = greece_link.find_element(By.XPATH, "//ul[@class='sub_1_83']")

    greece_super_league = greece_ul.find_elements(By.XPATH, "//h3[contains(text(),'Super League')]")

    # Variable to store the id by which elems will be sought within the tab, based on div's set= attrib
    set_ids = []

    #Visit all 'Super League' links under Greece
    total_tabs = 0
    for link in greece_super_league:
        set_ids.append(re.findall(r'^\d+', link.get_attribute("id"))[0])
        total_tabs += 1
        browser.move_to_element_and_middle_click(link);
        break # Do not process the 2nd class League

    #Process tabs
    for tab in range(0, total_tabs):
        #print('Processing tab [' + str(set_ids[tab]) + ']')
        #Ensure the tab has been loaded
        div_set_xpath = '//div/div/div[@set="' + str(set_ids[tab]) + '"]'
        page = browser.switch_to_tab(tab + 1, div_set_xpath)
        # Get all the matches
        div_sets = page.find_elements(By.XPATH, div_set_xpath)
        num_div_sets = len(div_sets)
        for counter in range(0, num_div_sets):
            div_set = div_sets[counter]
            try: # some matches do not have odds set yet
                process_over_under_values(browser, page, div_set)
            except:
                pass
            browser.go_back(4)
            browser.sleep_for_seconds_random(2)
            page = browser.page
            div_sets = page.find_elements(By.XPATH, div_set_xpath)

if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        exit(-1)

    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")
    process_Greek_Super_League_OverUnder(db, browser, page)

    if browser.headless:
        browser.close()

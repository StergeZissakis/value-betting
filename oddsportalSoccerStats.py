import time
from datetime import datetime, date, timedelta
from PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition
from SoccerStatsRow import SoccerStatsRow
from OddsPortal import get_section_kind, get_event_date, get_event_time


def process_header(browser, page, data):

    browser.wait_for_element_to_appear('.//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[1]/p')

    data.set('home_team'   , page.find_element(By.XPATH, './/*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[1]/p').text)
    data.set('guest_team'  , page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[3]/div[1]/p').text)
    data.set('date_time'   , page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[1]/div[2]').text)
    data.set('date_time'   , datetime.strptime(data.get('date_time'), "%A, %d %b %Y, %H:%M"))
    data.set('goals_home'  , page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[2]/div').text)
    data.set('goals_guest' , page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[3]/div[2]/div').text)

    half_goals = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[3]/div[2]').text.split('\n')[2].strip()
    first_half_goals, second_half_goals = half_goals.split(',')
    frist_half_goals = first_half_goals[1:].strip()
    second_half_goals = second_half_goals[1:-1].strip()
    data.set('first_half_goals_home'   , first_half_goals.split(':')[0])
    data.set('first_half_goals_guest'  , first_half_goals.split(':')[1])
    data.set('second_half_goals_home'  , second_half_goals.split(':')[0])
    data.set('second_half_goals_guest' , second_half_goals.split(':')[1])

    print(data)

def process_1x2(browser, page, data):
    pass

def process_OverUnder(browser, page, data):
    pass

def process_Section(browser, page, section, kind):
    data = SoccerStatsRow()

    link = None

    if kind == "Match":
        link = section.find_element(By.XPATH,   './div/div/a');
    elif kind == "DateRow":
        link = section.find_element(By.XPATH,   './div[2]/div/a')
    elif kind == "TopHeader":
        link = section.find_element(By.XPATH,   './div[3]/div/a')

    browser.move_to_element_and_middle_click(link)
    browser.switch_to_tab(1)
    tab_page = browser.page
    process_header(browser, tab_page, data)
    process_1x2(browser, tab_page, data)
    process_OverUnder(browser, tab_page, data)
    browser.close_tab()

    return data

def process_results_page(db, browser, page):
    container_div = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]')
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')

    event_date = None
    for section in section_divs:
        kind = get_section_kind(section)
        if kind is not None:
            browser.sleep_for_millis_random(300)
            row = process_Section(browser, page, section, kind)
            db.insert_or_update_1x2_odds(row)


if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    browser = Browser()

    url = "https://www.oddsportal.com/football/greece/super-league/results/" # current year
    page = browser.get(url)
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")
    # Process the 1st page
    process_results_page(db, browser, page)

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
        page = browser.get(url)
        process_results_page(db, browser, page)

    if browser.headless:
        browser.quit()

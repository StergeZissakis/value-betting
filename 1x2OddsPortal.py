import time
from  PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from datetime import datetime, date, timedelta

def get_section_kind(section_div):
    try:
        div = section_div.find_element(By.XPATH, './div/div/div')
        if div.text.startswith("Yesterday"):
            return 'Yesterday'
    except:
        pass

    try:
        div = section_div.find_element(By.XPATH, './div[2]/div/div')
        if div.text.startswith("Today"):
            return 'Today'
    except:
        pass

    try:
        div = section_div.find_element(By.XPATH, './div/div/div')
        if div.text.startswith("Tomorrow"):
            return 'Tomorrow'
        datetime.strptime(div.text, "%d %b %Y")
        return "Date"
    except:
        pass

    try:
        div = section_div.find_element(By.XPATH, './div/div/a/div/div/p')
        (left, right) = div.text.split(":")
        if len(left) != 2 and len(right) != 2:
            raise None
        else:
            return "Match"
    except:
        pass

    return None
    


def get_event_date(section_div, event_date, kind):
    if kind == "Yesterday":
        return datetime.today() - timedelta(days=1)
    elif kind == "Today":
        return datetime.today()
    elif kind == "Tomorrow":
        return datetime.today() + timedelta(days=1)
    elif kind ==  "Date":
        div = section_div.find_element(By.XPATH, './div/div/div')
        return datetime.strptime(div.text, "%d %b %Y")
    else:
        return event_date

def get_event_time(section_div, kind):
    if kind == "Yesterday":
        div = section_div.find_element(By.XPATH, './div[3]/div/a/div/div/p')
    elif kind  == "Today":
        div = section_div.find_element(By.XPATH, './div[3]/div/a/div/div/p')
    elif kind in ("Tomorrow", "Date"):
        div = section_div.find_element(By.XPATH, './div[2]/div/a/div/div/p')
    elif kind == "Match":
        div = section_div.find_element(By.XPATH, './div/div/a/div/div/p')
    else:
        return None

    return div.text

def max_array(array):
    if len(array):
        return max(array)
    return []

def scrape_odds_table(browser, page):
    odds = {"1_odds": [], "x_odds": [], "2_odds": []} # will work out the maximu of all 
    odds_container = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[1]/div[1]')
    divs = odds_container.find_elements(By.XPATH, './*')
    print("divs: " + str(len(divs)))
    for div in divs:
        try:
            div.find_element(By.XPATH, './div[1]/a[2]/p') # skip sections with no links
        except:
            continue

        one = div.find_element(By.XPATH, './div[2]/div[1]/div[1]/p').text
        print(one)
        if len(one):
            odds["1_odds"].append(one)

        x = div.find_element(By.XPATH,   './div[3]/div[1]/div[1]/p').text
        print(x)
        if len(x):
            odds["x_odds"].append(x)

        two = div.find_element(By.XPATH, './div[4]/div/div/p').text
        print(two)
        if len(two):
            odds["2_odds"].append(two)

    return {"1_odds": max_array(odds["1_odds"]), "x_odds": max_array(odds["x_odds"]), "2_odds": max_array(odds["2_odds"])}


def click_and_collect_1x2_odds(browser, section, kind):
    if kind == "Today":
        clickable_xpath = './div[3]/div[1]/a[1]' 
    elif kind == "Date":
        clickable_xpath = './div[2]/div[1]/a[1]'
    elif kind == "Match":
        clickable_xpath = './div[1]/div[1]/a[1]'
    else:
        return {}


    browser.move_to_element_and_middle_click(section.find_element(By.XPATH, clickable_xpath)) #,  '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[3]')
    browser.sleep_for_millis_random(300)
    page = browser.switch_to_tab(1, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[3]')

    links = ["Full Time", "1st Half", "2nd Half"]
    odds = {"Full Time": [], "1st Half": [], "2nd Half": []}

    for i in range(0, len(links)):
        half = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[' + str(i + 1) + ']')
        browser.move_to_element_and_left_click(half, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[6]/div[1]/div')
        browser.sleep_for_millis_random(400)
        max_odds = scrape_odds_table(browser, browser.page)
        odds[links[i]].append(max_odds)

    browser.close_tab()
    return odds


def scrape_1x2(db, browser, page):
    container_div = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[7]/div[1]')
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')

    event_date = None
    for section in section_divs:
        kind = get_section_kind(section)
        if kind is not None:
            if kind == "Yesterday":
                continue

            browser.scroll_to_visible(section)
            browser.sleep_for_millis_random(300)
            event_date = get_event_date(section, event_date, kind) 


            event_time = get_event_time(section, kind)
            event_date_time = browser.add_time_to_date(event_date, event_time)

            if kind == "Today":
                home_team = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/a[1]/div[1]').text
                guest_team = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/a[2]/div[1]').text
            if kind in ("Tomorrow", "Date"):
                print(event_date_time)
                home_team = section.find_element(By.XPATH,  './div[2]/div/a/div[2]/div/a[1]/div[1]').text
                guest_team = section.find_element(By.XPATH, './div[2]/div/a/div[2]/div/a[2]/div[1]').text
            elif kind == "Match":
                home_team = section.find_element(By.XPATH,  './div/div/a/div[2]/div/a[1]/div[1]').text
                guest_team = section.find_element(By.XPATH, './div/div/a/div[2]/div/a[2]/div[1]').text

            #click in and get all the details
            odds = click_and_collect_1x2_odds(browser, section, kind)
            db.insert_or_update_1x2_odds("1x2_oddsportal", event_date_time, home_team, guest_team, odds)

if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    browser = Browser(headless = False)
    page = browser.get("https://www.oddsportal.com/soccer/greece/super-league/")
    
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")

    scrape_1x2(db, browser, page)

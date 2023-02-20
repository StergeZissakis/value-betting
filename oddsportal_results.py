import time
from  PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from datetime import datetime, date, timedelta

def get_section_kind(section_div):
    try:
        div = section_div.find_element(By.XPATH, './div[2]/div/div')
        if div.text.startswith("Today"):
            return 'Today'
    except:
        pass

    try:
        div = section_div.find_element(By.XPATH, './div/div/div')
        if div.text.startswith("Yesterday"):
            return 'Yesterday'
    except:
        pass

    try:
        div = section_div.find_element(By.XPATH, './div/div/div')
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
    if kind == "Today":
        return datetime.today()
    elif kind == "Yesterday":
        return datetime.today() - timedelta(days=1)
    elif kind ==  "Date":
        div = section_div.find_element(By.XPATH, './div/div/div')
        return datetime.strptime(div.text, "%d %b %Y")
    else:
        return event_date

def get_event_time(section_div, kind):
    if kind  == "Today":
        div = section_div.find_element(By.XPATH, './div[3]/div/a/div/div/p')
    elif kind == "Yesterday":
        div = section_div.find_element(By.XPATH, './div[2]/div/a/div/div/p')
    elif kind == "Date":
        div = section_div.find_element(By.XPATH, './div[2]/div/a/div/div/p')
    elif kind == "Match":
        div = section_div.find_element(By.XPATH, './div/div/a/div/div/p')
    else:
        return None

    return div.text


def process_results(db, browser, page):
    container_div = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[7]/div[1]')
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]');
    if len(section_divs):
        event_date = None
        for section in section_divs:
            browser.move_to_element_and_scroll_to_visible_bottom(section)
            browser.sleep_for_millis_random(1200)

            kind = get_section_kind(section)
            print(kind)
            if kind is not None:
                event_date = get_event_date(section, event_date, kind) 
                event_time = get_event_time(section, kind)
                event_date_time = browser.add_time_to_date(event_date, event_time)
                print(event_date_time)


if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        exit(-1)

    browser = Browser()
    page = browser.get("https://www.oddsportal.com/soccer/greece/super-league/results/#/page/1/")
    
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")

    process_results(db, browser, page)

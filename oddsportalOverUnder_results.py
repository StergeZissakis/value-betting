import time
from  PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from datetime import datetime, date, timedelta

def count_children_divs(section_div):
    return len(section_div.find_elements(By.XPATH, './div'))

def get_section_kind(section_div):
    num_children_divs = count_children_divs(section_div)

    if num_children_divs == 1:
        return "Match"
    elif num_children_divs == 2:
        return "DateRow"
    elif num_children_divs == 3:
        return "TopHeader"

    return None
    
def get_event_date(section_div, event_date, kind):
    if kind == "TopHeader":
        date = section_div.find_element(By.XPATH, './div[2]/div[1]/div').text
        if date == 'Today':
            return datetime.today()
        elif date == 'Yesterday':
            return datetime.today() - timedelta(days=1)
        elif datetime.strptime(date, "%d %b %Y"):
            return datetime.strptime(date, "%d %b %Y")
    elif kind ==  "DateRow":
        date = section_div.find_element(By.XPATH, './div/div/div').text
        if datetime.strptime(date, "%d %b %Y"):
            return datetime.strptime(date, "%d %b %Y")

    return event_date

def get_event_time(section_div, kind):
    if kind  == "TopHeader":
        div = section_div.find_element(By.XPATH, './div[3]/div/a/div[1]/div/div/p')
    elif kind == "DateRow":
        try:
            div = section_div.find_element(By.XPATH, './div[2]/div/a/div/div/p')
        except:
            div = section_div.find_element(By.XPATH, './div[3]/div/a/div[1]/div/div/p')
    elif kind == "Match":
        div = section_div.find_element(By.XPATH, './div/div/a/div[1]/div/div/p')
    else:
        return None

    return div.text

def click_and_collect_over_under_details(browser, section, kind):
    if kind  == "TopHeader" or kind == "DateRow":
        clickable_xpath = './div[3]/div/a/div[2]/div/div/a[1]'
    elif kind == "Match":
        clickable_xpath = './div/div/a'
    else:
        return ()

    browser.move_to_element_and_middle_click(section.find_element(By.XPATH, clickable_xpath)) #, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[2]/div[3]/div[2]/span')
    browser.sleep_for_millis_random(300)
    page = browser.switch_to_tab(1)

    half_goals = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[3]/div[2]').text.strip()
    half_goals = half_goals.replace('(','').replace(')','').split('\n')[-1].strip()
    (half_1, half_2) = half_goals.split(',')
    half_1 = half_1.strip()
    half_2 = half_2.strip()
    page = browser.close_tab()
    return (half_1, half_2)

def process_results(db, browser, page):
    container_div = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]')
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')
    browser.scroll_to_bottom()
    browser.scroll_to_visible(section_divs[0])

    event_date = None
    num_sections = len(section_divs)
    processed_sections = 0;
    print("Num:" + str(num_sections))
    print("Prc:" + str(processed_sections))
    while processed_sections <= num_sections:
        for section in section_divs:
            kind = get_section_kind(section)
            print(kind)
            if kind is not None:
                browser.scroll_to_visible(section)
                browser.sleep_for_millis_random(300)
                event_date = get_event_date(section, event_date, kind) 

                event_time = get_event_time(section, kind)
                event_date_time = browser.add_time_to_date(event_date, event_time)
                if kind == "TopHeader":
                    home_team = section.find_element(By.XPATH,   './div[3]/div/a/div[2]/div/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/div/a[2]/div[1]').text
                    home_goals = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/div/div/div/div[1]').text
                    guest_goals = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/div/div/div/div[3]').text
                elif kind == "DateRow":
                    try:
                        home_team = section.find_element(By.XPATH,  './div[2]/div/a/div[2]/div/a[1]/div[1]').text
                        guest_team = section.find_element(By.XPATH, './div[2]/div/a/div[2]/div/a[2]/div[1]').text
                        (home_goals, guest_goals) = section.find_element(By.XPATH, './div[2]/div/div[1]/div').text.split(':')
                    except:
                        home_team = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/div/a[1]/div[1]').text
                        guest_team = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/div/a[2]/div[1]').text
                        home_goals = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/div/div/div/div[1]').text
                        guest_goals = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/div/div/div/div[3]').text
                elif kind == "Match":
                    home_team = section.find_element(By.XPATH,  './div/div/a/div[2]/div/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH, './div/div/a/div[2]/div/div/a[2]/div[1]').text
                    home_goals = section.find_element(By.XPATH, './div/div/a/div[2]/div/div/div/div/div[1]').text
                    guest_goals = section.find_element(By.XPATH,'./div/div/a/div[2]/div/div/div/div/div[1]').text
                #click in and get more details
                halfs = click_and_collect_over_under_details(browser, section, kind)
                #print(str(event_date_time) + "->" + home_team + "_VS_" + guest_team + "=" + str(home_goals) + ":" + str(guest_goals))
                db.update_historical_results_over_under("OverUnderHistorical", event_date_time, home_team, guest_team, home_goals, guest_goals, halfs[0], halfs[1])


        section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')
        processed_sections += num_sections
        section_divs = section_divs[processed_sections:-1]
        num_sections += len(section_divs)
        print("Num:" + str(num_sections))
        print("Prc:" + str(processed_sections))

if __name__ == "__main__":
    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    browser = Browser()
    page = browser.get("https://www.oddsportal.com/football/greece/super-league/results/#/page/1/")
    
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")

    process_results(db, browser, page)

    if browser.headless:
        browser.close()
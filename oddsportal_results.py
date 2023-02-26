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
        div = section_div.find_element(By.XPATH, './div[3]/div/a/div/div/p')
    elif kind == "Date":
        div = section_div.find_element(By.XPATH, './div[2]/div/a/div/div/p')
    elif kind == "Match":
        div = section_div.find_element(By.XPATH, './div/div/a/div/div/p')
    else:
        return None

    return div.text

def click_and_collect_over_under_details(browser, section, kind):
    if kind == "Yesterday":
        clickable_xpath = './div[3]/div/a'
        #clickable_xpath = './div[3]/div/a/div[2]/div/a[1]/'
    elif kind == "Date":
        clickable_xpath = './div[2]/div/a'
        #clickable_xpath = './div[2]/div/a/div[2]/div/a[2]'
    elif kind == "Match":
        clickable_xpath = './div/div/a'
        #clickable_xpath = './div/div/a/div[2]/div/a[1]'
    else:
        return ()

    browser.move_to_element_and_middle_click(section.find_element(By.XPATH, clickable_xpath)) #, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[2]/div[3]/div[2]/span')
    browser.sleep_for_millis_random(300)
    page = browser.switch_to_tab(1)

    half_goals = page.find_element(By.XPATH, '//div[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[2]/div[3]/div[2]').text
    half_goals = half_goals.replace('(','').replace(')','').split('\n')[-1].strip()
    (half_1, half_2) = half_goals.split(',')
    half_1 = half_1.strip()
    half_2 = half_2.strip()
    page = browser.close_tab()
    return (half_1, half_2)

def process_results(db, browser, page):
    container_div = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[7]/div[1]')
    #load all the content
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')
    browser.scroll_to_bottom()
    browser.scroll_to_visible(section_divs[0])

    # and then hit it!
    section_divs = container_div.find_elements(By.XPATH, './div[@set="65147"]')
    event_date = None
    num_sections = len(section_divs)
    processed_sections = 0;
    print("Num:" + str(num_sections))
    print("Prc:" + str(processed_sections))
    yesterday_found = False
    while processed_sections <= num_sections:
        for section in section_divs:

            kind = get_section_kind(section)
            if kind is not None:
                browser.scroll_to_visible(section)
                browser.sleep_for_millis_random(300)
                event_date = get_event_date(section, event_date, kind) 

                if kind == "Date" and not yesterday_found:
                    kind = "Yesterday"
                    yesterday_found = True
                elif not yesterday_found and kind == "Yesterday":
                    yesterday_found = True

                event_time = get_event_time(section, kind)
                event_date_time = browser.add_time_to_date(event_date, event_time)
                if kind == "Today":
                    print("#TODO: Today")
                elif kind == "Yesterday":
                    home_team = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/a[2]/div[1]').text
                    (home_goals, guest_goals) = section.find_element(By.XPATH, './div[3]/div/div[1]/div').text.split(':')
                elif kind == "Date":
                    home_team = section.find_element(By.XPATH,  './div[2]/div/a/div[2]/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH, './div[2]/div/a/div[2]/div/a[2]/div[1]').text
                    (home_goals, guest_goals) = section.find_element(By.XPATH, './div[2]/div/div[1]/div').text.split(':')
                elif kind == "Match":
                    home_team = section.find_element(By.XPATH,  './div/div/a/div[2]/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH, './div/div/a/div[2]/div/a[2]/div[1]').text
                    (home_goals, guest_goals) = section.find_element(By.XPATH, './div/div/div[1]/div').text.split(':')
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

    headless = False
    browser = Browser(headless)
    page = browser.get("https://www.oddsportal.com/soccer/greece/super-league/results/#/page/1/")
    
    # Click I Accept
    browser.accept_cookies("//button[text()='I Accept']")

    process_results(db, browser, page)

    if headless:
        browser.close()

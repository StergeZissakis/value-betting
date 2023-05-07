import time
from  PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from datetime import datetime, date, timedelta
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition
from OddsPortal import get_section_kind, get_event_date, get_event_time

def click_and_collect_over_under_details(browser, section, kind):
    if kind == "Match":
        clickable_xpath = './div/div/a'
    elif kind == "DateRow":
        clickable_xpath = './div[2]/div/a/div[2]/div/div/a[1]/div[1]'
    elif kind  == "TopHeader":
        clickable_xpath = './div[3]/div/a/div[2]/div/div/a[1]'
    else:
        return ()

    browser.move_to_element_and_middle_click(section.find_element(By.XPATH, clickable_xpath))
    browser.sleep_for_millis_random(400)
    page = browser.switch_to_tab(1)

    final_result = WebDriverWait(browser.driver, 5).until(ExpectedCondition.presence_of_element_located((By.XPATH, "//*[@id='app']/div/div[1]/div/main/div[2]/div[3]/div[2]/div[3]/div[2]/span[contains(text(),'result')]")))
    final_result_parent = final_result.find_element(By.XPATH, '..')
    goals = final_result_parent.text.strip()
    half_goals = goals.split('\n')[-1].replace('(','').replace(')','').strip()
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
                if kind == "Match":
                    home_team = section.find_element(By.XPATH,   './div/div/a/div[2]/div/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH,  './div/div/a/div[2]/div/div/a[2]/div[1]').text
                    home_goals = section.find_element(By.XPATH,  './div/div/a/div[2]/div/div/div/div/div[1]').text
                    guest_goals = section.find_element(By.XPATH, './div/div/a/div[2]/div/div/div/div/div[1]').text
                elif kind == "DateRow":
                    home_team = section.find_element(By.XPATH,   './div[2]/div/a/div[2]/div/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH,  './div[2]/div/a/div[2]/div/div/a[2]/div[1]').text
                    home_goals = section.find_element(By.XPATH,  './div[2]/div/a/div[2]/div/div/div/div/div[1]').text
                    guest_goals = section.find_element(By.XPATH, './div[2]/div/a/div[2]/div/div/div/div/div[3]').text
                elif kind == "TopHeader":
                    home_team = section.find_element(By.XPATH,   './div[3]/div/a/div[2]/div/div/a[1]/div[1]').text
                    guest_team = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/div/a[2]/div[1]').text
                    home_goals = section.find_element(By.XPATH,  './div[3]/div/a/div[2]/div/div/div/div/div[1]').text
                    guest_goals = section.find_element(By.XPATH, './div[3]/div/a/div[2]/div/div/div/div/div[3]').text
                #click in and get more details
                scores = click_and_collect_over_under_details(browser, section, kind)
                print(str(event_date_time) + "->" + home_team + "_VS_" + guest_team + "=" + str(home_goals) + ":" + str(guest_goals))
                db.update_historical_results_over_under("OverUnderHistorical", event_date_time, home_team, guest_team, home_goals, guest_goals, scores[0], scores[1])


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
        browser.quit()

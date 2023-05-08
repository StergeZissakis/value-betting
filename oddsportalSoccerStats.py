import time
import argparse
from dateutil.parser import parse, ParserError
from datetime import datetime, date, timedelta
from PGConnector import PGConnector
from Browser import Browser
from collections import OrderedDict
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition
from SoccerStatsRow import SoccerStatsRow
from OddsPortal import get_section_kind, get_event_date, get_event_time

def date_to_datetime(date):
    dt = date
    if str(dt).startswith('Yesterday'):
        yesterday = datetime.now() - timedelta(1)
        yesterday_day = yesterday.strftime('%A')
        dt = dt.replace('Yesterday', yesterday_day)
    elif str(dt).startswith('Today'):
        today = datetime.now()
        today_day = today.strftime('%A')
        dt = dt.replace('Today', today_day)
    return datetime.strptime(dt, "%A, %d %b %Y, %H:%M")


def process_header(browser, page, data):

    browser.wait_for_element_to_appear('.//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[1]/p')

    browser.sleep_for_millis_random(400)

    data.set('home_team'   , page.find_element(By.XPATH, './/*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[1]/p').text)
    data.set('guest_team'  , page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[3]/div[1]/p').text)
    data.set('date_time'   , date_to_datetime(page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[1]/div[2]').text))
    print(str(data.get('date_time')) + " " + str(data.get('home_team')) + " VS " + str(data.get('guest_team')))
    data.set('goals_home'  , int(page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[1]/div/div[2]/div').text))
    data.set('goals_guest' , int(page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[1]/div[3]/div[2]/div').text))

    browser.wait_for_element_to_appear('//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[3]/div[2]')
    half_goals = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[2]/div[3]/div[2]').text.split('\n')[2].strip()
    first_half_goals, second_half_goals = half_goals.split(',')
    frist_half_goals = first_half_goals[1:].strip()
    second_half_goals = second_half_goals[1:-1].strip()
    data.set('first_half_goals_home'   , int(first_half_goals.split(':')[0][1:]))
    data.set('first_half_goals_guest'  , int(first_half_goals.split(':')[1]))
    data.set('second_half_goals_home'  , int(second_half_goals.split(':')[0]))
    data.set('second_half_goals_guest' , int(second_half_goals.split(':')[1]))

    data.set('url', browser.driver.current_url)

def get_max_values_from_1x2_table(browser, page):
    table_root = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div')
    rows = table_root.find_elements(By.XPATH, './div[@class = "flex text-xs border-b h-9 border-l border-r"]')
    
    one_odds = []
    x_odds   = []
    two_odds = []
    for row in rows:
        try:
            val = row.find_element(By.XPATH, './div[2]/div/div/p[@class="height-content" and @class!="line-through"]').text
            if val != '-':
                one_odds.append(float(val))
            else:
                one_odds.append(None)
            val = row.find_element(By.XPATH,   './div[3]/div/div/p[@class="height-content" and @class!="line-through"]').text
            if val != '-':
                x_odds.append(float(val))
            else:
                x_odds.append(None)
            val = row.find_element(By.XPATH, './div[4]/div/div/p[@class="height-content" and @class!="line-through"]').text
            if val != '-':
                two_odds.append(float(val))
            else:
                two_odds.append(None)
        except:
            pass
                
    if isinstance(one_odds, list) and len(one_odds):
        ret_one = max(one_odds)
    else:
        ret_one = None
    if isinstance(x_odds, list) and len(x_odds): 
        ret_x   = max(x_odds)
    else:
        ret_x   = None
    if isinstance(two_odds, list) and len(two_odds):
        ret_two = max(two_odds)
    else:
        ret_two = None
    return (ret_one, ret_x, ret_two)


def process_1x2(browser, page, data):
    # 1x2 Full Time
    one_odds, x_odds, two_odds = get_max_values_from_1x2_table(browser, page)
    data.set('full_time_home_win_odds',  one_odds)
    data.set('full_time_draw_odds',      x_odds)
    data.set('full_time_guest_win_odds', two_odds)

    # 1x2 1st Half
    first_half_button = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[5]/div[2]')
    browser.move_to_element_and_left_click(first_half_button, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div/div[1]/div[1]/span/p')

    one_odds, x_odds, two_odds = get_max_values_from_1x2_table(browser, page)
    data.set('first_half_home_win_odds',  one_odds)
    data.set('first_half_draw_odds',      x_odds)
    data.set('first_half_guest_win_odds', two_odds)

    
    # 1x2 2nd Half
    second_half_button = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[5]/div[3]')
    browser.move_to_element_and_left_click(second_half_button, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div/div[1]/div[1]/span/p')

    one_odds, x_odds, two_odds = get_max_values_from_1x2_table(browser, page)
    data.set('second_half_home_win_odds',  one_odds)
    data.set('second_half_draw_odds',      x_odds)
    data.set('second_half_guest_win_odds', two_odds)

def get_values_from_overunder_table(browser, page):
    table_root = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]')
    rows = table_root.find_elements(By.XPATH, './div[@set = "0"]')
    
    goals = []
    over  = []
    under = []
    for row in rows:
        try:
            goals.append(float(row.find_element(By.XPATH, './div/div[2]/p[1]').text.split(' +')[1]))
            over.append(float(row.find_element(By.XPATH,  './div/div[3]/div[1]/div[1]/div/p').text))
            under.append(float(row.find_element(By.XPATH, './div/div[3]/div[2]/div[1]/div/p').text))
        except:
            continue

    return (goals, over, under)


def process_OverUnder(browser, page, data):
    # Over/Under Full Time
    over_under_button = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[4]/div/div/div/ul/li[2]/span/div')
    browser.move_to_element_and_left_click(over_under_button, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div')
        
    goals = []
    over  = []
    under = []
    goals, over, under = get_values_from_overunder_table(browser, page)
    data.set('full_time_over_under_goals',  goals)
    data.set('full_time_over_odds',      over)
    data.set('full_time_under_odds', under)

    # Over/Under 1st Half
    first_half_over_under_button = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[5]/div[2]')
    browser.move_to_element_and_left_click(first_half_over_under_button, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div')
        
    goals = []
    over  = []
    under = []
    goals, over, under = get_values_from_overunder_table(browser, page)
    data.set('first_half_over_under_goals',  goals)
    data.set('first_half_over_odds',      over)
    data.set('first_half_under_odds', under)

    # Over/Under 2nd Half
    seocnd_half_over_under_button = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[3]/div[5]/div[3]')
    browser.move_to_element_and_left_click(seocnd_half_over_under_button, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[4]/div[1]/div')
        
    goals = []
    over  = []
    under = []
    goals, over, under = get_values_from_overunder_table(browser, page)
    data.set('second_half_over_under_goals',  goals)
    data.set('second_half_over_odds',      over)
    data.set('second_half_under_odds', under)

def get_link_of_section(section, kind):
    link = None

    if kind == "Match":
        link = section.find_element(By.XPATH,   './div/div/a');
    elif kind == "DateRow":
        link = section.find_element(By.XPATH,   './div[2]/div/a')
    elif kind == "TopHeader":
        link = section.find_element(By.XPATH,   './div[3]/div/a')

    return link

def get_date_of_section(section, kind):
    if kind == "Match":
        return None
    elif kind == "DateRow":
        try:
            date = section.find_element(By.XPATH,   './div[1]/div[1]/div').text.split('-')[0].strip()
            return datetime.strptime(date, '%d %b %Y')
        except:
            return None
    elif kind == "TopHeader":
        try:
            date = section.find_element(By.XPATH,   './div[2]/div[1]/div').text.split('-')[0].strip()
            return datetime.strptime(date, '%d %b %Y')
        except:
            return None
    return None


def process_Section(browser, page, section, kind):
    data = SoccerStatsRow()

    link = get_link_of_section(section, kind)

    browser.move_to_element_and_middle_click(link)
    browser.switch_to_tab(1)
    tab_page = browser.page
    process_header(browser, tab_page, data)
    process_1x2(browser, tab_page, data)
    process_OverUnder(browser, tab_page, data)
    browser.close_tab()

    return data

start_date = None

def process_results_page(db, browser, page):

    page_number = 1
    next_page_button_xpath = '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[4]/div/div[3]/a[1]/div/p'
    next_page = True
    while(next_page):
        browser.scroll_to_bottom()
        browser.sleep_for_millis_random(300)
        container_div_xapth = '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]'
        container_div = page.find_element(By.XPATH, container_div_xapth )
        section_divs = container_div.find_elements(By.XPATH, './div[@set!=""]')
        print("Page: " + str(page_number) + " Total matches: " + str(len(section_divs)))
        for section in section_divs:
            browser.scroll_to_visible(section)
            kind = get_section_kind(section)
            if kind is not None:
                if start_date:
                    dt = get_date_of_section(section, kind)
                    print(str(start_date) + " > " + str(dt))
                    if dt == None or start_date < dt:
                        continue
                browser.sleep_for_millis_random(300)

                row = process_Section(browser, page, section, kind)
                db.insert_or_update_soccer_statistics(row)

        try:
            browser.scroll_to_bottom()
            browser.sleep_for_millis_random(300)
            next_page_button = page.find_element(By.XPATH, next_page_button_xpath) 
        except:
            next_page= False

        if next_page:
            browser.scroll_to_visible(next_page_button, True)
            table_header_xpath = '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[1]/div[1]/div[1]'
            browser.move_to_element_and_left_click(next_page_button, table_header_xpath)
            page = browser.driver
            browser.sleep_for_millis_random(350)
            browser.scroll_to_visible(page.find_element(By.XPATH, table_header_xpath))
        page_number = page_number + 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--headed", help='Headed mode', action=argparse.BooleanOptionalAction, default=False)
    date_lambda = lambda s: datetime.strptime(s, '%Y-%m-%d')
    parser.add_argument("--start-date", help='Start recording matches after this date', type=date_lambda, default=None, required=False)
    args = parser.parse_args()

    if args.start_date:
        start_date = args.start_date
        print(start_date)

    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    browser = Browser()
    ##url = "https://www.oddsportal.com/football/greece/super-league/results/" # current year
    ##page = browser.get(url)
    # Click I Accept
    ##browser.accept_cookies("//button[text()='I Accept']")
    # Process the 1st page
    ##process_results_page(db, browser, page)

    # Process all years to 1999
    tmp_years = []
    #for year in range(-2021, -2006):
    for year in range(-2020, -2006):
        tmp_years.append(str(year))
    
    years = []
    i = 0
    #for year in range(-2022, -2007):
    for year in range(-2021, -2007):
        years.append((tmp_years[i], str(year)))
        i += 1

    for year_from, year_to in years:
        url = "https://www.oddsportal.com/football/greece/super-league" + year_from + year_to + "/results/"
        print(str(year_from) + str(year_to) + " " + url)
        browser = Browser()
        page = browser.get(url)
        browser.sleep_for_seconds_random(3)
        browser.accept_cookies("//button[text()='I Accept']")
        process_results_page(db, browser, page)

    if browser.headless:
        browser.quit()

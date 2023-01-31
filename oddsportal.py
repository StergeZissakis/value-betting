import re
import time
from Browser import Browser
from selenium.webdriver.common.by import By



if __name__ == "__main__":
    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    # Click I Accept
    browser.accept_cookies("I Accept")

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
        browser.sleep_for_millis_random(1000)

    #Process tabs
    for tab in range(0, total_tabs):
        print('Processing tab [' + str(set_ids[tab]) + ']')
        page = browser.switch_to_tab(tab + 1)
        events = page.find_elements(By.XPATH, '//div[@set="' + str(set_ids[tab]) + '"]//a[last()]')
        for event in events:
            if event.get_attribute('innerHTML').strip().startswith("<"):
                browser.move_to_element_and_left_click(event)
                event_page = browser.driver
                over_under = event_page.find_element(By.XPATH, "//div[conatins(text(), 'Over/Under']");
                browser.move_to_element_and_left_click(event)
                
                break
                browser.back()


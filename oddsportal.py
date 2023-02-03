import re
import time
from Browser import Browser
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ExpectedCondition



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

    #Process tabs
    for tab in range(0, total_tabs):
        print('Processing tab [' + str(set_ids[tab]) + ']')

        #Ensure the tab has been loaded
        page = browser.switch_to_tab(tab + 1, '//div[@set="' + str(set_ids[tab]) + '"]') 
        # Get all the matches
        browser.sleep_for_seconds_random(3)
        div_sets = page.find_elements(By.XPATH, '//div[@set="' + str(set_ids[tab]) + '"]')
        for div_set in div_sets: 
            event_div = div_set.find_elements(By.XPATH, './div')[-1]
            event_inner_div = event_div.find_elements(By.XPATH, './div')[0]
            
            event_a = event_inner_div.find_elements(By.XPATH, './a')[0]
            browser.move_to_element_and_left_click(event_a)

            over_under = page.find_element(By.XPATH, "//li[contains(@class, 'odds-item')]//span[@class='flex']//div[contains(text(), 'Over/Under')]")
            browser.move_to_element_and_left_click(over_under, '//div[@set="0"]')

            ou_full_time = page.find_element(By.XPATH, '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[1]')
            ou_1st_half = page.find_element(By.XPATH,  '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[2]')
            ou_2nd_half = page.find_element(By.XPATH,  '//*[@id="app"]/div/div[1]/div/main/div[2]/div[5]/div[5]/div[3]')

            browser.sleep_for_seconds_random(5)

            browser.move_to_element_and_left_click(ou_full_time) #, wait_sync_element_xpath="//div//div[@set='0']")
            # Process Full Time
            browser.move_to_element_and_left_click(ou_1st_half) #, wait_sync_element_xpath="//div//div[@set='0']")
            # Process 1st Half
            browser.move_to_element_and_left_click(ou_2nd_half) #, wait_sync_element_xpath="//div//div[@set='0']")
            # Process 2nd Half

            break
            #browser.back()


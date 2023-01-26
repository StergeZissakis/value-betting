import time
from Browser import Browser
from selenium.webdriver.common.by import By

def process_odds_page(browser, link):
    browser.move_to_element_and_middle_click(link);
    browser.sleep_for_millis(1000)

def main():
    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    # Click I Accept
    browser.accept_cookies(page, "I Accept")

    #Find soccer
    soccer_link = page.find_element(By.XPATH, "//p[text()='soccer']")
    browser.scroll_to_visible(page, soccer_link)
    browser.move_to_element_and_left_click(soccer_link)

    #Find Greece
    browser.sleep_for_millis(400)
    greece_link = page.find_element(By.XPATH, "//h2[text()='Greece']")
    browser.scroll_to_visible(page, greece_link)
    browser.move_to_element_and_left_click(greece_link)

    # find Greece parent li
    greece_parent_li = page.find_element(By.XPATH, "//h2[text()='Greece']/ancestor::li[@class='country']")

    # get the datum data-v-xyz=""
    greece_li_html = greece_parent_li.get_attribute('innerHTML')
    data_start_index = greece_li_html.find('data-v-')
    data_end_index = greece_li_html.find('=', data_start_index)
    data_v_str = greece_li_html[data_start_index:data_end_index] 

    # get parent li id (contry code)
    greece_country_code = greece_parent_li.get_attribute('id')

    # get Greece li children links (h3)
    greece_li_children_links = greece_parent_li.find_elements(By.CSS_SELECTOR, 'h3[' + data_v_str + ']')

    print(greece_li_children_links)

    #Visit all links under Greece
    for p in greece_li_children_links:
        print(p)
        process_odds_page(browser, p)


if __name__ == "__main__":
    main()

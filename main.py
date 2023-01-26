import time
from Browser import Browser
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains

def sleep_for_millis(millis):
    time.sleep(millis / 1000)

def scroll_to_visible(page, element):
    page.execute_script("arguments[0].scrollIntoView({block: 'center', inline: 'nearest'});", element);
    sleep_for_millis(300)

def move_to_element(driver, element):
    ActionChains(driver).move_to_element(element).perform()
    sleep_for_millis(250)

def move_to_element_and_left_click(driver, element):
    move_to_element(driver, element)
    element.click()
    sleep_for_millis(150)

def middle_click(driver, element):
    driver.execute_script('var mouseWheelClick = new MouseEvent( "click", { "button": 2, "which": 2 }); document.getElementById("' + element.get_attribute('id') + '").dispatchEvent(mouseWheelClick)');
    sleep_for_millis(200)

def move_to_element_and_middle_click(driver, element):
    move_to_element(driver, element)
    middle_click(driver, element)

def accept_cookies(driver, page, button_text):
    button = page.find_element(By.XPATH, "//button[text()='" + button_text + "']")
    sleep_for_millis(200)
    move_to_element_and_left_click(driver, button)

def process_odds_page(driver, page, link):
    move_to_element_and_middle_click(driver, link);
    sleep_for_millis(1000)

def main():
    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    # Click I Accept
    accept_cookies(browser.driver, page, "I Accept")

    #Find soccer
    soccer_link = page.find_element(By.XPATH, "//p[text()='soccer']")
    scroll_to_visible(page, soccer_link)
    move_to_element_and_left_click(browser.driver, soccer_link)

    #Find Greece
    sleep_for_millis(400)
    greece_link = page.find_element(By.XPATH, "//h2[text()='Greece']")
    scroll_to_visible(page, greece_link)
    move_to_element_and_left_click(browser.driver, greece_link)

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

    #Visit all links under Greece
    for p in greece_li_children_links:
        process_odds_page(browser.driver, page, p)


if __name__ == "__main__":
    main()

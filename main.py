import time
from Browser import Browser
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains

def sleep_for_millis(millis):
    time.sleep(millis / 1000)

def scroll_to_visible(driver, element):
    #actions = ActionChains(driver)
    #actions.move_to_element(element).perform()
    driver.execute_script("arguments[0].scrollIntoView({block: 'center', inline: 'nearest'});", element);
    sleep_for_millis(300)

def accept_cookies(driver, button_text):
    button = driver.find_element(By.XPATH, "//button[text()='" + button_text + "']")
    button.click()
    sleep_for_millis(200)

def main():
    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    # Click I Accept
    accept_cookies(page, "I Accept")

    #Find soccer
    soccer_link = page.find_element(By.XPATH, "//p[text()='soccer']")
    scroll_to_visible(page, soccer_link)
    soccer_link.click()

    #Find Greece
    sleep_for_millis(400)
    greece_link = page.find_element(By.XPATH, "//h2[text()='Greece']")
    scroll_to_visible(page, greece_link)
    greece_link.click()

    # find Greece parent li
    greece_parent = page.find_element(By.XPATH, "//h2[text()='Greece']/ancestor::li[@class='country']")
    greece_li_html = greece_parent.get_attribute('innerHTML')
    data_start_index = greece_li_html.find('data-v-')
    data_end_index = greece_li_html.find('=', data_start_index)

    print(greece_li_html[data_start_index:data_end_index]) 

    #Visit all links under Greece


if __name__ == "__main__":
    main()

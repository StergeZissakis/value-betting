import time
from Browser import Browser
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains

def sleep_for_millis(millis):
    time.sleep(millis / 1000)

def scroll_to_visible(driver, element):
    #actions = ActionChains(driver)
    #actions.move_to_element(element).perform()
    driver.execute_script("arguments[0].scrollIntoView(true);", element);
    sleep_for_millis(300)

def accept_cookies(driver, button_text):
    button = driver.find_element(By.XPATH, "//button[text()='" + button_text + "']")
    button.click()
    sleep_for_millis(200)

def main():
    browser = Browser()
    page = browser.get("https://www.oddsportal.com/")
    
    accept_cookies(page, "I Accept")

    soccer_link = page.find_element(By.XPATH, "//p[text()='soccer']")
    scroll_to_visible(page, soccer_link)
    soccer_link.click()

    sleep_for_millis(400)
    greece_link = page.find_element(By.XPATH, "//h2[text()='Greece']")
    scroll_to_visible(page, greece_link)
    greece_link.click()

if __name__ == "__main__":
    main()

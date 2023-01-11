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

    #Visit all links under Greece
    ## Get all the attributes
    dataElement = None
    attribs = greece_link.get_property('attributes')[0].keys()
    for attrib in attribs:
        if attrib.startswith('data-v-'):
            dataElement=attrib
            break

    if dataElement:
        print(dataElement)

        top_href = greece_link.find_element_by_xpath('..').find_element_by_xpath('..') #find the top <a href
        print(top_href)

        ul = top_href.find_element_by_xpath('//a[@href]/ul[@' + dataElement + ']')
        print(ul)


if __name__ == "__main__":
    main()

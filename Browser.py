import os
import time
import pickle
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions as ExpectedCondition

class Browser:

    def __init__(self):
        self.chrome_options = Options()
        self.chrome_options.add_argument('no-sandbox')
        #self.chrome_options.add_argument('--window-size=1280,1024')
        self.chrome_options.add_argument('--start-maximized')
        self.chrome_options.add_argument('--disable-dev-shm-usage')
        self.chrome_options.add_argument('disable-gpu')
        #self.chrome_options.add_argument("--incognito")
        self.chrome_options.add_experimental_option("detach", True)
        self.chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
        #self.chrome_options.add_argument('--headless')

        self.driver = webdriver.Chrome(chrome_options=self.chrome_options)

        # Load cookies from previous session
        '''
        self.cookies_file = "./config/chrome.cookies.pkl"
        if(os.path.isfile(self.cookies_file)):
            cookies = pickle.load(open(self.cookies_file, "rb"))
            for cookie in cookies:
                self.driver.add_cookie(cookie)
        '''

    def __del__(self):
        # Save cookies for next session
        #pickle.dump(self.driver.get_cookies(), open(self.cookies_file, "wb"))
        pass

    def get(self, url):
        self.page = self.driver.get(url)
        return self.driver

    def reset_page_to_current(self):
        self.page = self.driver

    def element_completely_visible(self, elem):
        elem_left_bound = elem.location.get('x')
        elem_top_bound = elem.location.get('y')
        elem_width = elem.size.get('width')
        elem_height = elem.size.get('height')
        elem_right_bound = elem_left_bound + elem_width
        elem_lower_bound = elem_top_bound + elem_height

        win_upper_bound = self.driver.execute_script('return window.pageYOffset')
        win_left_bound = self.driver.execute_script('return window.pageXOffset')
        win_width = self.driver.execute_script('return document.documentElement.clientWidth')
        win_height = self.driver.execute_script('return document.documentElement.clientHeight')
        win_right_bound = win_left_bound + win_width
        win_lower_bound = win_upper_bound + win_height

        return all(
                   (    win_left_bound <= elem_left_bound,
                        win_right_bound >= elem_right_bound,
                        win_upper_bound <= elem_top_bound,
                        win_lower_bound >= elem_lower_bound
                   )
                  )


    def get_interactible_child(self, element):
        if element and element.is_displayed() and element.is_enabled():
            return element

        ret = None
        for child in element.find_elements(By.XPATH, "./*"):
            if child and child.is_displayed() and child.is_enabled():
                ret = child
                break

        return ret


    def get_interactible_parent(self, element, parent_limit_xpath = ""):
        if element and element.is_displayed() and element.is_enabled():
            return element

        parent_limit = None
        if len(parent_limit_xpath):
            parent_limit = element.find_element(By.XPATH, ".//ancestor::" + parent_limit_xpath)

        parent = element.find_element(By.XPATH, "..")
        if parent_limit and parent == parent_limit:
            return parent

        while parent and not (parent.is_displayed() and parent.is_enabled()):
            parent = parent.find_element(By.XPATH, "..")
            if parent_limit and parent == parent_limit:
                return parent

        if parent and parent.is_displayed() and parent.is_enabled():
            return parent
        elif parent_limit:
            return parent_limit
        else:
            return None

    def get_interactible(self, element, parent_limit_xpath = ""):
        if element and element.is_displayed() and element.is_enabled():
            return element

        ret = self.get_interactible_child(element)
        if ret is None:
            ret = self.get_interactible_parent(element, parent_limit_xpath)

        return ret

    def sleep_for_millis(self, millis):
        time.sleep(millis / 1000)

    def sleep_for_millis_random(self, limit):
        if limit > 100:
            self.sleep_for_millis(random.randint(100, limit))
        else:
            self.sleep_for_millis(random.randint(100, 1000))

    def sleep_for_seconds(self, seconds):
        time.sleep(seconds)
        
    def sleep_for_seconds_random(self, limit):
        if limit > 1:
            self.sleep_for_seconds(random.randint(1, limit))
        else:
            self.sleep_for_seconds(random.randint(1, 3))

    def scroll_to_visible(self, element):
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        self.sleep_for_millis_random(400)

    def move_to_element(self, element):
        if(self.element_completely_visible(element) and element.is_displayed()):
            ActionChains(self.driver).move_to_element(element).perform()
        self.sleep_for_millis_random(300)

    def move_to_element_and_left_click(self, element, wait_sync_element_xpath = "", parent_limit_xpath = ""):
        self.move_to_element(element)
        clickable = self.get_interactible(element, parent_limit_xpath)
        if clickable:
            try:
                clickable.click()
            except :
                ActionChains(self.driver).move_to_element(clickable).click(clickable).perform()

            self.sleep_for_millis_random(150)
            if len(wait_sync_element_xpath):
                try:
                    element = WebDriverWait(self.driver, 5).until(ExpectedCondition.presence_of_element_located((By.XPATH, wait_sync_element_xpath)))
                except:
                    element = None
                return element

        return clickable


    def middle_click(self, element):
        self.move_to_element(element)
        clickable = self.get_interactible(element)
        if clickable:
            ActionChains(self.driver).key_down(Keys.CONTROL).click(clickable).key_up(Keys.CONTROL).perform()
            self.sleep_for_millis_random(200)

    def move_to_element_and_middle_click(self, element):
        self.move_to_element(element)
        clickable = self.get_interactible(element)
        if clickable:
            self.middle_click(clickable)

    def accept_cookies(self, button_text):
        button = self.driver.find_element(By.XPATH, "//button[text()='" + button_text + "']")
        if button:
            self.sleep_for_millis_random(200)
            self.move_to_element_and_left_click(button)


    def switch_to_tab(self, tab_index, expectedXPath, timeout = 10):
        self.driver.switch_to.window(self.driver.window_handles[tab_index])
        self.page = self.driver
        return self.page


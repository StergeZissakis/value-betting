from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

class Browser:

    def __init__(self):
        self.chrome_options = Options()
        self.chrome_options.add_argument('no-sandbox')
        #self.chrome_options.add_argument('--window-size=1280,1024')
        self.chrome_options.add_argument('--start-maximized')
        self.chrome_options.add_argument('--disable-dev-shm-usage')
        self.chrome_options.add_argument('disable-gpu')
        #self.chrome_options.add_argument('--headless')

        self.driver = webdriver.Chrome(chrome_options=self.chrome_options)
    

    def get(self, url):
        self.page = self.driver.get(url)
        return self.driver

    def moveMouseTo(self, x, y):
        pass

    def scrollToVisible():
        pass



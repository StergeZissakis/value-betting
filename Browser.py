import pickle
import time
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

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
        #'''
        self.cookies_file = "./config/chrome.cookies.pkl"
        if(os.path.isfile(self.cookies_file)):
            cookies = pickle.load(open(self.cookies_file, "rb"))
            for cookie in cookies:
                self.driver.add_cookie(cookie)
        #'''

    def __del__(self):
        # Save cookies for next session
        pickle.dump(self.driver.get_cookies(), open(self.cookies_file, "wb"))

    def get(self, url):
        self.page = self.driver.get(url)
        return self.driver

    def moveMouseTo(self, x, y):
        pass

    def scrollToVisible():
        pass



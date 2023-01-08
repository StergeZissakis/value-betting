from Browser import Browser

def main():
    browser = Browser()
    page = browser.get("https://www.google.com/")
    print(page.title)

if __name__ == "__main__":
    main()

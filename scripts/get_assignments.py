#!/home/arjun/myConky/.venv/bin/python3
import sys
import os
from dotenv import load_dotenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.chrome.service import Service

load_dotenv()


usernameStr = "20BCE1029"
passwordStr = os.environ.get("PASSWORD")
options = webdriver.ChromeOptions()
options.binary_location = "/usr/bin/chromium"
options.add_argument("--headless")
options.add_argument("--disable-gpu")

browser = webdriver.Chrome(service=Service("/usr/bin/chromedriver"), options=options)
browser.get("https://lms.vit.ac.in/login/index.php")

username = browser.find_element(By.ID, "username")
password = browser.find_element(By.ID, "password")
username.send_keys(usernameStr)
password.send_keys(passwordStr)
browser.find_element(By.ID, "loginbtn").click()

xpath = "//*[starts-with(@id, 'month-upcoming-mini')]"
loaded_assignments = WebDriverWait(browser, 10).until(
    EC.presence_of_element_located((By.XPATH, xpath))
)

assignment = browser.find_element(By.XPATH, xpath)
child_elements = assignment.find_elements(By.XPATH, ".//*")


text_assignments = assignment.text
text_assignments = list(text_assignments)
text_assignments = "".join(text_assignments)
text_assignments = text_assignments.split("\n")
assignments_list = []
if text_assignments == ["There are no upcoming events"]:
    print("${color2}" + "No Assignments Due YAAAAY!" + "${color}")
    browser.close()
    sys.exit(0)
for i in range(0, len(text_assignments), 2):
    cur_assignment_title = text_assignments[i][: len(text_assignments[i]) - 8]
    cur_assignment_due_date = text_assignments[i + 1]
    assignments_list.append(
        {"title": cur_assignment_title, "due": cur_assignment_due_date}
    )

for assignment in assignments_list:
    print(assignment["title"], "\t", "${color2}" + assignment["due"] + "${color}")

browser.close()

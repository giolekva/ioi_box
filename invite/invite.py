#!/usr/local/bin/python3.9

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import time
import sys


MAIL_SUBJECT = 'GEOI-2021 დასკვნითი ტური - მომხმარებლის ინფორმაცია'

MAIL_CONTENT_TMPL = '''გამარჯობა {participant},

ქვემოთ იხილეთ GEOI-2021 დასკვნითი ტურის მომხმარებლის ინფორმაცია:

მისამართი: https://cms.geoi.ge
Username: {username}
Password: {password}

დასკვნითი ტური ჩატარდება 24 და 25 აპრილს. მთავარი შეჯიბრი დაიწყება დილის 10 საათზე, ხოლო ნახევარი საათით ადრე 9:30-ზე ჩაირთვება სატესტო გარემო.
სრული ინფორმაციისთვის ეწვიეთ შეჯიბრების საიტს: https://www.geoi.ge

ავტორიზაციასთან პრობლემების შემთხვევაში მიპასუხეთ ამ წერილზე.

გისურვებთ წარმატებებს!

--
გიორგი ლეკვეიშვილი
'''

SENDER_ADDRESS = 'giolekva@gmail.com'
SENDER_PASS = 'uenpivraomirhslh'


class User:
    def __init__(self, row):
        items = row.split(',')
        self.first_name = items[0]
        self.last_name = items[1]
        self.username = items[2]
        self.password = items[3]
        self.email = items[4]


def sendTo(user, session):
    message = MIMEMultipart()
    message['From'] = SENDER_ADDRESS
    message['To'] = user.email
    message['Subject'] = MAIL_SUBJECT
    mail_content = MAIL_CONTENT_TMPL.format(
        participant=user.first_name.strip(" *"),
        username=user.username,
        password=user.password)
    message.attach(MIMEText(mail_content, 'plain'))
    text = message.as_string()
    # session.sendmail(SENDER_ADDRESS, "giolekva@gmail.com", text)
    session.sendmail(SENDER_ADDRESS, user.email, text)
    print('Mail sent to %s' % user.email)


def main():
    session = smtplib.SMTP('smtp.gmail.com', 587)
    session.starttls()
    session.login(SENDER_ADDRESS, SENDER_PASS)
    num_sent = 0
    with open(sys.argv[1]) as inp:
        for line in inp:
            user = User(line[:-1])
            try:
                sendTo(user, session)
                num_sent += 1
                time.sleep(2)
            except:
                print('Sent %d and failed' % num_sent)
                return
    print('Sent %d' % num_sent)
    session.quit()


if __name__ == '__main__':
    main()

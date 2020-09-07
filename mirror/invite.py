from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import time


MAIL_SUBJECT = 'EJOI2020 Mirror Competition Info'

MAIL_CONTENT_TMPL = '''Hello {participant},

We are inviting you to participate in EJOI2020 (https://www.ejoi2020.ge) mirror ccompetition, which will be held on September 6th and 7th starting at 17:00 GMT+4.
Each day competition will be four hours long.
Below you can find an information on how to login into the system:

Where to login: https://cms.ejoi2020.ge
Username: {username}
Password: {password}

In case you have questions regarding competition website or your login credentials please email me at giolekva@gmail.com
You can use these same credentials on both days.

Thank you for participating and good luck!

--
Giorgi Lekveishvili
Chair of Host Technical Committee
'''

SENDER_ADDRESS = 'giolekva@gmail.com'
SENDER_PASS = ''


class User:
    def __init__(self, row):
        items = row.split(',')
        self.full_name = items[0]
        self.username = items[2]
        self.password = items[3]
        self.email = items[4]


def sendTo(user, session):
    message = MIMEMultipart()
    message['From'] = SENDER_ADDRESS
    message['To'] = user.email
    message['Subject'] = MAIL_SUBJECT
    mail_content = MAIL_CONTENT_TMPL.format(
        participant=user.full_name,
        username=user.username,
        password=user.password)
    message.attach(MIMEText(mail_content, 'plain'))
    text = message.as_string()
    session.sendmail(SENDER_ADDRESS, user.email, text)
    print('Mail sent to %s' % user.email)

    
def main():
    session = smtplib.SMTP('smtp.gmail.com', 587)
    session.starttls()
    session.login(SENDER_ADDRESS, SENDER_PASS)
    num_sent = 0
    with open('users.csv') as inp:
        for line in inp:
            user = User(line[:-1])
            try:
                sendTo(user, session)
                num_sent += 1
                time.sleep(1)
            except:
                print('Sent %d and failed' % num_sent)
                return
    print('Sent %d' % num_sent)
    session.quit()


if __name__ == '__main__':
    main()

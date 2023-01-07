from random import randint, choice, random

import secrets
import string

from datetime import datetime as datetime
from datetime import timedelta


def random_ts(min_year=2015, max_year=datetime.now().year - 1):
    # generate a datetime in format yyyy-mm-dd hh:mm:ss.000000+03
    start = datetime(min_year, 1, 1, 00, 00, 00)
    years = max_year - min_year + 1
    end = start + timedelta(days=365 * years)
    return str(start + (end - start) * random()) + '+03'


def generate_alphanum_crypt_string(length):
    letters_and_digits = string.ascii_letters + string.digits
    crypt_rand_string = ''.join(secrets.choice(
        letters_and_digits) for i in range(length))
    return crypt_rand_string


path_installations_file = "/home/anna/Desktop/prak5/installations.txt"
path_users_file = "/home/anna/Desktop/prak5/users.txt"
path_products_file = "/home/anna/Desktop/prak5/products.txt"

N_users = 10**6
N_installations = 10**7
programming_products = set([generate_alphanum_crypt_string(10) for i in range(500)])
programming_products.update(['University', 'School'])
programming_products = list(programming_products)
operating_systems = ["Windows", "Ubuntu", "Fedora", "Manjaro", "Android", "IOS", "IpadOS",
                     "ArchLinux", "IpodOS"]
text = """ В 2007 году закончил с отличием киевский Национальный Университет Технологии и Дизайна.
Работает на должности маркетолога с октября 2007 года.
За время работы проявил себя как квалифицированный специалист.
Является настоящим профессионалом, умело руководит вверенным ему направлением, пользуется заслуженным уважением среди сотрудников.
Он постоянно повышает свой профессиональный уровень: посещает тематические мероприятия, тренинги и семинары, читает специализированную литературу, ответственно и серьезно относиться к выполнению должностных обязанностей.
Руководство компании выделяет постоянное стремление к профессиональному развитию: в настоящее время он получает дополнительное профессиональное образование по специальности «управление персоналом».
За добросовестное отношение к работе награжден грамотой «Лучший сотрудник 2008».
В общении с коллегами дружелюбен и внимателен.
За время работы внедрил конкретные предложения, которые оказали благотворное влияние на деятельность компании.
Характеристика выдана для представления по месту требования."""

characteristics = text.split('.\n')
# print(characteristics)
# exit(0)

with open("/home/anna/Desktop/prak5/names_surnames.txt", 'r') as f:
    names_surnames = [i.split(' ') for i in f]

product_classes = ['application', 'system_software', 'programming_tool']
with open(path_products_file, 'w') as products:
    for i in range(1, len(programming_products) + 1):
        products.write(f'{i}|{programming_products[i - 1]}|{choice(product_classes)}\n')

user_product = {}
user_installation = {i: 0 for i in range(1, N_users + 1)}
with open(path_installations_file, 'w') as installations:
    with open(path_users_file, 'w') as users:
        for i in range(1, N_installations + 1):
            installation_updating_dates = [random_ts(2015, 2021) for i in range(randint(1, 10))]
            installation_updating_dates.sort()
            install_date = '{' + installation_updating_dates[0]
            for j in installation_updating_dates:
                if j != installation_updating_dates[0]:
                    install_date += ','
                    install_date += j
            install_date += '}'
            programming_product_num = randint(1, len(programming_products) - 1)
            programming_product = programming_products[programming_product_num]
            operating_system = choice(operating_systems)
            #license_key = generate_alphanum_crypt_string(6)
            price_for_license = 100 + random() * 1000
            user_id = randint(1, N_users)
            if user_id in user_product.keys():
                user_product[user_id].append(programming_product)
            else:
                user_product[user_id] = [programming_product]
            user_installation[user_id] += 1
            line = 1
            installations.write(
             f'{i}|{install_date}|{programming_product_num}|{operating_system}|{price_for_license}|{user_id}\n')
        for u in range(1, N_users + 1):
            name_surname = choice(names_surnames)
            user_information = '{"name" :"' + name_surname[0] + '", "surnmame":"' + name_surname[1][:-1] + '", "age":' + str(randint(10, 60)) + '}'
            products = '{'
            if u in user_product.keys():
                products += user_product[u][0]
                for i in user_product[u]:
                    if i != user_product[u][0]:
                        products += ','
                        products += i
            products += '}'
            users.write(f'{u}|{user_information}|{choice(characteristics)}|{user_installation[u]}|{products}\n')

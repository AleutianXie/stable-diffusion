# encoding=utf8
import pymysql.cursors

from ape.lib import setting


def get_db_conn():
    settings = setting.Settings()
    # Connect to the database
    return pymysql.connect(host=settings.db_host,
                           user=settings.db_user,
                           port=settings.db_port,
                           password=settings.db_password,
                           database=settings.db_name,
                           cursorclass=pymysql.cursors.DictCursor)

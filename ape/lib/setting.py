# encoding=utf8
import os

from pydantic import BaseSettings


class Settings(BaseSettings):
    db_host: str = "localhost"
    db_port: int = 3306
    db_user: str = "root"
    db_password: str = "Password01!"
    db_name: str = "jms"

    # oss
    oss_access_key_id: str = ""
    oss_access_key_secret: str = ""
    oss_bucket_name: str = ""
    oss_endpoint: str = ""
    oss_domain: str = ""
    oss_cdn_domain: str = ""
    # 指定数据要复制到的目标Bucket。
    oss_target_bucket_name: str = ""
    # 指定目标Bucket所在的Region。
    oss_target_bucket_location: str = "oss-cn-beijing"

    class Config:
        env_file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                f'.env_{os.getenv("RUN_MODE", "dev")}')

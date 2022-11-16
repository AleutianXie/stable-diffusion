# encoding=utf8
import oss2

from ape.lib import setting


def get_bucket(bucket_name: str = None):
    settings = setting.Settings()
    auth = oss2.Auth(settings.oss_access_key_id, settings.oss_access_key_secret)
    if bucket_name is None:
        return oss2.Bucket(auth, settings.oss_endpoint, settings.oss_bucket_name)
    return oss2.Bucket(auth, settings.oss_endpoint, bucket_name)


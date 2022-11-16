# encoding=utf8
import json
import os

from ape.lib import mysql, setting, oss


def progress(percent: int):
    tid = int(os.getenv("TASK_ID", 0))
    if tid > 0:
        with mysql.get_db_conn() as connection:
            with connection.cursor() as cursor:
                sql = f"UPDATE `dfu_task` SET `progress` = %s, " \
                      f"`updated_at` = REPLACE(unix_timestamp(current_timestamp(3)),'.','') WHERE `id` = %s "
                cursor.execute(sql, (percent, tid,))
                connection.commit()


def complete(tid: int, pic_files: str):
    with mysql.get_db_conn() as connection:
        with connection.cursor() as cursor:
            sql = f"UPDATE `dfu_task` SET `pic_files` = %s, `progress` = 10000, `status` = 2, `job_status` = 3, " \
                  f"`updated_at` = REPLACE(unix_timestamp(current_timestamp(3)),'.','') WHERE `id` = %s"
            cursor.execute(sql, (pic_files, tid,))
            connection.commit()


def upload_model(n_samples: int, n_iter: int):
    tid = int(os.getenv("TASK_ID", 0))
    run_mode = os.getenv("RUN_MODE", "dev")
    print(tid, run_mode)

    if tid > 0:
        model_oss_path_prefix = f'Download_data/model/dfu/{run_mode}'
        log_oss_path_prefix = f'Download_data/log_dfu/model/{run_mode}'
        settings = setting.Settings()
        model_oss_path = f'{model_oss_path_prefix}/task_{tid}'
        log_oss_path = f'{log_oss_path_prefix}/task_{tid}'

        current_path = os.path.dirname(os.path.abspath(__file__))
        bucket = oss.get_bucket()
        target_bucket = oss.get_bucket(settings.oss_target_bucket_name)
        out_path = os.path.join(os.path.dirname(os.path.dirname(current_path)), "outputs/txt2img-samples/samples")

        pic_files = []
        for index in range(1, n_samples * n_iter + 1):
            pic_name = f"{index:05}.png"
            pic_path = os.path.join(out_path, pic_name)
            oss_pic_path = os.path.join(model_oss_path, pic_name)
            if os.access(pic_path, os.F_OK):
                bucket.put_object_from_file(oss_pic_path, pic_path)
                target_bucket.put_object_from_file(oss_pic_path, pic_path)
                pic_files.append(oss_pic_path)
                print(f'upload {pic_name} succeed.')

        # upload log
        log_path = os.path.join(os.path.dirname(os.path.dirname(current_path)), "error.log")
        oss_log_path = os.path.join(log_oss_path, "error.log")
        if os.access(log_path, os.F_OK):
            bucket.put_object_from_file(oss_log_path, log_path)
            target_bucket.put_object_from_file(oss_log_path, log_path)
            print("upload error log file succeed.")

        # complete, update model_files, status, job_status
        complete(tid, json.dumps(pic_files))

        print("Upload model Done!")

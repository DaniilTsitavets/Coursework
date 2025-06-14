import os
import boto3
import psycopg2

def run_sql_script(cursor, sql):
    for stmt in sql.strip().split(';'):
        if stmt.strip():
            cursor.execute(stmt)

def handler(event, context):
    try:
        # ENV vars
        s3_bucket     = os.environ["S3_BUCKET"]
        init_sql_key  = os.environ["INIT_SQL_KEY"]
        etl_sql_key   = os.environ["ETL_SQL_KEY"]

        db_host       = os.environ["OLAP_HOST"]
        db_name       = os.environ["OLAP_NAME"]
        db_user       = os.environ["OLAP_USER"]
        db_password   = os.environ["OLAP_PASSWORD"]

        # Connect to OLAP DB
        conn = psycopg2.connect(
            host=db_host,
            port=5432,
            database=db_name,
            user=db_user,
            password=db_password
        )
        cur = conn.cursor()

        s3 = boto3.client("s3")

        init_sql_obj = s3.get_object(Bucket=s3_bucket, Key=init_sql_key)
        init_sql = init_sql_obj["Body"].read().decode("utf-8")
        run_sql_script(cur, init_sql)

        etl_sql_obj = s3.get_object(Bucket=s3_bucket, Key=etl_sql_key)
        etl_sql = etl_sql_obj["Body"].read().decode("utf-8")
        run_sql_script(cur, etl_sql)

        conn.commit()
        cur.close()
        conn.close()

        return {"statusCode": 200, "body": "OLAP ETL completed"}

    except Exception as e:
        print(f"ERROR: {e}")
        return {"statusCode": 500, "body": str(e)}

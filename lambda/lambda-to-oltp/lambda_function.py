import os
import boto3
import psycopg2


def handler(event, context):
    try:
        s3_bucket = os.environ["S3_BUCKET"]
        s3_key = os.environ["S3_KEY"]
        db_host = os.environ["DB_HOST"]
        db_name = os.environ["DB_NAME"]
        db_user = os.environ["DB_USER"]
        db_password = os.environ["DB_PASSWORD"]
        db_port = os.environ.get("DB_PORT", "5432")

        s3 = boto3.client("s3")
        sql_obj = s3.get_object(Bucket=s3_bucket, Key=s3_key)
        sql_query = sql_obj["Body"].read().decode("utf-8")

        print("SQL script loaded from S3")

        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )

        with conn.cursor() as cur:
            cur.execute(sql_query)
        conn.commit()
        conn.close()

        print("SQL executed successfully")

        return {
            "statusCode": 200,
            "body": "SQL executed"
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 500,
            "body": str(e)
        }

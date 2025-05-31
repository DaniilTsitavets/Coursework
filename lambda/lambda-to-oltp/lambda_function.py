import os
import boto3
import psycopg2

def handler(event, context):
    try:
        s3_bucket = os.environ["S3_BUCKET"]
        etl = os.environ["ETL_KEY"]
        init_tables_key = os.environ["INIT_TABLES_KEY"]
        csv_key = os.environ["CSV_KEY"]
        db_host = os.environ["DB_HOST"]
        db_name = os.environ["DB_NAME"]
        db_user = os.environ["DB_USER"]
        db_password = os.environ["DB_PASSWORD"]
        db_port = os.environ.get("DB_PORT", "5432")

        s3 = boto3.client("s3")

        init_obj = s3.get_object(Bucket=s3_bucket, Key=init_tables_key)
        init_script = init_obj["Body"].read().decode("utf-8")

        etl_obj = s3.get_object(Bucket=s3_bucket, Key=etl)
        etl_script = etl_obj["Body"].read().decode("utf-8")

        csv_obj = s3.get_object(Bucket=s3_bucket, Key=csv_key)
        csv_content = csv_obj["Body"].read()
        csv_path = "/tmp/test.csv"
        with open(csv_path, "wb") as f:
            f.write(csv_content)

        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )
        cur = conn.cursor()

        cur.execute(init_script)
        conn.commit()

        with open(csv_path, "r", encoding="utf-8") as f:
            cur.copy_expert(
                "COPY staging_data FROM STDIN WITH CSV HEADER DELIMITER ','",
                f
            )
        conn.commit()

        cur.execute(etl_script)
        conn.commit()

        cur.close()
        conn.close()

        print("SQL scripts executed and CSV loaded successfully")
        return {"statusCode": 200, "body": "ETL completed"}

    except Exception as e:
        print(f"ERROR: {str(e)}")
        return {"statusCode": 500, "body": str(e)}

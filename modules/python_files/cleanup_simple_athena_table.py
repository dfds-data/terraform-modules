from os import environ
import awswrangler as wr
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def delete_data(path, table, database):
    try:
        wr.s3.delete_objects(path)

        wr.athena.read_sql_query(sql=f"DROP TABLE {table};", database=database, ctas_approach=False)
    except wr.exceptions.QueryFailed:
        pass


def lambda_handler(event=None, context=None):
    glue_table = environ["glue_table_name"]
    glue_dummy_table = f"{glue_table}_dummy"
    glue_database = environ["glue_database_name"]

    lambda_output_bucket = environ["lambda_output_bucket"]
    lambda_output_folder = environ["lambda_output_folder"]
    lambda_output_dummy_folder = f"dummy-{lambda_output_folder}"

    # Very important to keep the last forward slash. Theres a bug in awswrangler that will assume a
    # wildcard if no forward slash.
    data_path = f"s3://{lambda_output_bucket}/{lambda_output_folder}/"
    dummy_path = f"s3://{lambda_output_bucket}/{lambda_output_dummy_folder}/"

    # Delete old dummy data if it still exists
    delete_data(path=dummy_path, table=glue_dummy_table, database=glue_database)

    # Clean up data and save to new copy
    wr.athena.read_sql_query(
        f"""CREATE TABLE {glue_dummy_table} WITH (format='PARQUET', parquet_compression = 'SNAPPY', external_location='{dummy_path}') AS SELECT * FROM {glue_table};""",
        database=glue_database,
        ctas_approach=False,
    )

    # Delete original data
    delete_data(path=data_path, table=glue_table, database=glue_database)

    # Copy cleaned up data into folder that was deleted in above step
    list_of_objects = wr.s3.list_objects(dummy_path)
    wr.s3.copy_objects(paths=list_of_objects, source_path=dummy_path, target_path=data_path)

    # Create athena table
    wr.s3.store_parquet_metadata(
        path=data_path, database=glue_database, table=glue_table, dataset=True
    )

    # Delete dummy data
    delete_data(path=dummy_path, table=glue_dummy_table, database=glue_database)


if __name__ == "__main__":
    from dotenv import load_dotenv

    lambda_handler()
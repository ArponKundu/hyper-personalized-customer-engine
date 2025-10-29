from sqlalchemy import create_engine, text
from .config import settings
import os

def read_sql_file(path: str) -> str:
    """Read an SQL file and return its contents."""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def main():
    """Connect to Postgres and execute the schema SQL."""
    # Build connection engine from .env
    engine = create_engine(settings.pg_dsn, future=True, pool_pre_ping=True)
    print("Connecting to:", settings.pg_dsn)

    schema_path = os.path.join("sql", "02_schema.sql")
    if not os.path.exists(schema_path):
        raise FileNotFoundError(f"Schema file not found: {schema_path}")

    sql_script = read_sql_file(schema_path)

    with engine.begin() as conn:
        print(f"Applying {schema_path} ...")
        conn.execute(text(sql_script))

    print("✅ Database schema created successfully.")

if __name__ == "__main__":
    main()

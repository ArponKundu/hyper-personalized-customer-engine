from dotenv import load_dotenv
import os
import psycopg2

def main():
    print("🔌 Testing PostgreSQL connection...\n")

    # load .env
    load_dotenv()

    # read env vars
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    dbname = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")

    print(f"Connecting using:")
    print(f"  host={host}")
    print(f"  port={port}")
    print(f"  dbname={dbname}")
    print(f"  user={user}")
    # don't print password for safety

    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            dbname=dbname,
            user=user,
            password=password,
        )
        cur = conn.cursor()

        # 1. confirm basic connection
        cur.execute("SELECT version();")
        version = cur.fetchone()[0]
        print("\n✅ Connected!")
        print(f"PostgreSQL server version:\n  {version}")

        # 2. confirm TimescaleDB extension is available / enabled
        try:
            cur.execute("SELECT extversion FROM pg_extension WHERE extname='timescaledb';")
            row = cur.fetchone()
            if row:
                print(f"\n🕒 TimescaleDB is installed, version {row[0]}")
            else:
                print("\n⚠️ TimescaleDB extension is NOT enabled in this database yet.")
                print("   We'll enable it in a moment.")
        except Exception as e:
            print("\n⚠️ Could not query TimescaleDB extension:")
            print(f"   {e}")

        cur.close()
        conn.close()
        print("\n🔒 Connection closed cleanly.")

    except Exception as e:
        print("\n❌ Connection failed:")
        print(e)

if __name__ == "__main__":
    main()
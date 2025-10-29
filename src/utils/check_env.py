# src/utils/check_env.py
from dotenv import load_dotenv
import os

def main():
    print("🔍 Checking environment variables from .env file...\n")
    load_dotenv()

    required_vars = [
        "DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD",
        "DATABASE_URL", "TIMESCALEDB_ENABLED"
    ]

    missing = []
    for var in required_vars:
        value = os.getenv(var)
        if not value:
            missing.append(var)
        else:
            print(f"{var} = {value}")

    if missing:
        print("\n⚠️ Missing environment variables:")
        for var in missing:
            print(f"  - {var}")
        print("\n❌ Please check your .env file and try again.")
    else:
        print("\n✅ All required environment variables are set correctly!")

if __name__ == "__main__":
    main()
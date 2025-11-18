from pydantic import BaseModel
from dotenv import load_dotenv
import os

load_dotenv()  # Load .env from project root

class Settings(BaseModel):
    PGHOST: str = os.getenv("PGHOST", "localhost")
    PGPORT: int = int(os.getenv("PGPORT", "5432"))
    PGUSER: str = os.getenv("PGUSER", "postgres")
    PGPASSWORD: str = os.getenv("PGPASSWORD", "admin123")
    PGDATABASE: str = os.getenv("PGDATABASE", "hpce_db")

    @property
    def pg_dsn(self) -> str:
        return (
            f"postgresql+psycopg2://{self.PGUSER}:{self.PGPASSWORD}"
            f"@{self.PGHOST}:{self.PGPORT}/{self.PGDATABASE}"
        )

settings = Settings()

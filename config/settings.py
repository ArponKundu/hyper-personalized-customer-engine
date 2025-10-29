# Project Configuration Settings

DATABASE_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'customer_analytics',
    'user': 'postgres',
    'password': 'password'
}

MODEL_CONFIG = {
    'churn_prediction_horizons': [30, 60, 90],
    'segmentation_clusters': 5,
    'recommendation_top_k': 5
}

DASHBOARD_CONFIG = {
    'host': 'localhost',
    'port': 8501,
    'debug': True
}

API_CONFIG = {
    'host': 'localhost',
    'port': 8000,
    'reload': True
}
import os
import requests

BASE_URL = os.getenv("NOCODB_URL", "http://localhost:8080")

def test_homepage_status():
    response = requests.get(BASE_URL + "/")
    assert response.status_code == 200

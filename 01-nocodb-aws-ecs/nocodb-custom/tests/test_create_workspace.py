import os
import requests

BASE_URL = os.getenv("NOCODB_URL", "http://localhost:8080")
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

def test_create_workspace():
    payload = {
        "workspaceName": "test_workspace"
    }

    response = requests.post(BASE_URL + "/api/v1/workspaces", json=payload, headers=HEADERS)

    assert response.status_code in [200, 201, 409]

from locust import HttpUser, task, between

class User(HttpUser):
    wait_time = between(1, 2)

    @task
    def root(self):
        self.client.get("/")  # SSL vérification activée

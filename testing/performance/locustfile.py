from locust import HttpUser, task

class LazarusUser(HttpUser):
    @task
    def test_quiz_submit(self):
        self.client.get("/submit")

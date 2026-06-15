# Task Manager — Spring Boot + MySQL + AWS

## Folder Structure



```
task-manager/
│
├── src/
│   ├── main/
│   │   ├── java/com/example/taskmanager/
│   │   │   ├── TaskManagerApplication.java       ← Spring Boot entry point
│   │   │   ├── controller/
│   │   │   │   └── TaskController.java           ← REST API (GET/POST/PUT/DELETE)
│   │   │   ├── model/
│   │   │   │   └── Task.java                     ← JPA Entity (@Entity)
│   │   │   └── repository/
│   │   │       └── TaskRepository.java           ← JpaRepository interface
│   │   └── resources/
│   │       └── application.properties            ← DB config, port 80
│   └── test/
│       └── java/com/example/taskmanager/
│           └── TaskManagerApplicationTests.java
│
├── Dockerfile                                    ← Multi-stage build, port 80
├── docker-compose.yml                            ← App + MySQL, port 80
├── pom.xml                                       ← Spring Boot 3.2, Java 17
└── README.md
```

---

## Port Alignment

| Layer                    | Port |
|--------------------------|------|
| `application.properties` | 80   |
| `Dockerfile EXPOSE`      | 80   |
| `docker-compose` mapping | 80   |
| ALB Listener             | 80   |
| ALB Target Group         | 80   |

Everything speaks port 80. No mismatch.

---

## Run Locally

```bash
# From the project root (where docker-compose.yml lives):
docker compose up --build

# First build takes ~2-3 min (Maven downloads deps).
# After that:
#   App  → http://localhost:80
#   API  → http://localhost/tasks
#   DB   → localhost:3306 
```

### Useful commands

```bash
# Stop (keep DB data)
docker compose down

# Stop + wipe DB volume
docker compose down -v

# Rebuild only the app after code changes
docker compose up --build app

# View logs
docker compose logs -f app
```

---

## API Endpoints

| Method | Path          | Body                                          | Description     |
|--------|---------------|-----------------------------------------------|-----------------|
| GET    | `/`           | —                                             | Health check    |
| GET    | `/tasks`      | —                                             | List all tasks  |
| GET    | `/tasks?completed=true` | —                                 | Filter tasks    |
| GET    | `/tasks/{id}` | —                                             | Get one task    |
| POST   | `/tasks`      | `{"description":"Buy milk","completed":false}`| Create task     |
| PUT    | `/tasks/{id}` | `{"description":"Buy milk","completed":true}` | Update task     |
| DELETE | `/tasks/{id}` | —                                             | Delete task     |

---

## Deploy to AWS

```bash
cd main/
terraform init
terraform plan
terraform apply
```

The ASG `userdata.sh` pulls your Docker image and runs it with `DB_ENDPOINT` set to the RDS endpoint output from Terraform.

### Build and Push to Docker Hub

1. **Authenticate:**
   ```bash
   docker login
   ```

2. **Build:**
   ```bash
   docker build -t <username>/task-manager-app:latest .
   ```

3. **Push:**
   ```bash
   docker push <username>/task-manager-app:latest
   ```
```

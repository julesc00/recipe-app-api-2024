# Recipe Django and Django Restframework Project
By Mark Winterbottom at: [Udemy](https://www.udemy.com/share/101XNg3@RtX7c6HSUAt5ip5zX0yrdXkXLxk4ZHwPE-VJFAuH4TocWLXq8DMpE3dL29yObYkutg==/)

## Section 4: Project Setup
### Docker and Django
1. Paste token into GitHub repo at *Secrets* -> New repository secret.   
2. Run `docker login -u julesc00`.
3. `--rm` removes the container.
4. `app` is the name of the service.
5. `sh -c` passes in a shell command.
6. `"python manage.py collectstatic"` Command to run inside container.
7. Docker compose syntax `docker-compose run --rm app `.
8. Command that runs on the container `sh -c "python manage.py collectstatic" `.

### Define Requirements
1. Declare the `requirements.txt` file.
    ```
    Django>=3.2.4,<3.3
    djangorestframework>=3.12.4,<3.13
   ```
### Create Project Dockerfile
```aiignore
FROM python:3.9-alpine3.13
LABEL maintainer="julesc003@gmail.com"
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user 

ENV PATH="/py/bin:$PATH"

USER django-user
```
**Note:** `PYTHONUNBUFFERED` This is recommended when running Python in a Docker container,
this would print immediately Python's buffer to console which prevents any delays.

**Note:** `python -m venv /py` We create a virtual environment in our Docker image to fully control
our dependencies, there have been cases where the image's dependencies versions conflict
with the project's.

**Note:** `rm -rf /tmp ` It's best practice to keep Docker images as light-weight as possible.

**Note:** `adduser ...` It's best practice not to use the `root` user, this will provide a layer of security.

**Note:** `ENV PATH="/py/bin:$PATH"` This will update the environment variable path. This defines all the directives
where executables can be run. Like this, we don't have to specify the whole path to our environment.

**Note:** `django-user` At last, we switch to our user, so from there forward commands will
be run using this user, and not the `root` user.

### Create .dockerignore file
Create a `.dockerignore` file to exclude certain files from the Docker context.
```aiignore
# Git
.git

# Docker
.docker

# Python
app/__pycache__/
app/*/__pycache__/
app/*/*/__pycache__/
app/*/*/*/__pycache__/
.env/
.venv/
venv/
```
**Build the image:** Before running this command, make sure to have already
created the `app` directory: `docker build .`

### Create Docker Compose Configuration
```aiignore
version: "3.9"

services:
  app:
    build:
      context: .
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app
    command: >
      sh -c "python manage.py runserver 0.0.0.0:8000"
```

**Note:** `context: .` Means to use the current directory

**Note:** `- 8000:8000` This will map port `8000` on our local machine to port `8000` on the
local container.

**Notes:** `volumes: ` Are a way of mapping directories from our system into the
Docker container.  
`- ./app:/app` we want the changes we make to our code in our local project to be
reflected in our Docker container in real-time.

**Notes:** `sh -c "python manage.py runserver 0.0.0.0:8000"` command used to run the service.

Run `docker-compose build` to build our Docker image.

### Linting and Testing
- Install `flake8` package
- Run it through Docker compose `docker-compose run --rm app sh -c "flake8"`  
**Note:** Always start correcting errors from the bottom up of flake8's output.
- For testing, we use Django test suite:  
Command to run unit tests: `docker-compose run --rm app sh -c "python manage.py test"`

### Configure flake8
1. Create a new file called `requirements.dev.txt` with line `flake8>=3.9.2,<3.10`.  

We create a new requirements file only for dev since we don't need the flake8 package when
running our deployed application, we don't need to run the linting tool. It's good to separate
our development dependencies from the production deployment package.
2. Add a new line to define our current `docker-compose` file is only running for
development:
```aiignore
    build:
      context: .
      args:
        - DEV=true
    ports:
```
3. Add a new line to the Dockerfile `COPY ./requirements.dev.txt /tmp/requirements.dev.txt`
4. Above `RUN python -m venv /py && \` add another new line to the Dockerfile `ARG DEV=false`.
5. Then we will add a new block of code to the Dockerfile:
```aiignore
/py/bin/pip install -r /tmp/requirements.txt && \ ...
if [ "${DEV}" = "true" ]; \
      then /py/bin/pip install -r requirements.dev.txt ; \
    fi && \
...
```
6. Then run again `docker-compose build`
7. Add a configuration file for flake8 in the app directory called `.flake8`.
```aiignore
[flake8]
exclude =
    migrations,
    __pycache__,
    manage.py,
    settings.py
```
8. Command to run flake8: `docker-compose run --rm app sh -c "flake8"`
**Note:** ***Encountered an error with the Dockerfile and haven't been able to solve it,
so I've created the local environment as well to continue with the course.***

**Above issue solved--Debugging Docker**  
```aiignore
docker-compose down
docker rm -f $(docker ps -aq)
docker system prune
docker volume prune
docker-compose build
docker-compose up
```

### Create GitHub Actions config

## Section Configure Database
Download the official alpine postgres image from `hub.docker.com/postgres`


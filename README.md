# 2024 Winter Wheel Seminar Final Assignment

휠 세미나 최종 과제에서는 휠 세미나 전반에서 배운
지식들을 활용하여 서비스를 배포하게 됩니다.

# Requisites
이 과제에서는 다음과 같은 기능들을 구현하게 됩니다.

- [ ] **[`app.py`](./app.py)를 작동시키는 `Dockerfile`을 작성**
    - **WHL205** Docker
- [ ] **[`app.py`](./app.py)와 mysql 데이터베이스, `nginx` 리버스 프록시로 구성된 
`docker-compose.yml` 작성**
    - **WHL205** Docker
    - **WHL210** Apache & NginX
- [ ] **AWS의 `EC2`와 `S3`을 이용하여 서비스를 배포할 수 있는 환경 구성**
    - **WHL201** AWS
    - **WHL202** Linux
    - **WHL204** File System & Physical Disk
    - **WHL209** Network & DNS
- [ ] **이미지를 빌드하여 이미지 레지스트리에 푸시 / 서버에서 배포하는 CD 파이프라인 구축**
    - **WHL208** Github Actions & Introduction to CI / CD
- [ ] **`EC2`에 배포된 서비스를 `HTTPS`로 접속할 수 있도록 `ssl` 인증서 발급**
    - **WHL206** Security & Backup
    - **WHL210** Apache & NginX
- [ ] (optional) **Shell script와 crontab을 이용하여 데이터베이스를 주기적으로 백업**
    - **WHL203** Shell Script & Cron
    - **WHL206** Security & Backup

![Overview](./overview.png)

# Guide
최종 과제를 구현하기 위한 가이드입니다. 
어디까지나 가이드일 뿐이며, 꼭 **가이드에 나온 방법, 툴을 사용하지 않아도 무방**합니다. 

## 1. `Dockerfile` 작성
이 과제에서는 [`app.py`](./app.py)를 작동시키는 `Dockerfile`을 작성해야 합니다.

`Dockerfile` 안에서는 다음과 같은 작업을 수행해야 합니다. 

[`./Dockerfile`](./Dockerfile)
- [ ] `pip install -r requirements.txt`으로 디펜던시 설치
- [ ] `python3 app.py`로 서버 실행

베이스 이미지로는 클라이언트와 서버 모두 [`python:3.11-bullseye`](https://hub.docker.com/_/python) 이미지, 또는 이를 베이스로 하는 이미지를 사용하면 됩니다. 

## 2. `docker-compose.yml` 작성
[`docker-compose.yml`](./docker-compose.yml) 파일을 작성하여 클라이언트, 서버, 데이터베이스, 리버스 프록시 컨테이너를 구성하게 됩니다.

### 서버 컨테이너
위에서 작성한 `Dockerfile`을 이용하여 서버 컨테이너를 구성합니다. 
이때 각각의 컨테이너에 필요한 환경 변수들을 설정해 주어야 합니다. 

#### 환경 변수
```dotenv
DOMAIN=                  # 서비스 도메인
AWS_ACCESS_KEY_ID=       # AWS Access Key ID
AWS_SECRET_ACCESS_KEY=   # AWS Secret Access Key
AWS_S3_BUCKET_NAME=      # AWS S3 버킷 이름
```


> **HINT** 
> `docker-compose.yml` 파일은 `EC2` 서버에 존재하나, `server`의 빌드는 Github Actions에서 이루어지게 되므로 
> 사용하는 이미지 레지스트리에서의 이미지 이름과 태그를 사용해야 합니다.

### 데이터베이스

이 레포지토리에서는 `Mysql`을 사용합니다.
[`mysql` 이미지](https://hub.docker.com/_/mysql)를 사용하여 데이터베이스 컨테이너를 구성합니다.

이 이미지의 자세한 사용 방법에 대해서는 [Docker Hub](https://hub.docker.com/_/mysql)을 참고하세요.

### 리버스 프록시

[`nginx` 이미지](https://hub.docker.com/_/nginx)를 사용하여 리버스 프록시 컨테이너를 구성합니다.

`/` 주소로 접속했을 때 static 폴더로, `/api` 주소로 접속했을 때 서버 컨테이너로 프록시를 설정해야 합니다.

Docker의 [Networking](https://docs.docker.com/network/) 기능을 활용하면 서버 컨테이너의 포트를 외부에 노출하지 않고
프록시를 설정할 수 있습니다.

> **HINT** 
> `nginx.conf` 파일을 컨테이너 내부에 적용하기 위해 다음 방법 중 하나를 사용해 볼 수 있습니다. 
> - Volume mount 이용
> - 기존 nginx 이미지를 베이스 이미지로 하는 새로운 이미지 빌드


## 3. CI/CD 파이프라인 구성

이 가이드에서는 CD 파이프라인을 구성하기 위해 **Github Actions**를 사용합니다. 
[`./.github/workflows/cd.yml`](./.github/workflows/cd.yml)에 워크플로우를 작성하면 됩니다. 추가 파일을 만드셔도 됩니다. 

### `server` 이미지 빌드 후 이미지 레지스트리에 푸시

이미지 레지스트리로는 [Github Registry](https://ghcr.io)를 사용하면 비교적 간단한 security 설정을 통해 사용할 수 있습니다.
대신 [Docker hub](https://hub.docker.com/)를 사용해도 무방합니다.

서버와 클라이언트의 이미지를 빌드하고, 이미지 레지스트리에 푸시하는 워크플로우를 구성하면 됩니다. 


> **HINT** 
> [`docker/build-push-action`](https://github.com/marketplace/actions/build-and-push-docker-images)를 사용해서
> 워크플로우를 구성해 보세요. [Github 공식 docs](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows/publishing-and-installing-a-package-with-github-actions)
> 를 참고하는 것도 도움이 될 수 있습니다. 

### (optional) 새로 빌드된 이미지 기반으로 EC2의 컨테이너 재시작

이전 세미나에서 `platypus`님의 발표에서 다루었던 'Deploy to EC2' 워크플로우를 참고하면 비교적 쉽게 구성할 수 있습니다.
따로 이 방법을 사용하지 않고, 직접 이미지 레지스트리에서 이미지를 다운로드 받아 EC2에 배포하는 것도 가능합니다.


> **HINT** 
> `docker-compose.yml` 파일이 이미지 레지스트리에 푸쉬된 이미지를 사용하도록 작성되어 있다면
> `docker-compose up -d`을 다시 실행하는 것만으로 서비스를 재배포할 수 있습니다.


## 4. AWS 배포 환경 구성

AWS에 배포하기 위해 `EC2`와 `S3`을 사용해 배포 환경을 구성해 주면 됩니다.

### EC2

클라이언트 컨테이너와 서버 컨테이너, 리버스 프록시 컨테이너와 데이터베이스 컨테이너 모두를 EC2 인스턴스에 배포합니다.

모두 도커화되어 있으므로 EC2 인스턴스에는 **도커 컨테이너를 올릴 수 있는 환경**만 구성해주면 됩니다. 

또한 CI/CD를 위해 설정을 구성해주셔야 합니다. 

### S3

S3는 asset을 업로드하기 위해 사용됩니다. 이를 위해서 권한이 **public**으로 설정된 S3 버킷을 생성해 주시면 됩니다.

## 5. SSL 인증서

`letsencrypt`에서 SSL 인증서를 발급받아 서비스에 https로 접속할 수 있도록 합니다. 

구현 방법은 자유이며, 가능한 구현 방법 예시로는 다음이 있습니다. 

- (권장) pip install을 통해 `certbot` 라이브러리를 설치하고, `certbot`을 이용해 SSL 인증서 발급
- [`certbot` 이미지](https://hub.docker.com/r/webdevops/certbot) 사용
- `nginx` 컨테이너 볼륨 매핑 후 로컬 머신에서 `certbot` 사용
- 기존 `nginx` 이미지 대신 SSL 인증서 발급 및 자동 갱신을 지원하는 다른 이미지 사용

nginx 설정에 적용하기 위해서는 밑 설정을 http 블록에 추가해주시면 됩니다.

```conf
ssl_certificate /path/to/ssl/fullchain.pem;
ssl_certificate_key /path/to/ssl/privkey.pem;
```

nginx 세미나 도중 certbot의 사용방법에 대해 다뤄지지 않았으므로, 밑에 후술된 방법을 사용하는 것을 추천합니다.

### pip certbot standalone을 통한 인증

`certbot` 이미지를 사용하여 `standalone` 모드로 인증을 받을 수 있습니다.

nginx 컨테이너가 중단 된 상태에서 인증서를 발급받고, 인증서를 받은 후에 다시 nginx 컨테이너를 실행하면 됩니다.

```bash
certbot certonly --standalone -d {domain}
```

이후 /etc/letsencrypt/live/{domain} 폴더에 인증서가 저장되며, 이를 nginx 컨테이너에 볼륨 매핑하여 사용하면 됩니다.

### pip certbot .well-known 폴더를 통한 인증

nginx 컨테이너를 설정하실 때 `.well-known` 폴더를 컨테이너 내부에 볼륨 매핑하여 `certbot`이 인증을 받을 수 있도록 해주시면 됩니다.

`docker-compose.yml` 에서 다음 예시와 같이 볼륨 매핑을 먼저 합니다.

```yaml
volumes:
  - ./web/.well-known:/var/www/.well-known
```

그리고 밑 설정을 http 블록에 추가해주시면 됩니다.

```conf
location /.well-known {
    alias /var/www/.well-known;
}
```

이후 아래 명령어를 통해 SSL 인증서를 발급받을 수 있습니다.

```bash
certbot certonly --webroot -w ./web/ -d {domain}
```



## 6. 데이터베이스 백업 설정
> Optional 과제를 수행하는 경우에만 필요한 단계입니다. 

`crontab`을 이용해 주기적으로 Mysql의 덤프 파일을 생성하고 S3에 백업하도록 합니다. 

액세스 권한이 다르게 설정된 별도의 S3 버킷을 생성하고, 백업 및 업로드를 진행하는 스크립트를 작성해주시면 됩니다. 
상세한 구현 방법은 자유입니다. 


# Submission

과제의 내용이 모두 구현된 **Github Repository**와 AWS에 배포된 **서비스의 링크**, 모든 작업을 수행한 후 생성된 **JWT 토큰**을 제출해 주세요.


# Remarks

휠 세미나에서 배운 내용을 모두 활용하는 과제인 만큼, 과제의 난이도가 기존 과제들보다 훨씬 높을 것이라 생각합니다. 

휠 세미나를 통과하기 위한 장벽이라기 보다는, 공부한 내용을 실제로 적용해 보고 이를 조합하여 하나의 서비스를 배포하는 데에 중점을 두었으므로 
과제를 하다 막히거나 궁금한 부분이 있다면 자유롭게 질문해 주세요!



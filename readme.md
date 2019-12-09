# intro

將 dotnet 預設範例網站包進 docker 的練習

## 建立 dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
# COPY *.sln .
COPY src/aspMVC/*.csproj ./aspnetapp/
# RUN dotnet restore

# copy everything else and build app
COPY src/aspMVC/. ./aspnetapp/
WORKDIR /app/aspnetapp
RUN dotnet publish -c Release -o out


FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
WORKDIR /app
COPY --from=build /app/aspnetapp/out ./
ENTRYPOINT ["dotnet", "aspMVC.dll"]
```

## 執行 docker

```shell
# 建立標籤為 test 的 image
docker build -t test .

# 依照 test image 建立容器
# 指定容器名稱為 mytest
# 容器停止後刪除
# 指定容器 80 port 對應本機 8002 port
docker run -d --name=mytest --rm -p 8002:80 test
```

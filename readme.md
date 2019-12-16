# intro

將 dotnet 預設範例網站包進 docker 的練習

ref site:[Docker 教學 - 打包 ASP.NET Core 前後端專案 Docker Image](https://blog.johnwu.cc/article/docker-build-asp-net-core-image.html)

## 建立 dockerfile

```dockerfile
# 建置發行檔案
# copy 當前目錄檔案-->容器內aspnetapp目錄
# 到容器目錄app底下執行donet publish到 /app/out
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
COPY . ./app/
WORKDIR /app
RUN dotnet publish -c Release -o out

# 佈署RUNTIME容器並執行網站
# 從build容器內複製build好的檔案至runtime容器
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
COPY --from=build /app/out ./
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

## 調整 dockerfile

```dockerfile
# build/build-image.dockerfile
### build stage
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
ARG project_name
COPY ./src ./src
WORKDIR /src
RUN dotnet publish $project_name -o /publish --configuration Release

### publish stage
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
ARG project_name
COPY --from=build /publish ./
ENV project_dll="${project_name}.dll"
ENTRYPOINT dotnet $project_dll

# docker build -f build/build-image.dockerfile -t test --build-arg project_name=aspMVC .

```

## 編譯前端專案


```dockerfile
# build/build-image.dockerfile
### build stage
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS dotnet-build-env
ARG project_name
COPY ./src ./src
WORKDIR /src
RUN dotnet publish $project_name -o /publish --configuration Release


### Build Stage - npm
FROM node:11 AS npm-build-env
ARG project_name
RUN mkdir -p /publish
RUN npm set progress=false;
COPY ./src /src
WORKDIR /src/$project_name
RUN if [ -f "package.json" ]; then \
        npm i; \
        npm run build; \
        if [ -d "wwwroot" ]; then cp -R wwwroot /publish; fi; \
    fi


### publish stage
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
ARG project_name
WORKDIR /app
COPY --from=dotnet-build-env /publish .
COPY --from=npm-build-env /publish .
ENV project_dll="${project_name}.dll"
ENTRYPOINT dotnet $project_dll

# sample
# docker build -f build/build-image.dockerfile -t test --build-arg project_name=aspMVC .
# docker run -d --name=mytest --rm -p 8002:80 test

```
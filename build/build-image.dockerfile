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